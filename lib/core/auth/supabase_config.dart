import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../security/secure_store.dart';

/// Inisialisasi klien Supabase (Fase 1B, Bagian 8B).
///
/// Hanya kunci publishable/anon yang dipakai (aturan A-10) — service-role
/// key TIDAK PERNAH ada di aplikasi atau repositori.
///
/// Sesi disimpan di secure storage OS (A-05): persistensi default
/// Supabase (SharedPreferences) dinonaktifkan dan sesi dipulihkan sendiri
/// dari secure storage pada start, sehingga token tidak pernah mendarat
/// di file biasa.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
    debug: kDebugMode,
    authOptions: const FlutterAuthClientOptions(
      // A-02: PKCE wajib untuk semua alur OAuth.
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
      // A-05: matikan persistensi default (SharedPreferences/file biasa).
      localStorage: EmptyLocalStorage(),
    ),
  );

  // A-17: pulihkan sesi dari secure storage; tetap valid offline.
  await _restoreSession();
}

/// URL project Supabase (publik, aman dibagikan).
const supabaseUrl = 'https://swvokwnijcmfanbeqjqb.supabase.co';

/// Kunci publishable/anon (aturan A-10). Bukan service-role key.
const supabasePublishableKey =
    'sb_publishable_KzzIzPlHEjRDRIuQIMu5Zw_tg7WqzV-';

/// Serialisasi sesi untuk disimpan di secure storage (A-05).
String sessionToJson(Session session) => jsonEncode(session.toJson());

/// Simpan sesi ke secure storage (A-05).
Future<void> _persistSession(String sessionJson) async {
  final store = SecureStore();
  await store.write(SecureKeys.authPersisted, sessionJson);
}

/// Hapus sesi dari secure storage.
Future<void> _clearPersistedSession() async {
  final store = SecureStore();
  await store.delete(SecureKeys.authPersisted);
}

/// Pulihkan sesi dari secure storage (A-05, A-17). Sesi rusak/expired
/// dihapus — pengguna diminta login ulang.
Future<void> _restoreSession() async {
  try {
    final store = SecureStore();
    final raw = await store.read(SecureKeys.authPersisted);
    if (raw == null || raw.isEmpty) return;
    await Supabase.instance.client.auth.recoverSession(raw);
  } catch (_) {
    await _clearPersistedSession();
  }
}

/// Singkatan akses klien.
SupabaseClient get supabase => Supabase.instance.client;

/// Status autentikasi (Fase 1B).
/// - isLoading false pada start, baik online maupun offline (A-17)
/// - session null = belum login; app tetap berfungsi penuh (8B.1).
class AppAuthState {
  const AppAuthState({this.session, this.isLoading = false});

  final Session? session;
  final bool isLoading;

  bool get isLoggedIn => session != null;
  String? get userId => session?.user.id;
  String? get userEmail => session?.user.email;
  String? get userName =>
      session?.user.userMetadata?['full_name'] as String? ??
      session?.user.userMetadata?['name'] as String?;
}

/// Notifier status auth: mendengarkan perubahan sesi Supabase dan
/// mempersistenkannya ke secure storage (A-05).
class AuthNotifier extends StateNotifier<AppAuthState> {
  AuthNotifier() : super(const AppAuthState()) {
    _sub = supabase.auth.onAuthStateChange.listen((event) {
      final s = event.session;
      if (s != null) {
        _persistSession(sessionToJson(s));
      } else {
        _clearPersistedSession();
      }
      state = AppAuthState(session: s);
    });
    // Sesi awal dari memory (sudah dipulihkan saat init).
    state = AppAuthState(session: supabase.auth.currentSession);
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier();
});
