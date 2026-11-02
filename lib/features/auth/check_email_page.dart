import 'package:flutter/material.dart';

/// Layar "Cek email kamu" (8B.5 langkah 2 & 8B.6): setelah daftar email,
/// pengguna diverifikasi lewat tautan yang kembali ke app via deep link.
class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.mark_email_read_outlined,
                      size: 64, color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cek email kamu',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami mengirim tautan verifikasi ke $email. '
                    'Buka tautannya untuk mengaktifkan akunmu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _openMail(context),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Buka aplikasi email'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                    child: const Text('Kembali ke Masuk'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak menerima email? Cek folder spam, atau tunggu '
                    'beberapa saat dan kirim ulang dari layar Masuk.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Membuka aplikasi email mailto: (launcher tersedia di Fase selanjutnya;
  // untuk sekarang arahkan pengguna manual).
  void _openMail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buka aplikasi email kamu secara manual.')),
    );
  }
}
