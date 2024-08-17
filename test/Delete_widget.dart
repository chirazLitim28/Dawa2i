import 'package:app/widgets/delete_medication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('DeleteConfirmationDialog Widget Test', (WidgetTester tester) async {
    // Build the DeleteConfirmationDialog widget
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ElevatedButton(
            onPressed: () {
              DeleteConfirmationDialog.show(context);
            },
            child: const Text('Show Dialog'),
          );
        },
      ),
    ));

    // Tap the ElevatedButton to show the dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);

    // Verify the content of the AlertDialog
    expect(find.text('Delete Omeprazole'), findsOneWidget);
    expect(find.text('Deleting this medication will stop any notifications.'), findsOneWidget);

    // Tap the CANCEL button and verify that the dialog is closed
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
