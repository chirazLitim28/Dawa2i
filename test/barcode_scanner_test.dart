import 'package:app/widgets/barcode_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/barcode_dialog.dart';
 // Import your BarcodeDialog class

void main() {
  testWidgets('BarcodeDialog shows correct content', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  BarcodeDialog.showBarcodeDialog(context, 'barcode', {'data': {'name': 'Test Medication'}, 'date': DateTime.now()});
                },
                child: Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the dialog.
    await tester.tap(find.text('Show Dialog'));
    await tester.pump();

    // Verify that the dialog is displayed with the correct content.
    expect(find.text('medication'), findsOneWidget);
    expect(find.text('Test Medication'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });
}
