import 'dart:math';

import 'package:app/models/notification_item.dart';
import 'package:app/screens/Notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../commons/images.dart';
import '../commons/colors.dart';
import '../databases/db_medications.dart';
import 'Medications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/delete_homepage.dart';
import 'edit_med.dart';
import 'Notification/Notification_helper.dart'
    as not; // Import the NotificationHelper class
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AddMed extends StatefulWidget {
  final Map<String, String> preFilledData;

  AddMed({Key? key, required this.preFilledData}) : super(key: key);

  @override
  _AddMedState createState() => _AddMedState();
}

class _AddMedState extends State<AddMed> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController _tx_name_Controller = TextEditingController();
  TextEditingController _tx_dose_Controller = TextEditingController();
  TextEditingController _tx_num_pill_Controller = TextEditingController();
  TextEditingController _tx_date_Controller = TextEditingController();
  List<TextEditingController> _timeControllers = [];
  List<TextEditingController> _takenControllers = [];
  DateTime? _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _nameError;
  String? _doseError;
  String? _numPillError;

  //-------------- Database and notifications ------------------
  final MedicationDB _repository = MedicationDB();
  final not.Notifications _notifications = not.Notifications();
  // List<NotificationItem> scheduledNotifications = [];

  @override
  void initState() {
    super.initState();
    _tx_num_pill_Controller.addListener(_updateTimeFields);
    initNotifies();

    // Set initial values from preFilledData when available
    if (widget.preFilledData.isNotEmpty) {
      _tx_name_Controller.text = widget.preFilledData['name']?.trim() ?? '';
      _tx_dose_Controller.text = widget.preFilledData['dose']?.trim() ?? '';
      _tx_num_pill_Controller.text =
          widget.preFilledData['num_pill']?.trim() ?? '1';
      _tx_date_Controller.text = widget.preFilledData['date']?.trim() ?? '';
    }
  }

//init notifications
  Future initNotifies() async =>
      flutterLocalNotificationsPlugin = await _notifications.initNotifies();

  void _updateTimeFields() {
    int numPills = int.tryParse(_tx_num_pill_Controller.text) ?? 0;
    _timeControllers.clear();
    _takenControllers.clear();

    // Adding the times based on the number of pills with 2-hour intervals
    for (int i = 0; i < numPills; i++) {
      _timeControllers.add(TextEditingController());
      _takenControllers.add(TextEditingController(text: '0'));

      // Setting default time for each pill with a 2-hour interval
      int hours = 8 + (i * 2); // Start from 8:00 and increment by 2 hours
      _timeControllers[i].text = '${hours.toString().padLeft(2, '0')}:00';
    }
    setState(() {});
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
            primaryColor: blue2Color, // Set your desired primary color
            colorScheme: ColorScheme.light(primary: blue2Color),
            highlightColor: blue2Color, // Set your desired highlight color
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tx_date_Controller.text = picked.toString();
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
            primaryColor: black1Color,
            hintColor: black1Color,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: blue1Color,
          leading: InkWell(
            onTap: () {
              // Add the action you want to perform when the close button is pressed
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.close,
              size: 28,
              color: white1Color,
            ),
            // Closing parenthesis for InkWell
          ),
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (_validateAndSave()) {
                        // Validation successful, proceed with saving
                        List<String> times = _timeControllers
                            .map((controller) => controller.text)
                            .toList();
                        List<String> takens = _takenControllers
                            .map((controller) => controller.text)
                            .toList();

                        // Insert medication only if validation passes
                        MedicationDB.insertMedication({
                          'name': _tx_name_Controller.text.trim(),
                          'dose': _tx_dose_Controller.text.trim(),
                          'num_pill': _tx_num_pill_Controller.text.trim(),
                          'date': _tx_date_Controller.text.trim()
                        }, times, takens);

                        setState(() {});
                        // Schedule notifications for each specified time
                        for (int i = 0; i < times.length; i++) {
                          tz.initializeTimeZones();
                          tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));

                          DateTime scheduledDateTime =
                              _notifications.parseTime(times[i]);
                          TimeOfDay scheduledTimeOfDay =
                              TimeOfDay.fromDateTime(scheduledDateTime);

                          await _notifications.showNotification(
                            "It's time to take ${_tx_name_Controller.text}",
                            "Dose: ${_tx_dose_Controller.text}",
                            scheduledTimeOfDay,
                            Random().nextInt(10000000),
                            flutterLocalNotificationsPlugin,
                          );

                          // // Create a NotificationItem and add it to the list
                          // scheduledNotifications.add(NotificationItem(
                          //   title:
                          //       "It's time to take ${_tx_name_Controller.text}",
                          //   medicationName: _tx_name_Controller.text,
                          //   dose: _tx_dose_Controller.text,
                          //   time: times[i],
                          // ));
                        }

                        setState(() {});

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Medications()),
                        );
                      }
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 20, color: white1Color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                    borderSide: BorderSide(
                      color: _nameError != null ? Colors.red : blue1Color,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(
                      color: _nameError != null ? Colors.red : blue1Color,
                      width: 2.0,
                    ),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              if (_nameError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _nameError!,
                    style: TextStyle(color: Colors.red),
                  ),
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
                    border: Border.all(color: grey1Color),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: grey1Color,
                      ),
                      SizedBox(width: 15),
                      Text(
                        _selectedDate != null
                            ? "${_selectedDate!.toLocal()}".split(' ')[0]
                            : "YYYY-MM-DD",
                        style: TextStyle(fontSize: 18, color: blue1Color),
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
                    borderSide: BorderSide(
                      color: _doseError != null ? Colors.red : blue1Color,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(
                      color: _doseError != null ? Colors.red : blue1Color,
                      width: 2.0,
                    ),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              if (_doseError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _doseError!,
                    style: TextStyle(color: Colors.red),
                  ),
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
                            borderSide: BorderSide(
                              color: _numPillError != null
                                  ? Colors.red
                                  : blue1Color,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                              color: _numPillError != null
                                  ? Colors.red
                                  : blue1Color,
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: SvgPicture.asset(
                              'assets/images/Vector.svg',
                              color: black2Color,
                            ),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              if (_numPillError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _numPillError!,
                    style: TextStyle(color: Colors.red),
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
                                            ? black1Color
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

  bool _validateAndSave() {
    _clearErrorMessages();

    bool isValid = true;

    if (_tx_name_Controller.text.trim().isEmpty) {
      setState(() {
        _nameError = "Name feild is required";
      });
      isValid = false;
    }

    if (_tx_dose_Controller.text.trim().isEmpty) {
      setState(() {
        _doseError = "Dose feild is required";
      });
      isValid = false;
    }

    if (_tx_num_pill_Controller.text.trim().isEmpty) {
      setState(() {
        _numPillError = "Number of pills feild is required";
      });
      isValid = false;
    }

    // Add more validations as needed

    return isValid;
  }

  void _clearErrorMessages() {
    setState(() {
      _nameError = null;
      _doseError = null;
      _numPillError = null;
      // Add more error variables if needed
    });
  }
}