import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../../../core/llm/anthropic.dart';
import '../../../core/llm/openai_compat.dart';
import '../../../core/llm/provider.dart';
import '../provider_config.dart';

/// Create or edit a provider connection (blueprint wireframe C).
///
/// Implements: multi-profile, base URL + API key, Test Connection, Fetch
/// Models, manual model input, HTTPS/loopback URL validation (rule S-10),
/// key always masked (rule 5.1 / S-01).
class ProviderFormPage extends ConsumerStatefulWidget {
  const ProviderFormPage({super.key, this.existing});

  final ProviderProfile? existing;

  @override
  ConsumerState<ProviderFormPage> createState() => _ProviderFormPageState();
}

class _ProviderFormPageState extends ConsumerState<ProviderFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _baseUrl;
  late final TextEditingController _apiKey;
  late final TextEditingController _model;
  late final TextEditingController _budget;
  late final TextEditingController _maxTokens;

  ProviderType _type = ProviderType.openaiCompatible;
  double _temperature = 0.2;
  bool _testing = false;
  bool _fetching = false;
  String? _testMessage;
  bool _testOk = false;
  List<ModelInfo> _models = <ModelInfo>[];

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _baseUrl = TextEditingController(text: p?.baseUrl ?? 'https://api.openai.com/v1');
    _apiKey = TextEditingController();
    _model = TextEditingController(text: p?.model ?? '');
    _budget = TextEditingController(text: (p?.dailyBudgetUsd ?? 5).toStringAsFixed(2));
    _maxTokens = TextEditingController(text: (p?.maxTokens ?? 4096).toString());
    _type = p?.type ?? ProviderType.openaiCompatible;
    _temperature = p?.temperature ?? 0.2;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _baseUrl,
      _apiKey,
      _model,
      _budget,
      _maxTokens,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Validates the base URL (rule S-10): HTTPS required, plain HTTP only
  /// for loopback / LAN with an explicit warning.
  String? _validateBaseUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return 'Base URL wajib diisi.';
    Uri parsed;
    try {
      parsed = Uri.parse(url);
    } catch (_) {
      return 'URL tidak valid.';
    }
    if (!parsed.hasScheme || parsed.host.isEmpty) {
      return 'URL tidak valid.';
    }
    if (parsed.scheme == 'http') {
      final host = parsed.host;
      final isLoopback = host == 'localhost' ||
          host.startsWith('127.') ||
          host.startsWith('192.168.') ||
          host.startsWith('10.');
      if (!isLoopback) {
        return 'HTTP hanya diizinkan untuk localhost/LAN (aturan S-10).';
      }
      return null; // Loopback diperbolehkan untuk provider lokal.
    }
    if (parsed.scheme != 'https') {
      return 'Hanya http/https yang didukung.';
    }
    return null;
  }

  String? _validateModel(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Model default wajib diisi.';
    return null;
  }

  Future<LlmProvider> _buildAdapter() async {
    final profile = _currentProfile();
    final key = widget.existing != null
        ? await ref
                .read(providerConfigProvider.notifier)
                .apiKeyFor(widget.existing!.id) ??
            _apiKey.text.trim()
        : _apiKey.text.trim();
    final timeout = Duration(seconds: profile.timeoutSeconds);
    switch (_type) {
      case ProviderType.openaiCompatible:
        return OpenAiCompatibleProvider(
          baseUrl: profile.baseUrl,
          apiKey: key,
          timeout: timeout,
        );
      case ProviderType.anthropic:
        return AnthropicProvider(
          baseUrl: profile.baseUrl,
          apiKey: key,
          timeout: timeout,
        );
    }
  }

  ProviderProfile _currentProfile() => ProviderProfile(
        id: widget.existing?.id ??
            'prov-${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim().isEmpty
            ? 'Provider'
            : _name.text.trim(),
        type: _type,
        baseUrl: _baseUrl.text.trim(),
        model: _model.text.trim(),
        temperature: _temperature,
        maxTokens: int.tryParse(_maxTokens.text.trim()) ?? 4096,
        dailyBudgetUsd: double.tryParse(_budget.text.trim()) ?? 5.0,
        timeoutSeconds: 60,
        retries: 2,
        isPrimary: widget.existing?.isPrimary ?? false,
      );

  Future<void> _testConnection() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _testing = true;
      _testMessage = null;
    });
    try {
      final adapter = await _buildAdapter();
      final sw = Stopwatch()..start();
      final ok = await adapter.testConnection();
      sw.stop();
      _testOk = ok;
      _testMessage = ok
          ? 'Uji koneksi berhasil · ${sw.elapsedMilliseconds} ms'
          : 'Uji koneksi gagal. Periksa base URL dan API key.';
    } catch (e) {
      _testOk = false;
      _testMessage = 'Uji koneksi gagal: $e';
    }
    if (mounted) {
      setState(() => _testing = false);
    }
  }

  Future<void> _fetchModels() async {
    setState(() => _fetching = true);
    try {
      final adapter = await _buildAdapter();
      _models = await adapter.listModels();
      if (_models.isEmpty) {
        _testMessage =
            'Endpoint /models tidak tersedia. Masukkan nama model manual.';
        _testOk = false;
      } else {
        _testMessage = '${_models.length} model ditemukan.';
        _testOk = true;
      }
    } catch (e) {
      _testOk = false;
      _testMessage = 'Gagal mengambil model: $e';
    }
    if (mounted) {
      setState(() => _fetching = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(providerConfigProvider.notifier);
    await notifier.saveProfile(
      _currentProfile(),
      apiKey: _apiKey.text.trim().isEmpty ? null : _apiKey.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(widget.existing == null
            ? 'Tambah provider'
            : 'Kelola koneksi'),
        backgroundColor: colors.background,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.gridGap),
          children: [
            _field(context, 'Nama koneksi', _name, 'OpenAI · Pribadi'),
            const SizedBox(height: 16),
            _typeSelector(context),
            const SizedBox(height: 16),
            _field(
              context,
              'Base URL',
              _baseUrl,
              'https://api.openai.com/v1',
              validator: _validateBaseUrl,
              hint: 'Gunakan HTTPS. Endpoint harus mendukung /chat/completions.',
            ),
            const SizedBox(height: 16),
            _apiKeyField(context),
            const SizedBox(height: 16),
            _modelField(context),
            const SizedBox(height: 16),
            _sliderRow(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _field(
                    context,
                    'Anggaran harian (USD)',
                    _budget,
                    '5.00',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    context,
                    'Batas token / task',
                    _maxTokens,
                    '4096',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_testMessage != null) ...[
              _testBanner(context),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                OutlinedButton(
                  onPressed: _testing ? null : _testConnection,
                  child: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Uji koneksi'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _fetching ? null : _fetchModels,
                  child: _fetching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Fetch Models'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan konfigurasi'),
            ),
            const SizedBox(height: 8),
            Text(
              'Provider kustom menerima isi prompt Anda. Jangan sertakan '
              'seed phrase, API key, atau data sensitif.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller,
    String placeholder, {
    String? Function(String?)? validator,
    String? hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: suffix,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _typeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jenis provider', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ProviderType>(
          segments: [
            ButtonSegment(
              value: ProviderType.openaiCompatible,
              label: Text(ProviderType.openaiCompatible.label),
            ),
            ButtonSegment(
              value: ProviderType.anthropic,
              label: Text(ProviderType.anthropic.label),
            ),
          ],
          selected: <ProviderType>{_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
      ],
    );
  }

  Widget _apiKeyField(BuildContext context) {
    return _field(
      context,
      'API key',
      _apiKey,
      'sk-…',
      obscure: true,
      hint: 'Terenkripsi saat disimpan. Tidak pernah ditampilkan di log '
          'atau dibagikan ke model.',
      suffix: IconButton(
        icon: const Icon(Icons.paste_outlined, size: 18),
        tooltip: 'Tempel dari clipboard',
        onPressed: () async {
          // Clipboard read is a confirmed action (rule S-06 / 5.3).
          final clipboard = await Clipboard.getData('text/plain');
          if (clipboard?.text != null && clipboard!.text!.isNotEmpty) {
            _apiKey.text = clipboard.text!;
            // S-06: the clipboard held a secret — wipe it after 30 s so it
            // cannot be pasted into another app.
            Timer(const Duration(seconds: 30), () {
              Clipboard.setData(const ClipboardData(text: ''));
            });
            if (mounted) setState(() {});
          }
        },
      ),
    );
  }

  Widget _modelField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Model default', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _model,
          validator: _validateModel,
          decoration: InputDecoration(
            hintText: 'gpt-4.1',
            suffixIcon: _models.isNotEmpty
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (v) => setState(() => _model.text = v),
                    itemBuilder: (_) => [
                      for (final m in _models)
                        PopupMenuItem<String>(value: m.id, child: Text(m.label)),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Jika endpoint /models tidak tersedia, masukkan nama model manual.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _sliderRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Temperature',
                style: Theme.of(context).textTheme.titleMedium),
            Text(_temperature.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Slider(
          value: _temperature,
          min: 0,
          max: 2,
          divisions: 20,
          activeColor: DesignTokens.accent,
          onChanged: (v) => setState(() => _temperature = v),
        ),
        Text(
          'Nilai rendah disarankan untuk pemanggilan tools.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _testBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _testOk ? const Color(0x213FB950) : const Color(0x33F85149),
        borderRadius: const BorderRadius.all(
          Radius.circular(DesignTokens.radius),
        ),
        border: Border.all(
          color: _testOk ? DesignTokens.success : DesignTokens.danger,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _testOk ? Icons.check_circle : Icons.error,
            color: _testOk ? DesignTokens.success : DesignTokens.danger,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _testMessage ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
