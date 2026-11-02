import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/data/database/app_database.dart';

/// Tes database Fase 2: CRUD, cascade delete, search, pemangkasan, dan
/// uji performa 1000 pesan (syarat blueprint Fase 2).
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() async {
    await db.close();
  });

  group('CRUD dasar', () {
    test('buat percakapan, isi pesan, baca kembali', () async {
      final convId = await db.createConversation(title: 'Tes');
      await db.insertMessage(
          conversationId: convId, role: 'user', content: 'Halo');
      await db.insertMessage(
          conversationId: convId, role: 'assistant', content: 'Hai juga');

      final msgs = await db.messagesFor(convId);
      expect(msgs.length, 2);
      expect(msgs[0].role, 'user');
      expect(msgs[1].role, 'assistant');
      expect(await db.conversationCount(), 1);
      expect(await db.messageCount(), 2);
    });

    test('update isi pesan (edit)', () async {
      final convId = await db.createConversation();
      final id = await db.insertMessage(
          conversationId: convId, role: 'user', content: 'lama');
      await db.updateMessageContent(id, 'baru');
      final msgs = await db.messagesFor(convId);
      expect(msgs.single.content, 'baru');
    });

    test('metadata tersimpan untuk kartu tool', () async {
      final convId = await db.createConversation();
      final id = await db.insertMessage(
        conversationId: convId,
        role: 'tool',
        content: '200 OK',
        toolName: 'http_request',
        toolStatus: 'ok',
        toolDurationMs: 1200,
        toolArgsJson: '{"url":"https://a.example.com"}',
      );
      final m = (await db.messagesFor(convId)).single;
      expect(m.id, id);
      expect(m.toolName, 'http_request');
      expect(m.toolStatus, 'ok');
      expect(m.toolDurationMs, 1200);
    });
  });

  group('cascade delete', () {
    test('hapus percakapan menghapus semua pesannya', () async {
      final convId = await db.createConversation();
      for (var i = 0; i < 10; i++) {
        await db.insertMessage(
            conversationId: convId, role: 'user', content: 'p$i');
      }
      expect(await db.messageCount(), 10);

      await db.deleteConversation(convId);
      expect(await db.conversationCount(), 0);
      expect(await db.messageCount(), 0,
          reason: 'FK cascade harus menghapus pesan');
    });
  });

  group('pencarian riwayat', () {
    test('searchMessages menemukan teks di percakapan manapun', () async {
      final c1 = await db.createConversation();
      final c2 = await db.createConversation();
      await db.insertMessage(
          conversationId: c1, role: 'user', content: 'Cek kuota task hari ini');
      await db.insertMessage(
          conversationId: c2, role: 'assistant', content: 'Kuota tersisa 5');

      final hits = await db.searchMessages('kuota');
      expect(hits.length, 2, reason: 'LIKE case-insensitive di SQLite');
    });

    test('query dengan % tidak memblokir pola', () async {
      final c1 = await db.createConversation();
      await db.insertMessage(
          conversationId: c1, role: 'user', content: 'diskon 50% besok');
      final hits = await db.searchMessages('50%');
      expect(hits.length, 1);
    });
  });

  group('pemangkasan konteks (sliding window)', () {
    test('pruneMessages menyimpan N pesan terakhir', () async {
      final convId = await db.createConversation();
      for (var i = 0; i < 50; i++) {
        await db.insertMessage(
            conversationId: convId, role: 'user', content: 'm$i');
      }
      final removed = await db.pruneMessages(convId, 10);
      expect(removed, 40);
      final left = await db.messagesFor(convId);
      expect(left.length, 10);
      expect(left.first.content, 'm40');
      expect(left.last.content, 'm49');
    });

    test('prune tidak menghapus apa pun bilaKeepLatest >= jumlah', () async {
      final convId = await db.createConversation();
      for (var i = 0; i < 5; i++) {
        await db.insertMessage(
            conversationId: convId, role: 'user', content: 'm$i');
      }
      expect(await db.pruneMessages(convId, 40), 0);
    });
  });

  group('uji performa blueprint Fase 2: 1000 pesan', () {
    test('menulis 1000 pesan dan membaca dalam waktu wajar', () async {
      final convId = await db.createConversation(title: 'Besar');
      final sw = Stopwatch()..start();
      await db.transaction(() async {
        await db.batch((b) {
          for (var i = 0; i < 1000; i++) {
            b.insert(db.messages, MessagesCompanion.insert(
              conversationId: convId,
              role: i.isEven ? 'user' : 'assistant',
              content: 'Pesan nomor $i dengan teks cukup panjang untuk '
                  'mensimulasikan percakapan nyata. lorem ipsum dolor sit amet '
                  'consectetur adipiscing elit sed do eiusmod tempor.',
            ));
          }
        });
      });
      final insertMs = sw.elapsedMilliseconds;
      sw.reset();

      final all = await db.messagesFor(convId);
      final readMs = sw.elapsedMilliseconds;
      sw.stop();

      expect(all.length, 1000);
      // Batas longgar agar tes stabil di mesin CI lambat; yang penting
      // tidak meledak ke detik.
      expect(insertMs, lessThan(5000),
          reason: 'insert batch 1000 pesan terlalu lambat');
      expect(readMs, lessThan(2000),
          reason: 'baca 1000 pesan terlalu lambat');
      // Indeks harus dipakai: plan query tidak boleh full scan.
      final plan = await db.customSelect(
        'EXPLAIN QUERY PLAN SELECT * FROM messages '
        'WHERE conversation_id = ? ORDER BY created_at;',
        variables: [Variable.withInt(convId)],
      ).get();
      final planText = plan.map((r) => r.data.values.join(' ')).join(' | ');
      expect(planText.toLowerCase(), isNot(contains('scan')));
    });
  });
}
