import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/check_email_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/welcome_page.dart';
import '../features/settings/app_lock_providers.dart';
import '../features/settings/app_lock_screen.dart';
import '../core/security/app_lock_manager.dart';
import 'app_shell.dart';
import 'theme.dart';

/// Widget akar aplikasi (Fase 1B).
///
/// Mengatur rute named untuk alur auth (8B.5): Welcome -> Login/Signup ->
/// Home. A-17: tidak ada login wall — /home tetap dapat ditempuh tanpa
/// akun. Implementasi AuthService dipasang via override ProviderScope
/// di main() setelah initSupabase() selesai.
class SuperagentApp extends ConsumerStatefulWidget {
  const SuperagentApp({super.key});

  @override
  ConsumerState<SuperagentApp> createState() => _SuperagentAppState();
}

/// Fase 11 (6.8): pantau aktivitas pengguna untuk reset timer auto-lock.
class _SuperagentAppState extends ConsumerState<SuperagentApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 6.8: kunci saat app masuk background (pengguna meninggalkan app).
    final manager = ref.read(appLockManagerProvider);
    if (state == AppLifecycleState.paused && manager.isEnabled) {
      manager.lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockStateProvider);
    return MaterialApp(
      title: 'Superagent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(context),
      darkTheme: AppTheme.dark(context),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
      // 6.8: layar kunci menutupi seluruh app bila aktif. Dipasang via
      // builder (di atas Navigator) supaya tidak bentrok initialRoute.
      builder: (context, child) {
        if (!locked) {
          // Reset timer auto-lock pada interaksi pengguna (6.8).
          return _ActivityReporter(
            manager: ref.read(appLockManagerProvider),
            child: child ?? const SizedBox.shrink(),
          );
        }
        return AppLockScreen(
          manager: ref.read(appLockManagerProvider),
          onUnlocked: () {
            ref.read(appLockStateProvider.notifier).hide();
          },
        );
      },
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fade(const WelcomePage(), settings);
      case '/login':
        return _fade(const LoginPage(), settings);
      case '/signup':
        return _fade(const SignupPage(), settings);
      case '/check-email':
        final email = settings.arguments as String? ?? '';
        return _fade(CheckEmailPage(email: email), settings);
      case '/home':
        return _fade(const AppShell(), settings);
      default:
        return _fade(const WelcomePage(), settings);
    }
  }

  // Transisi fade-slide halus (8B.6 "Motion dan popup").
  Route<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}

/// 6.8: laporkan setiap pointer down ke [AppLockManager.reportUserActivity]
/// untuk mereset timer auto-lock.
class _ActivityReporter extends StatelessWidget {
  const _ActivityReporter({required this.manager, required this.child});

  final AppLockManager manager;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => manager.reportUserActivity(),
      onPointerSignal: (_) => manager.reportUserActivity(),
      child: child,
    );
  }
}
