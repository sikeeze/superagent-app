import 'package:flutter/foundation.dart';

/// Notifikasi lokal (blueprint 5.5).
///
/// **Fase 6 (sementara):** implementasi plugin (`flutter_local_notifications`)
/// tidak bisa dikompilasi AOT bersama MSVC 14.51 (gen_snapshot crash). Versi
/// ini menulis ke debug log; tampilan toast akan dihidupkan kembali di Fase 8
/// setelah toolchain konsisten. Saluran logika (task/confirm/error) tetap.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  void Function(String? payload)? onTapNotification;

  Future<void> init() async {}

  Future<void> ensureChannels() async {}

  Future<void> notifyTaskDone(int taskId, String title) {
    debugPrint('[notif:task] #$taskId selesai: $title');
    return Future.value();
  }

  Future<void> notifyTaskFailed(int taskId, String title, String error) {
    debugPrint('[notif:error] #$taskId gagal: $title — $error');
    return Future.value();
  }

  Future<void> notifyNeedsConfirmation(int taskId, String title) {
    debugPrint('[notif:confirm] #$taskId butuh konfirmasi: $title');
    return Future.value();
  }
}
