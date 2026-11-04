import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/app_lock_manager.dart';
import '../../core/security/secure_store.dart';

/// Manager kunci aplikasi (6.8). Override instance-nya di main() dengan
/// AppLockManager yang sudah di-load().
final appLockManagerProvider = Provider<AppLockManager>((ref) {
  throw UnimplementedError('override di main()');
});

/// State notifier sederhana: UI menonton ini untuk tahu kapan layar kunci
/// harus muncul. Update dipicu AppLockManager (lock/unlock).
final appLockStateProvider = StateNotifierProvider<AppLockNotifier, bool>(
  (ref) => AppLockNotifier(),
);

class AppLockNotifier extends StateNotifier<bool> {
  AppLockNotifier() : super(false);

  /// Tampilkan layar kunci (dipicu AppLockManager.lock() atau startup).
  void show() => state = true;

  /// Sembunyikan layar kunci (PIN benar).
  void hide() => state = false;
}

/// Helper: init manager di main() lalu sinkronkan state awal.
Future<AppLockManager> initAppLock() async {
  final manager = AppLockManager(SecureStore());
  await manager.load();
  return manager;
}
