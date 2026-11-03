import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/audit/audit_logger.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/auth/supabase_config.dart';
import 'core/security/bip39_wordlist.dart';
import 'data/database/app_database.dart';
import 'data/repositories/crypto_repository.dart';
import 'data/repositories/task_repository.dart';
import 'features/task/task_providers.dart';
import 'features/wallet/wallet_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // P-01: paste error stack, ErrorsOnly.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrintStack(
      stackTrace: details.stack,
      label: details.exception.toString(),
    );
  };

  // Warm the BIP-39 wordlist so the first [Redactor.redact] call can scan
  // for seed phrases. Redaction falls back safely if this fails.
  Bip39Wordlist.load().catchError((Object _) {});

  // Fase 1B: init Supabase auth. Kegagalan tidak memblokir app (8B.1:
  // akun bersifat opsional, A-17: tidak ada login wall).
  AuthService? authService;
  try {
    await initSupabase();
    authService = SupabaseAuthService();
  } catch (_) {
    // auth opsional; UI akan menampilkan error generik saat dipakai.
  }

  // Fase 6: task scheduler + Fase 7: wallet watcher. Satu instance
  // AppDatabase dipakai bersama (WAL aman untuk konkurensi baca).
  final db = AppDatabase();
  final auditPath =
      '${(await getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}audit.log';

  runApp(
    ProviderScope(
      overrides: [
        if (authService != null)
          authServiceProxyProvider.overrideWithValue(authService),
        auditLoggerProvider.overrideWithValue(AuditLogger(auditPath)),
        taskNotifierProvider.overrideWith((ref) {
          final notifier = TaskNotifier(
            TaskRepository(db),
            ref.read(auditLoggerProvider),
          );
          notifier.init();
          return notifier;
        }),
        walletNotifierProvider.overrideWith((ref) {
          final audit = ref.read(auditLoggerProvider);
          return WalletNotifier(CryptoRepository(db), audit);
        }),
      ],
      child: const SuperagentApp(),
    ),
  );
}
