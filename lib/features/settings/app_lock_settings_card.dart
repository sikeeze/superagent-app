import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/security/app_lock_manager.dart';

/// Kartu pengaturan kunci aplikasi (6.8) di SettingsPage.
class AppLockSettingsCard extends StatefulWidget {
  const AppLockSettingsCard({super.key, required this.manager});

  final AppLockManager manager;

  @override
  State<AppLockSettingsCard> createState() => _AppLockSettingsCardState();
}

class _AppLockSettingsCardState extends State<AppLockSettingsCard> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = widget.manager.autoLockMinutes;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleLock() async {
    final m = widget.manager;
    if (m.isEnabled) {
      final pin = await _askPin('Masukkan PIN untuk menonaktifkan kunci');
      if (pin == null) return;
      try {
        await m.disable(pin);
      } on AppLockException catch (e) {
        _snack(e.message);
      }
    } else {
      final pin = await _askPin('Buat PIN (4-8 digit angka)');
      if (pin == null) return;
      try {
        await m.enable(pin);
        _snack('Kunci aplikasi diaktifkan.');
      } on AppLockException catch (e) {
        _snack(e.message);
      }
    }
    _refresh();
  }

  Future<String?> _askPin(String title) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    final m = widget.manager;
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Kunci aplikasi', style: TextStyle(fontSize: 13)),
          subtitle: Text(
            m.isEnabled
                ? 'Aktif · auto-lock ${m.autoLockMinutes} menit'
                : 'Nonaktif',
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
          value: m.isEnabled,
          onChanged: (_) => _toggleLock(),
        ),
        if (m.isEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('Auto-lock (menit)',
                    style: TextStyle(
                        fontSize: 12, color: colors.textSecondary)),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 30,
                    divisions: 29,
                    value: _minutes.toDouble(),
                    label: '$_minutes',
                    onChanged: (v) =>
                        setState(() => _minutes = v.round()),
                    onChangeEnd: (v) => m.setAutoLockMinutes(v.round()),
                  ),
                ),
                Text('$_minutes',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  m.lock();
                  _snack('Aplikasi terkunci.');
                },
                icon: const Icon(Icons.lock, size: 16),
                label: const Text('Kunci sekarang'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
