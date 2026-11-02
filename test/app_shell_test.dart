import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagent/app/app_shell.dart';
import 'package:superagent/core/security/bip39_wordlist.dart';

/// Smoke test UI workspace (blueprint 8.2: navigasi adaptif).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Bip39Wordlist.load();
  });

  testWidgets('shell merender dashboard di layar sempit (bottom nav)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pumpAndSettle();

    // 5 tab navigasi mobile (desain PDF).
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Wallet'), findsWidgets);
    expect(find.text('Airdrop'), findsWidgets);
    expect(find.text('Agentic'), findsWidgets);
    expect(find.text('Lainnya'), findsWidgets);
    expect(find.text('Selamat datang kembali, Raka'), findsOneWidget);
  });

  testWidgets('shell merender sidebar di layar lebar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pumpAndSettle();

    // Sidebar desktop dengan 8 item (desain PDF).
    expect(find.text('Ringkasan'), findsOneWidget);
    expect(find.text('Provider AI'), findsOneWidget);
    expect(find.text('Binance Agentic'), findsOneWidget);
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('navigasi sidebar pindah halaman', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aktivitas'));
    await tester.pumpAndSettle();

    expect(find.text('Audit trail'), findsOneWidget);
  });
}
