import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../core/security/app_lock_manager.dart';

/// Layar kunci aplikasi (blueprint 6.8).
///
/// Ditampilkan di atas app saat [AppLockManager.isLocked] true. Pengguna
/// memasukkan PIN; percobaan gagal menampilkan sisa waktu backoff.
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    required this.manager,
    required this.onUnlocked,
  });

  final AppLockManager manager;
  final VoidCallback onUnlocked;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _input = StringBuffer();
  String? _err;
  bool _busy = false;

  void _press(String digit) {
    if (_busy || _input.length >= 8) return;
    setState(() {
      _input.write(digit);
      _err = null;
    });
    if (_input.length == 4) {
      _tryUnlock();
    }
  }

  Future<void> _tryUnlock() async {
    setState(() => _busy = true);
    try {
      final ok = await widget.manager.unlock(_input.toString());
      if (!ok) {
        final remaining = widget.manager.backoffRemaining();
        setState(() {
          _err = remaining > 0
              ? 'PIN salah. Coba lagi dalam ${remaining}s.'
              : 'PIN salah. Percobaan ${widget.manager.failedAttempts}.';
          _input.clear();
        });
      } else {
        widget.onUnlocked();
      }
    } on AppLockException catch (e) {
      setState(() {
        _err = e.message;
        _input.clear();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() {
      _input.writeCharCode(0x08); // dummy
    });
    // Hapus 1 char terakhir dengan benar.
    final s = _input.toString();
    _input.clear();
    _input.write(s.substring(0, s.length - 1 <= 0 ? 0 : s.length - 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 40, color: colors.textSecondary),
              const SizedBox(height: DesignTokens.gridGap),
              Text('Superagent terkunci',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary)),
              const SizedBox(height: 24),
              // Indikator digit.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _input.toString().length;
                  return Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? DesignTokens.accent : colors.surface,
                      border: Border.all(color: DesignTokens.accent, width: 1.5),
                    ),
                  );
                }),
              ),
              if (_err != null) ...[
                const SizedBox(height: 12),
                Text(_err!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12)),
              ],
              const SizedBox(height: 24),
              // Keypad 3x4.
              for (final row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', '⌫'],
              ])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final d in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: d.isEmpty
                              ? const SizedBox(height: 56)
                              : InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: _busy
                                      ? null
                                      : () => d == '⌫'
                                          ? _backspace()
                                          : _press(d),
                                  child: Container(
                                    height: 56,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.surface,
                                      border: Border.all(
                                          color: DesignTokens.accent, width: 1),
                                    ),
                                    child: Text(d,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: colors.textPrimary)),
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
