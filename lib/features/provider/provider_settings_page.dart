import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_tokens.dart';
import '../../app/theme.dart';
import '../../core/llm/provider.dart';
import 'provider_config.dart';
import 'widgets/provider_form.dart';

/// Provider AI screen (blueprint wireframe C, design PDF "Provider AI").
///
/// Lists every saved connection, lets the user add or edit one, test the
/// connection and fetch the model catalogue. API keys are only ever read
/// from the keychain, never displayed in full (rule S-01).
class ProviderSettingsPage extends ConsumerStatefulWidget {
  const ProviderSettingsPage({super.key});

  @override
  ConsumerState<ProviderSettingsPage> createState() =>
      _ProviderSettingsPageState();
}

class _ProviderSettingsPageState extends ConsumerState<ProviderSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load metadata once on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerConfigProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerConfigProvider);
    final colors = appColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Provider AI'),
        backgroundColor: colors.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        backgroundColor: DesignTokens.accent,
        foregroundColor: const Color(0xFF0D0F12),
        icon: const Icon(Icons.add),
        label: const Text('Tambah provider'),
      ),
      body: state.profiles.isEmpty
          ? _EmptyState(onAdd: () => _openForm(context, null))
          : ListView.separated(
              // P-01: builder-style lazy list.
              padding: const EdgeInsets.all(DesignTokens.gridGap),
              itemCount: state.profiles.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: DesignTokens.gridGap),
              itemBuilder: (context, i) {
                final p = state.profiles[i];
                return _ProviderTile(profile: p);
              },
            ),
    );
  }

  void _openForm(BuildContext context, ProviderProfile? existing) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProviderFormPage(existing: existing),
      ),
    );
  }
}

class _ProviderTile extends ConsumerWidget {
  const _ProviderTile({required this.profile});

  final ProviderProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.all(DesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(DesignTokens.radius),
        ),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.baseUrl,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (profile.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: DesignTokens.accentDim,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(DesignTokens.radiusSm),
                    ),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusPill2(label: profile.type.label),
              const SizedBox(width: 8),
              Text(
                'Model: ${profile.model}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProviderFormPage(existing: profile),
                  ),
                ),
                child: const Text('Kelola koneksi'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(providerConfigProvider.notifier)
                      .deleteProfile(profile.id);
                },
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.danger,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hub_outlined, size: 48, color: Color(0xFF8A909E)),
            const SizedBox(height: 16),
            Text(
              'Belum ada provider AI',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Atur base URL, API key, dan model untuk setiap koneksi. '
              'API key disimpan terenkripsi di perangkat ini dan tidak '
              'pernah dibagikan ke model.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Tambah provider'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Local re-export so the tile stays self-contained.
class StatusPill2 extends StatelessWidget {
  const StatusPill2({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceTint,
        borderRadius: const BorderRadius.all(
          Radius.circular(DesignTokens.radiusSm),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
