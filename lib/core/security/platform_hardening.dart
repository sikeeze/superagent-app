import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Menerapkan rules keamanan platform tingkat UI.
///
/// - **S-05:** `FLAG_SECURE` di Android untuk layar yang menampilkan
///   kunci/token, agar tidak muncul di screenshot, screen recorder,
///   atau thumbnail recent apps. No-op di luar Android.
class PlatformHardening {
  static const _channel = MethodChannel('com.superagent.superagent/security');

  /// Aktifkan FLAG_SECURE pada activity Android (S-05).
  /// No-op di Windows/iOS.
  static Future<void> setFlagSecure(bool enabled) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setFlagSecure', <String, dynamic>{
        'enabled': enabled,
      });
    } on PlatformException {
      // Channel belum terdaftar (mis. di luar Android) — aman diabaikan.
    }
  }
}
