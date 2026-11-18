// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lapak_warga/main.dart';
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
