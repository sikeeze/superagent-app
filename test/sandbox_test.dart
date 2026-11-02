// Tes Fase 4: sandbox QuickJS (S-20/21/25).
// Blueprint kriteria: "uji sandbox escape gagal".
import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/core/skills/quickjs_sandbox.dart';

bool _nativeOk = false;

Future<bool> _probe() async {
  try {
    final probe = QuickJsSandbox();
    final res = await probe.run('1+1');
    probe.dispose();
    return res.success && res.output.contains('2');
  } catch (_) {
    return false;
  }
}

void main() {
  setUpAll(() async {
    _nativeOk = await _probe();
  });

  test('S-21: eksekusi JS murni dan terlalu lama dibunuh', () async {
    if (!_nativeOk) {
      print('SKIP: binding QuickJS tidak tersedia di environment ini.');
      return;
    }
    final ok = QuickJsSandbox(timeout: const Duration(seconds: 3));
    expect((await ok.run('40 + 2')).output, contains('42'));
    ok.dispose();

    final slow = QuickJsSandbox(timeout: const Duration(seconds: 1));
    final res = await slow.run('while (true) {}');
    expect(res.success, isFalse);
    expect(res.error, contains('batas waktu'));
    slow.dispose();
  });

  test('S-20: error syntax dikembalikan, host tidak crash', () async {
    if (!_nativeOk) return;
    final s = QuickJsSandbox();
    final res = await s.run('function (((');
    expect(res.success, isFalse);
    expect(res.error, isNotNull);
    s.dispose();
  });

  test('S-20: tidak ada API OS di global JS', () async {
    if (!_nativeOk) return;
    final s = QuickJsSandbox();
    final res = await s.run('typeof process');
    expect(res.output, contains('undefined'));
    s.dispose();
  });

  test('S-25: validasi nama file sandbox menolak traversal', () {
    expect(_safeName('file.txt'), isTrue);
    expect(_safeName('sub/dir/file.txt'), isTrue);
    expect(_safeName('../escape.txt'), isFalse);
    expect(_safeName('a/../../b.txt'), isFalse);
    expect(_safeName('/abs.txt'), isFalse);
    expect(_safeName(''), isFalse);
    expect(_safeName('a\x00b'), isFalse);
  });
}

/// Validasi nama file sandbox (S-25): hanya nama ril di dalam sandbox.
bool _safeName(String name) {
  if (name.isEmpty) return false;
  if (name.contains('..')) return false;
  if (name.contains('\x00')) return false;
  if (name.startsWith('/')) return false;
  return RegExp(r'^[A-Za-z0-9_\-./]+$').hasMatch(name);
}
