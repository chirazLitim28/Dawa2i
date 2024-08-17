import 'package:flutter/material.dart';
import '../commons/colors.dart';
import '../commons/images.dart';
import '../databases/db_medications.dart';
import 'edit_med.dart';

class Taken extends StatelessWidget {
  final Map<String, dynamic> medication;
  final Function(int, String, String) onTakenStatusChanged;

  const Taken({
    Key? key,
    required this.medication,
    required this.onTakenStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: EdgeInsets.zero, // This removes default padding
      content: Container(
        width: double.maxFinite, // Fills the maximum width available
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: white6Color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: black1Color),
                    onPressed: () {
                      // Handle edit button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditMed(medicationData: {},)),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: black1Color),
                    onPressed: () {
                      // Handle delete button press
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Image.asset(
                      pill_image,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 175,
                  child: medication['taken'] == '0'
                      ? Image.asset(
                          missed_image,
                          width: 30,
                          height: 30.0,
                        )
                      : Image.asset(
                          taken_image,
                          width: 30.0,
                          height: 30.0,
                        ),
                ),
              ],
            ),
            SizedBox(height: 18.0),
            Column(
              children: [
                Text(
                  '${medication['name']}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  medication['taken'] == '0' ? 'Missed' : 'Taken',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: medication['taken'] == '0' ? red1Color : green1Color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 15.0),
                  child: Icon(Icons.schedule, color: grey5Color),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Scheduled for ${medication['time']} today',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: grey5Color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 15.0),
                  child: Icon(Icons.description, color: grey5Color),
                ),
                SizedBox(width: 8.0),
                Text(
                  medication['taken'] == '0'
                      ? 'Untake 1 pill(s)'
                      : 'take 1 pill(s)',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: grey5Color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 23.0),
            if (medication['taken'] == '0')
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Update 'taken' to '1' when 'taken' is '0'
                    MedicationDB.updateTakenStatus(
                      medication['id'],
                      '1',
                      medication['time'],
                    );

                    // Call the callback to update the HomePage state
                    onTakenStatusChanged(
                      medication['id'],
                      '1',
                      medication['time'],
                    );

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(85.0, 35.0),
                    primary: red1Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Take',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: white1Color,
                    ),
                  ),
                ),
              ),
            if (medication['taken'] == '1')
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Update 'taken' to '0' when 'taken' is '1'
                    MedicationDB.updateTakenStatus(
                      medication['id'],
                      '0',
                      medication['time'],
                    );

                    // Call the callback to update the HomePage state
                    onTakenStatusChanged(
                      medication['id'],
                      '0',
                      medication['time'],
                    );

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(85.0, 35.0),
                    primary: green1Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Untake',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: white1Color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
