import 'package:flutter/material.dart';

import '../../core/security/config_vault.dart';
import '../../core/services/config_export_service.dart';

/// Dialog ekspor & impor konfigurasi terenkripsi (S-04).
class ExportImportDialogs {
  ExportImportDialogs._();

  static Future<void> showExport(
      BuildContext context, ConfigExportService service) async {
    final res = await showDialog<String>(
      context: context,
      builder: (_) => _ExportDialog(service: service),
    );
    if (res == 'ok' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfigurasi berhasil diekspor.')),
      );
    }
  }

  static Future<void> showImport(
      BuildContext context, ConfigExportService service) async {
    final res = await showDialog<int>(
      context: context,
      builder: (_) => _ImportDialog(service: service),
    );
    if (res != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$res profil provider dipulihkan.')),
      );
    }
  }
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.service});
  final ConfigExportService service;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _pass = TextEditingController();
  final _path = TextEditingController();
  String? _err;
  bool _busy = false;

  @override
  void dispose() {
    _pass.dispose();
    _path.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ekspor konfigurasi (S-04)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Profil provider + API key diekspor terenkripsi '
            'AES-256-GCM (PBKDF2 200rb iterasi). Simpan file di luar '
            'repositori.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _path,
            decoration: const InputDecoration(
              labelText: 'Path file tujuan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pass,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Passphrase (min 8 karakter)',
              border: OutlineInputBorder(),
            ),
          ),
          if (_err != null) ...[
            const SizedBox(height: 8),
            Text(_err!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _busy ? null : _doExport,
          child: const Text('Ekspor'),
        ),
      ],
    );
  }

  Future<void> _doExport() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await widget.service.exportToFile(_path.text, _pass.text);
      if (mounted) Navigator.pop(context, 'ok');
    } on ConfigVaultException catch (e) {
      setState(() => _err = e.message);
    } catch (e) {
      setState(() => _err = 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.service});
  final ConfigExportService service;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _pass = TextEditingController();
  final _path = TextEditingController();
  String? _err;
  bool _busy = false;

  @override
  void dispose() {
    _pass.dispose();
    _path.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Impor konfigurasi (S-04)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Impor file export terenkripsi. Profil dengan id yang sama '
            'akan ditimpa. Passphrase harus sama dengan saat ekspor.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _path,
            decoration: const InputDecoration(
              labelText: 'Path file export',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pass,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Passphrase',
              border: OutlineInputBorder(),
            ),
          ),
          if (_err != null) ...[
            const SizedBox(height: 8),
            Text(_err!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _busy ? null : _doImport,
          child: const Text('Impor'),
        ),
      ],
    );
  }

  Future<void> _doImport() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final n = await widget.service.importFromFile(_path.text, _pass.text);
      if (mounted) Navigator.pop(context, n);
    } on ConfigVaultException catch (e) {
      setState(() => _err = e.message);
    } catch (e) {
      setState(() => _err = 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
