import 'package:flutter/material.dart';

/// Layar sambutan pertama kali dibuka (8B.5 langkah 1):
/// pilih Masuk, Daftar, atau "Lanjut tanpa akun".
///
/// A-17: tidak ada login wall — app berfungsi penuh tanpa akun.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _heroIcon = Icons.smart_toy_rounded;
  static const _tagline = 'Agent serbaguna di perangkatmu';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Branding.
                  Icon(_heroIcon, size: 72, color: colors.primary),
                  const SizedBox(height: 16),
                  Text('Superagent',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_tagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Lokal · Aman · Ringan',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant)),

                  const SizedBox(height: 48),

                  // Masuk.
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Masuk'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  const SizedBox(height: 12),

                  // Daftar.
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/signup'),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Daftar'),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  const SizedBox(height: 12),

                  // Lanjut tanpa akun (A-17).
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/home'),
                    child: const Text('Lanjut tanpa akun →'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
