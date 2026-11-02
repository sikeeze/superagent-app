import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';

/// Layar daftar (8B.5 langkah 2, 8B.6).
///
/// A-07: password minimal 12 karakter + indikator kekuatan; pesan error
/// generik. Verifikasi email wajib sebelum akun aktif.
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  AuthService _auth() => ref.read(authServiceProxyProvider);

  // A-07: minimal 12 karakter.
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi.';
    if (v.length < 12) return 'Password minimal 12 karakter.';
    return null;
  }

  // Indikator kekuatan sederhana (A-07).
  PasswordStrength _strength(String v) {
    int score = 0;
    if (v.length >= 12) score++;
    if (v.length >= 16) score++;
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    if (score < 2) return PasswordStrength.weak;
    if (score < 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth().signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.needEmailVerify) {
      // 8B.5 langkah 2: arahkan ke layar "Cek email kamu".
      Navigator.of(context).pushReplacementNamed('/check-email',
          arguments: _emailCtrl.text.trim());
    } else if (res.ok) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _error = res.error);
    }
  }

  // Indikator kekuatan password (A-07).
  Widget _strengthIndicator(ColorScheme colors) {
    final s = _strength(_passwordCtrl.text);
    const labels = {
      PasswordStrength.weak: 'Lemah',
      PasswordStrength.medium: 'Sedang',
      PasswordStrength.strong: 'Kuat',
    };
    const counts = {
      PasswordStrength.weak: 1,
      PasswordStrength.medium: 2,
      PasswordStrength.strong: 3,
    };
    final color = switch (s) {
      PasswordStrength.weak => colors.error,
      PasswordStrength.medium => Colors.orange,
      PasswordStrength.strong => Colors.green,
    };
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(3, (i) {
              final filled = i < counts[s]!;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? color : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(labels[s]!,
            style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
  Future<void> _google() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth().signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.ok) Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _github() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth().signInWithGitHub();
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.ok) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final twoPanel = width >= 900;

    return Scaffold(
      body: SafeArea(
        child: twoPanel
            ? Row(
                children: [
                  _branding(theme, colors),
                  Expanded(child: _formCard(theme, colors)),
                ],
              )
            : Center(child: _formCard(theme, colors)),
      ),
    );
  }

  // Panel kiri branding (Windows, 8B.6).
  Widget _branding(ThemeData theme, ColorScheme colors) => Expanded(
        child: Container(
          color: colors.primaryContainer,
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.smart_toy_rounded, size: 64, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Superagent',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'Buat akun untuk sinkronkan pengaturan antar perangkat. '
                'Data kamu tetap lokal; rahasia tidak pernah dikirim ke cloud.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
  Widget _formCard(ThemeData theme, ColorScheme colors) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Daftar',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // A-01: OAuth lewat browser sistem.
                  FilledButton.icon(
                    onPressed: _loading ? null : _google,
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: const Text('Daftar dengan Google'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _github,
                    icon: const Icon(Icons.code_rounded),
                    label: const Text('Daftar dengan GitHub'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Text(' atau ',
                            style:
                                TextStyle(color: colors.onSurfaceVariant)),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'nama@email.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password (minimal 12 karakter)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: _validatePassword,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  // A-07: indikator kekuatan password.
                  if (_passwordCtrl.text.isNotEmpty)
                    _strengthIndicator(colors),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(color: colors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Daftar'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? '),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/login'),
                        child: const Text('Masuk'),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/home'),
                    child: const Text('Lanjut tanpa akun →'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dengan mendaftar, kamu setuju Ketentuan & Privasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

enum PasswordStrength { weak, medium, strong }

String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email wajib diisi.';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Format email tidak valid.';
}
