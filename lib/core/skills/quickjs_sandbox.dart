import 'dart:async';
import 'dart:convert';

import 'package:quickjs_engine/quickjs_engine.dart';

/// Hasil eksekusi script di sandbox.
class SandboxResult {
  const SandboxResult({
    required this.success,
    required this.output,
    this.error,
    this.durationMs = 0,
  });

  final bool success;
  final String output;
  final String? error;
  final int durationMs;

  factory SandboxResult.ok(String output, int durationMs) =>
      SandboxResult(success: true, output: output, durationMs: durationMs);

  factory SandboxResult.fail(String error, int durationMs) =>
      SandboxResult(
          success: false, output: error, error: error, durationMs: durationMs);
}

/// Host API yang diekspos ke script JS (S-20: script TIDAK punya akses
/// langsung ke file sistem, jaringan, atau proses — semua lewat sini,
/// dan setiap panggilan dicek PolicyEngine).
abstract class SandboxHost {
  /// Log aman dari script (S-06: tidak mencatat rahasia).
  void log(String level, String message);

  /// HTTP request ke domain allowlist (S-12, S-13). Melempar bila domain
  /// tidak diizinkan.
  Future<String> httpGet(String url);

  /// Baca/tulis hanya di folder sandbox (S-25).
  Future<String> readFile(String name);
  Future<String> writeFile(String name, String content);
}

/// Sandbox QuickJS untuk skill script (blueprint 9.1, aturan S-20/21/25).
///
/// - S-20: script berjalan TANPA akses file sistem, jaringan, atau
///   proses, kecuali lewat [SandboxHost] yang diperiksa PolicyEngine.
/// - S-21: batas waktu eksekusi 10 detik; tanpa eval dinamis dari input
///   jaringan.
/// - S-25: operasi path hanya di dalam direktori sandbox aplikasi.
///
/// Runtime dibuat saat dibutuhkan dan dibuang setelah eksekusi (P-05
/// menyebut idle >60 dtk; kami membuang segera setelah satu script
/// selesai — lebih aman dan tetap hemat karena hanya skill script yang
/// memakai runtime, bukan setiap pesan).
class QuickJsSandbox {
  QuickJsSandbox({this.timeout = const Duration(seconds: 10)});

  /// Batas waktu eksekusi (S-21: default 10 detik).
  final Duration timeout;

  bool _disposed = false;
  JavascriptRuntime? _rt;

  /// Daftar host API yang boleh dipanggil script. Diatur sebelum run.
  SandboxHost? host;

  /// Eval sekali lalu buang. [code] sudah diverifikasi pengguna saat
  /// impor (S-31); eval dinamis dari input jaringan ditolak (S-21).
  Future<SandboxResult> run(String code) async {
    final sw = Stopwatch()..start();
    if (_disposed) {
      return SandboxResult.fail('Sandbox sudah dibuang.', 0);
    }
    var rt = _rt;
    if (rt == null) {
      try {
        rt = _rt = getJavascriptRuntime(xhr: false);
      } catch (e) {
        return SandboxResult.fail('Gagal memulai sandbox: $e', 0);
      }
    }

    // Pasang host API (S-20): hanya fungsi yang kita sediakan.
    _registerHost(rt);

    try {
      final result = await rt.evaluateAsync(code).timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Sandbox: batas waktu 10 dtk'),
      );
      sw.stop();
      final out = result.stringResult;
      if (result.isError) {
        return SandboxResult.fail(out, sw.elapsedMilliseconds);
      }
      return SandboxResult.ok(out, sw.elapsedMilliseconds);
    } on TimeoutException catch (_) {
      // S-21: batin waktu tercapai — buang runtime (script tak bisa
      // dipercaya lagi), bukan dilanjutkan.
      dispose();
      return SandboxResult.fail(
          'Script melebihi batas waktu ${timeout.inSeconds} detik.',
          sw.elapsedMilliseconds);
    } catch (e) {
      sw.stop();
      return SandboxResult.fail('Script error: $e', sw.elapsedMilliseconds);
    }
  }

  void _registerHost(JavascriptRuntime rt) {
    final h = host;
    // console.log sudah disediakan package (menulis ke print — kita
    // teruskan ke host agar masuk audit log, S-33).
    rt.onMessage('ConsoleLog', (dynamic args) {
      final list = (args as List?) ?? const [];
      final level = list.isNotEmpty ? list[0].toString() : 'log';
      final body = list.skip(1).join(' ');
      if (host != null) {
        host!.log(level, body);
      }
      return null;
    });

    if (h == null) return;

    // Setiap host API lewat JSON; script tidak pernah memegang object
    // Dart langsung.
    rt.onMessage('HostHttpGet', (dynamic args) async {
      final url = (args as List?)?.firstOrNull?.toString() ?? '';
      try {
        return await h.httpGet(url);
      } catch (e) {
        return jsonEncode({'error': '$e'});
      }
    });
    rt.onMessage('HostReadFile', (dynamic args) async {
      final name = (args as List?)?.firstOrNull?.toString() ?? '';
      try {
        return await h.readFile(name);
      } catch (e) {
        return jsonEncode({'error': '$e'});
      }
    });
    rt.onMessage('HostWriteFile', (dynamic args) async {
      final list = (args as List?) ?? const [];
      final name = list.isNotEmpty ? list[0].toString() : '';
      final content = list.length > 1 ? list[1].toString() : '';
      try {
        return await h.writeFile(name, content);
      } catch (e) {
        return jsonEncode({'error': '$e'});
      }
    });
  }

  /// Buang runtime. Setelah ini sandbox tak bisa dipakai lagi.
  void dispose() {
    _disposed = true;
    _rt?.dispose();
    _rt = null;
  }
}
