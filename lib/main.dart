import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/supabase_auth_service.dart';
import 'core/auth/supabase_config.dart';
import 'core/security/bip39_wordlist.dart';

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

  runApp(
    ProviderScope(
      overrides: [
        if (authService != null)
          authServiceProxyProvider.overrideWithValue(authService),
      ],
      child: const SuperagentApp(),
    ),
  );
}
