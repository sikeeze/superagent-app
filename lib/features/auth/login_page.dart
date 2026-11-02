import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';

/// Layar masuk (8B.6): Google & GitHub sebagai tombol utama, email
/// sebagai opsi di bawahnya. Enter untuk kirim, Tab urutan logis.
///
/// A-01: OAuth hanya lewat browser sistem. A-07: pesan error generik.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _resetSent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  AuthService _auth() => ref.read(authServiceProxyProvider);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth().signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.ok) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _error = res.error);
    }
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

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Isi email dulu untuk kirim tautan reset.');
      return;
    }
    final res = await _auth().sendPasswordReset(email: email);
    if (!mounted) return;
    setState(() {
      _resetSent = res.ok;
      _error = res.error;
    });
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

  // Panel kiri branding (Windows, 8B.6): tiga poin nilai.
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
              _valuePoint(colors, Icons.offline_bolt_rounded, 'Lokal',
                  'Data, kunci, dan log tersimpan di perangkatmu.'),
              const SizedBox(height: 16),
              _valuePoint(colors, Icons.lock_rounded, 'Aman',
                  'Token di secure storage. Login tidak membuka Vault.'),
              const SizedBox(height: 16),
              _valuePoint(colors, Icons.bolt_rounded, 'Ringan',
                  'Fitur berat dimuat lazy, jejak RAM kecil.'),
            ],
          ),
        ),
      );

  Widget _valuePoint(
          ColorScheme colors, IconData icon, String title, String body) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(body),
              ],
            ),
          ),
        ],
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
                    'Masuk',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // A-01: OAuth lewat browser sistem.
                  FilledButton.icon(
                    onPressed: _loading ? null : _google,
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: const Text('Lanjutkan dengan Google'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _github,
                    icon: const Icon(Icons.code_rounded),
                    label: const Text('Lanjutkan dengan GitHub'),
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
                      labelText: 'Password',
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password wajib diisi.' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(color: colors.error, fontSize: 13)),
                  ],
                  if (_resetSent) ...[
                    const SizedBox(height: 12),
                    Text('Tautan reset dikirim. Cek email kamu.',
                        style: TextStyle(color: colors.primary, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text('Lupa password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? '),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/signup'),
                        child: const Text('Daftar'),
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
                    'Dengan masuk, kamu setuju Ketentuan & Privasi.',
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

String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email wajib diisi.';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Format email tidak valid.';
}
