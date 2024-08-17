import 'package:flutter/material.dart';
import '../commons/colors.dart';

class DeleteConfirmationDialog1 {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Omeprazole',
                style: TextStyle(
                  color: grey9Color,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Only this dose',
                  style: TextStyle(
                    color: black9Color,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10), // Add some space between the buttons
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // Perform delete operation
                  // ...
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'All future doses',
                  style: TextStyle(
                    color: black10Color,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
