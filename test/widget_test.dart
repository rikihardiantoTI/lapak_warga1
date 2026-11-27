// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lapak_warga/main.dart';
import 'package:lapak_warga/models/lapak_model.dart';
import 'package:lapak_warga/screens/chat_screen.dart';
import 'package:lapak_warga/screens/lapak_form_screen.dart';

void main() {
  testWidgets('App renders marketplace and navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LapakWargaApp());

    expect(find.text('Lapak Warga'), findsOneWidget);
    expect(find.text('Belanja dekat, kenal tetangga.'), findsOneWidget);
    expect(find.text('Layanan'), findsOneWidget);

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Kerja bakti lingkungan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Layanan'));
    await tester.pumpAndSettle();
    expect(find.text('Layanan warga'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Identitas lapak'), findsOneWidget);
  });

  testWidgets('Home quick actions filter nearby listings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LapakWargaApp());

    final serviceAction = find.byKey(const Key('quick-category-services'));
    await tester.ensureVisible(serviceAction);
    await tester.pumpAndSettle();
    await tester.tap(serviceAction);
    await tester.pumpAndSettle();

    final serviceChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Jasa Tukang'),
    );
    expect(serviceChip.selected, isTrue);
    expect(find.text('3 ditemukan'), findsOneWidget);
  });

  testWidgets('Chat supports emoji messages and asks before sharing location', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ChatScreen(lapak: dummyLapakList.first)),
    );

    expect(find.byTooltip('Telepon Budi Santoso'), findsOneWidget);
    expect(find.byTooltip('Ambil foto'), findsOneWidget);
    expect(find.byTooltip('Kirim lokasi'), findsOneWidget);
    expect(find.byTooltip('Rekam voice note'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('chat-message-input')), 'Halo');
    await tester.tap(find.byKey(const Key('chat-emoji-button')));
    await tester.pumpAndSettle();
    final smilingEmoji = find.text('😊').first;
    await tester.ensureVisible(smilingEmoji);
    await tester.pumpAndSettle();
    await tester.tap(smilingEmoji);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kirim pesan'));
    await tester.pumpAndSettle();

    expect(find.text('Halo😊'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat-location-button')));
    await tester.pumpAndSettle();
    expect(find.text('Bagikan lokasi Anda?'), findsOneWidget);
    expect(
      find.textContaining('Lokasi perangkat saat ini akan dikirim'),
      findsOneWidget,
    );
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Bagikan lokasi Anda?'), findsNothing);
  });

  testWidgets('New listing form reports required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LapakFormScreen()));

    await tester.scrollUntilVisible(
      find.text('Terbitkan lapak'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Terbitkan lapak'));
    await tester.pumpAndSettle();

    expect(find.text('Bagian ini wajib diisi.'), findsWidgets);
    expect(find.text('Masukkan nomor telepon yang valid.'), findsOneWidget);
  });
}
