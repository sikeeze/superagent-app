// Tes Fase 7: modul crypto read-only.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:superagent/core/audit/audit_logger.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/crypto/address_validator.dart';
import 'package:superagent/core/crypto/rpc_client.dart';
import 'package:superagent/core/crypto/wallet_watcher.dart';
import 'package:superagent/data/database/app_database.dart';
import 'package:superagent/data/repositories/crypto_repository.dart';

void main() {
  late AppDatabase db;
  late CryptoRepository repo;
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('crypto_test_');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CryptoRepository(db);
  });

  tearDown(() async {
    await db.close();
    try {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    } catch (_) {}
  });

  group('AddressValidator', () {
    test('alamat valid', () {
      expect(AddressValidator.isValid('0x' + 'a' * 40), isTrue);
      expect(AddressValidator.isValid('0x' + '123456789a' * 4), isTrue);
    });

    test('alamat invalid', () {
      expect(AddressValidator.isValid(''), isFalse);
      expect(AddressValidator.isValid('0x123'), isFalse);
      expect(AddressValidator.isValid('zzz' + 'a' * 40), isFalse);
      expect(AddressValidator.isValid('0x' + 'z' * 40), isFalse);
    });

    test('deteksi approve tak terbatas (N-03)', () {
      // Layout: selector(10) + address(64) + amount(64) hex chars.
      final unlimited =
          '0x095ea7b3' + '0' * 64 + 'f' * 64;
      expect(AddressValidator.isUnlimitedApprovalSig(unlimited), isTrue);
      final limited = '0x095ea7b3' + '0' * 64 + '0' * 63 + '1';
      expect(AddressValidator.isUnlimitedApprovalSig(limited), isFalse);
    });

    test('deteksi setApprovalForAll (N-03)', () {
      expect(AddressValidator.isUnlimitedApprovalSig('0xa22cb465' + '0' * 64),
          isTrue);
      expect(AddressValidator.isUnlimitedApprovalSig('0x70a08231' + '0' * 64),
          isFalse);
    });
  });

  group('RpcClient (mock Dio)', () {
    test('getBalance parse hex ke BigInt', () async {
      final dio = _MockDio(jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'result': '0x0de0b6b3a7640000', // 1 ETH
      }));
      final client = RpcClient(url: 'http://rpc', dio: dio);
      final bal = await client.getBalance('0x' + '1' * 40);
      expect(bal, BigInt.parse('1000000000000000000'));
    });

    test('error RPC dilempar', () async {
      final dio = _MockDio(jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'error': {'code': -32000, 'message': 'invalid method'},
      }));
      final client = RpcClient(url: 'http://rpc', dio: dio);
      expect(() => client.blockNumber(), throwsA(isA<RpcException>()));
    });

    test('tokenBalance pakai selector balanceOf', () async {
      late String captured;
      final dio = _MockDioWithCapture(
        jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': '0x64'}),
        onSend: (data) => captured = data.toString(),
      );
      final client = RpcClient(url: 'http://rpc', dio: dio);
      final bal = await client.tokenBalance(
        token: '0x' + '2' * 40,
        owner: '0x' + '3' * 40,
      );
      expect(bal, BigInt.from(100));
      expect(captured, contains('0x70a08231'));
      expect(captured, contains('3' * 40));
      expect(captured, contains('"to":"0x' + '2' * 40 + '"'));
    });
  });

  group('CryptoRepository', () {
    test('add + list wallet', () async {
      final id = await repo.addWallet(
        label: 'Main',
        address: '0x' + '1' * 40,
      );
      expect(id, greaterThan(0));
      final list = await repo.wallets();
      expect(list.length, 1);
      expect(list.first.label, 'Main');
    });

    test('remove wallet', () async {
      final id = await repo.addWallet(
          label: 'x', address: '0x' + '2' * 40);
      await repo.removeWallet(id);
      expect((await repo.wallets()).length, 0);
    });

    test('settings default = Manual (C-11)', () async {
      final s = await repo.settings();
      expect(s.mode, 'manual');
      expect(s.limitPerTx, 0.01);
      expect(s.limitPerDay, 0.05);
      expect(s.maxGasGwei, 5);
      expect(s.autoRevertDays, 7);
    });

    test('save settings', () async {
      await repo.saveSettings(
        mode: 'auto_limited',
        limitPerTx: 0.5,
        limitPerDay: 2.0,
        maxGasGwei: 10,
        autoRevertDays: 3,
      );
      final s = await repo.settings();
      expect(s.mode, 'auto_limited');
      expect(s.limitPerTx, 0.5);
    });

    test('allowlist add + list + remove (N-01)', () async {
      final id = await repo.addContract(
          address: '0x' + '4' * 40, label: 'Claim', functions: 'claim');
      final list = await repo.allowlist();
      expect(list.length, 1);
      expect(list.first.functions, 'claim');
      await repo.removeContract(id);
      expect((await repo.allowlist()).length, 0);
    });
  });

  group('KillSwitch + WalletWatcher (K-01, V-08)', () {
    test('kill switch menghentikan refresh', () async {
      await repo.addWallet(label: 'w', address: '0x' + '5' * 40);
      final audit = AuditLogger(
        '${tmp.path}${Platform.pathSeparator}audit.log');
      final watcher = WalletWatcher(repo: repo, audit: audit);

      KillSwitch.instance.deactivate();
      expect(KillSwitch.instance.stopped, isFalse);

      KillSwitch.instance.activate();
      expect(KillSwitch.instance.stopped, isTrue);

      // Kill switch aktif: refresh kembali map kosong.
      final result = await watcher.refresh();
      expect(result, isEmpty);

      KillSwitch.instance.deactivate();
      watcher.stop();
    });

    test('refresh tanpa RPC default ->RpcException, audit error', () async {
      await repo.addWallet(label: 'w', address: '0x' + '6' * 40);
      final audit = AuditLogger(
        '${tmp.path}${Platform.pathSeparator}audit.log');
      final watcher = WalletWatcher(repo: repo, audit: audit);
      KillSwitch.instance.deactivate();

      // Tanpa RPC (defaultRpc kosong) -> error per dompet, bukan crash.
      final result = await watcher.refresh();
      expect(result, isEmpty);

      // Event failure tercatat di audit log (S-22).
      final entries = await audit.tail();
      expect(entries.any((e) => e.event == 'error'), isTrue);

      watcher.stop();
      await audit.dispose();
    });
  });
}

class _MockDio implements Dio {
  _MockDio(this.body);
  final String body;

  @override
  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return Response<T>(
      data: jsonDecode(body) as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockDioWithCapture implements Dio {
  _MockDioWithCapture(this.body, {required this.onSend});
  final String body;
  final void Function(dynamic data) onSend;

  @override
  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    onSend(data);
    return Response<T>(
      data: jsonDecode(body) as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


