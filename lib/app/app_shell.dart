import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/design_tokens.dart';
import '../app/theme.dart';
import '../features/activity/activity_page.dart';
import '../features/airdrop/airdrop_page.dart';
import '../features/binance/binance_page.dart';
import '../features/chat/chat_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/model/model_page.dart';
import '../features/provider/provider_settings_page.dart';
import '../features/settings/settings_page.dart';
import '../features/wallet/wallet_page.dart';

/// Adaptive workspace shell (blueprint 8.2, design PDF layout).
///
/// - < 600 dp: bottom navigation, 5 tabs (Beranda, Wallet, Airdrop,
///   Agentic, Lainnya).
/// - >= 600 dp: fixed left sidebar with the full nav list (Ringkasan,
///   Wallet, Provider AI, Model, Airdrop, Binance Agentic, Aktivitas,
///   Pengaturan) and a workspace header + user footer.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _mobileTabs = <_NavTab>[
    _NavTab(label: 'Beranda', icon: Icons.home_outlined, child: DashboardPage()),
    _NavTab(label: 'Chat', icon: Icons.chat_bubble_outline, child: ChatPage()),
    _NavTab(
        label: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        child: WalletPage()),
    _NavTab(
        label: 'Airdrop', icon: Icons.card_giftcard_outlined, child: AirdropPage()),
    _NavTab(
        label: 'Agentic',
        icon: Icons.smart_toy_outlined,
        child: BinancePage()),
    _NavTab(
        label: 'Lainnya', icon: Icons.more_horiz, child: SettingsPage()),
  ];

  static const _sidebarTabs = <_NavTab>[
    _NavTab(label: 'Ringkasan', icon: Icons.home_outlined, child: DashboardPage()),
    _NavTab(
        label: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        child: WalletPage()),
    _NavTab(
        label: 'Provider AI',
        icon: Icons.hub_outlined,
        child: ProviderSettingsPage()),
    _NavTab(
        label: 'Model', icon: Icons.psychology_outlined, child: ModelPage()),
    _NavTab(
        label: 'Airdrop', icon: Icons.card_giftcard_outlined, child: AirdropPage()),
    _NavTab(
        label: 'Binance Agentic',
        icon: Icons.smart_toy_outlined,
        child: BinancePage()),
    _NavTab(
        label: 'Aktivitas', icon:Icons.receipt_long_outlined, child: ActivityPage()),
    _NavTab(
        label: 'Pengaturan',
        icon: Icons.settings_outlined,
        child: SettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colors = appColors(context);
    final tabs = width < DesignTokens.singleColumn ? _mobileTabs : _sidebarTabs;
    final active = tabs[_index.clamp(0, tabs.length - 1)];

    if (width < DesignTokens.singleColumn) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(child: active.child),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index.clamp(0, tabs.length - 1),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final t in tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.icon),
                label: t.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          _Sidebar(
            tabs: tabs,
            index: _index,
            onChanged: (i) => setState(() => _index = i),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(title: active.label),
                Expanded(child: active.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon, required this.child});

  final String label;
  final IconData icon;
  final Widget child;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<_NavTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Container(
      width: DesignTokens.sidebarWidth,
      color: colors.sidebar,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 20),
            child: Text(
              'superagent',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // P-01: lazy list even for the nav.
              itemCount: tabs.length,
              itemBuilder: (context, i) {
                final t = tabs[i];
                final selected = i == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: selected ? colors.surfaceTint : Colors.transparent,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(DesignTokens.radiusSm),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(DesignTokens.radiusSm),
                      ),
                      onTap: () => onChanged(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        child: Row(
                          children: [
                            Icon(
                              t.icon,
                              size: 18,
                              color: selected
                                  ? DesignTokens.accent
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            // Flexible so long labels ("Binance Agentic")
                            // wrap/shrink instead of overflowing the fixed
                            // sidebar width.
                            Flexible(
                              child: Text(
                                t.label,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: selected
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.all(12),
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
              const CircleAvatar(
                radius: 14,
                backgroundColor: DesignTokens.accent,
                child: Text(
                  'RA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D0F12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raka Aditya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pribadi · Paket Pro',
                      style: TextStyle(
                          fontSize: 10, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = appColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace Raka / $title',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.surfaceTint,
              borderRadius: const BorderRadius.all(
                Radius.circular(DesignTokens.radiusSm),
              ),
            ),
            child: Text(
              'DEMO · DATA ILUSTRATIF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.notifications_none, size: 18, color: colors.textSecondary),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 14,
            backgroundColor: DesignTokens.accent,
            child: Text(
              'RA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D0F12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
