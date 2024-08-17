import 'package:app/screens/Medications.dart';
import '../databases/db_medications.dart';
import '../widgets/bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'edit_med.dart';
import 'search.dart';
import '../widgets/delete_medication.dart';
import '../utils/barcode_scan.dart';
import '../utils/OCR_scan.dart';
import 'homepage.dart';
import 'Notifications.dart';
import 'search.dart';
import '../commons/colors.dart';
import '../widgets/floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../databases/db_medications.dart';

class EditMed extends StatefulWidget {
  final Map<String, dynamic> medicationData; // Add this line

  EditMed({required this.medicationData});

  @override
  _EditMedState createState() => _EditMedState();
}

class _EditMedState extends State<EditMed> {
  TextEditingController _tx_name_Controller = TextEditingController();
  TextEditingController _tx_dose_Controller = TextEditingController();
  TextEditingController _tx_num_pill_Controller = TextEditingController();
  TextEditingController _tx_date_Controller = TextEditingController();
  List<TextEditingController> _timeControllers = [];
  List<TextEditingController> _takenControllers = [];

  DateTime? _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    print("Received medication data: ${widget.medicationData}");
    _tx_name_Controller.text = widget.medicationData['name'] ?? '';
    _tx_dose_Controller.text = widget.medicationData['dose'].toString();
    _tx_num_pill_Controller.text =
        widget.medicationData['num_pill']?.toString() ?? '0';
    _tx_date_Controller.text = widget.medicationData['date'] ?? '';

    if (widget.medicationData['times'] != null) {
      List<String> times =
          (widget.medicationData['times'] as String).split(',');
      List<String> takens =
          (widget.medicationData['takens'] as String).split(',');

      for (int i = 0; i < times.length; i++) {
        TextEditingController timeController =
            TextEditingController(text: times[i]);
        TextEditingController takenController =
            TextEditingController(text: takens[i]);
        _timeControllers.add(timeController);
        _takenControllers.add(takenController);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Set your desired primary color
            colorScheme: ColorScheme.light(primary: Colors.blue),
            highlightColor: Colors.blue, // Set your desired highlight color
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tx_date_Controller.text =
            picked.toString(); // Update the TextField text
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            hintColor: Colors.black,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeControllers[index].text =
            picked.format(context); // Update time in TextEditingController
      });
    }
  }

  Future<void> _updateMedication() async {
    Map<String, dynamic> newData = {
      'name': _tx_name_Controller.text,
      'dose': _tx_dose_Controller.text,
      'num_pill': _tx_num_pill_Controller.text,
      'date': _tx_date_Controller.text,
    };

    await MedicationDB.updateMedication(widget.medicationData['id'], newData);

    // Pass the updated data back to Medications screen
    Navigator.pop(context, newData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medication'),
        actions: [
          TextButton(
            onPressed: () async {
              await _updateMedication();
            },
            child: Text(
              "Save",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 58.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _tx_name_Controller,
                decoration: InputDecoration(
                  hintText: 'Name of the medication',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 35),
              GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 15),
                      Text(
                        _selectedDate != null
                            ? "${_selectedDate!.toLocal()}".split(' ')[0]
                            : "YYYY-MM-DD",
                        style: TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 35),
              TextField(
                controller: _tx_dose_Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Dose of the medication',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 35),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tx_num_pill_Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'How many do you take? (pill(s))',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Text(
                      'When do you need to take your pill(s)?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              if (_timeControllers.isNotEmpty)
                ..._timeControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;

                  return GestureDetector(
                    onTap: () {
                      _selectTime(context, index);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7), // Adjust padding as needed
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100,
                                height: 40,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 238, 237, 237),
                                    width: 1,
                                  ),
                                  color: Colors.grey.withOpacity(0.25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.text.isNotEmpty
                                          ? controller.text
                                          : _timeControllers[index]
                                                  .text
                                                  .isNotEmpty
                                              ? _timeControllers[index].text
                                              : 'Select Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: controller.text.isNotEmpty ||
                                                _timeControllers[index]
                                                    .text
                                                    .isNotEmpty
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '1 Pill', // Display the time index
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(
                            color: Color.fromARGB(255, 205, 205,
                                205), // Change the color of the line
                            thickness: 1, // Adjust the thickness as needed
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
