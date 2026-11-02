import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/check_email_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/welcome_page.dart';
import 'app_shell.dart';
import 'theme.dart';

/// Widget akar aplikasi (Fase 1B).
///
/// Mengatur rute named untuk alur auth (8B.5): Welcome -> Login/Signup ->
/// Home. A-17: tidak ada login wall — /home tetap dapat ditempuh tanpa
/// akun. Implementasi AuthService dipasang via override ProviderScope
/// di main() setelah initSupabase() selesai.
class SuperagentApp extends ConsumerWidget {
  const SuperagentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Superagent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(context),
      darkTheme: AppTheme.dark(context),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
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
