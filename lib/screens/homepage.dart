import 'package:app/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../databases/db_medications.dart';
import '../commons/colors.dart';
import '../commons/images.dart';
import '../widgets/bottom_app_bar.dart';
import '../widgets/floating_action_button.dart';
import 'Medications.dart';
import 'Notifications.dart';
import '../utils/OCR_scan.dart';
import '../utils/barcode_scan.dart';
import 'edit_med.dart';
import 'edit_taken.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDay;
  late List<Map<String, dynamic>> _medications = [];
  String _scanBarcodeResult = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _selectedDay = DateTime.now();
    _fetchMedicationsForDay(_selectedDay);
  }

  void _toggleAnimation() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Future<void> _fetchMedicationsForDay(DateTime day) async {
    List<Map<String, dynamic>> meds = await MedicationDB.getAllMedications(day);

    // Update the fetched data to include 'id' and 'taken' status
    List<Map<String, dynamic>> expandedMeds = [];
    for (var medication in meds) {
      List<String> times = (medication['times'] ?? '').split(',');
      List<String> takens = (medication['takens'] ?? '').split(',');

      for (int i = 0; i < times.length; i++) {
        var expandedMed = Map<String, dynamic>.from(medication);
        expandedMed['id'] = medication['id'];
        expandedMed['time'] = times[i];
        expandedMed['taken'] = takens[i];
        expandedMeds.add(expandedMed);
      }
    }

    setState(() {
      _medications = expandedMeds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue1Color,
        toolbarHeight: 98,
        title: Text(
          'Home',
          style: TextStyle(fontSize: 20, color: white1Color),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(Duration(days: 365)),
            lastDay: DateTime.now().add(Duration(days: 365)),
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.week,
            calendarStyle: CalendarStyle(
              outsideTextStyle: TextStyle(color: grey1Color),
              selectedDecoration: BoxDecoration(
                color: blue7Color,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: blue1Color), // Style for the current day
            ),
            selectedDayPredicate: (DateTime date) {
              return isSameDay(_selectedDay, date);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _fetchMedicationsForDay(selectedDay);
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: EdgeInsets.all(0), // Remove any padding
              headerMargin: EdgeInsets.all(0), // Remove any margin
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 18, left: 18, top: 18),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    grey3Color,
                    white1Color,
                  ],
                  radius: 0.90,
                  stops: [0.5, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _medications.isEmpty
                        ? Center(
                            child: Image.asset(
                              medication_image,
                              width: 200,
                              height: 200,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _medications.length,
                            itemBuilder: (context, index) {
                              final medication = _medications[index];
                              String isTaken = medication['taken'];
                              bool taken1 = isTaken == '1';
                              // Split the concatenated times string to get individual times
                              List<String> times =
                                  (medication['times'] ?? '').split(',');
                              List<String> takens =
                                  (medication['takens'] ?? '').split(',');
                              return GestureDetector(
                                onTap: () {
                                  // Show pop-up dialog when a medication is tapped
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Use the MedicationPopup widget
                                      return Taken(
                                        medication:
                                            medication, // Pass the medication data
                                        onTakenStatusChanged:
                                            onTakenStatusChanged, // Pass the callback
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 2, left: 8, right: 8, bottom: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${medication['time']}',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 17.0),
                                      Container(
                                          height: 90, // Adjust height as needed
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: white1Color,
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    grey1Color.withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 3,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                pill_image,
                                                width: 55.0,
                                                height: 76.0,
                                              ),
                                              SizedBox(
                                                  width:
                                                      24.0), // Adjust as needed
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      medication['name'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: black1Color,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.0),
                                                    Text(
                                                      '${medication['dose']} mg',
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: grey1Color,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                      24.0), // Adjust as needed
                                              Image.asset(
                                                taken1
                                                    ? taken_image
                                                    : missed_image,
                                                width: 27.0,
                                                height: 29.0,
                                              ),
                                            ],
                                          )),
                                      SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBarWidget(
          onSearchPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
          onMedicationsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Medications()),
            );
          },
          onNotificationsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications(notifications: [],)),
            );
          },
          onHomePressed: () {},
          activePage: ActivePage.Home),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: CustomFloatingActionButton(
        animation: _animation,
        onBarcodePressed: () {
          startBarcodeScan(context);
        },
        onTextPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        },
        onScanPressed: _toggleAnimation,
      ),
    );
  }

  void onTakenStatusChanged(int id, String takenStatus, String time) {
    // Update the medication status in the _medications list
    setState(() {
      _medications = _medications.map((medication) {
        if (medication['id'] == id && medication['time'] == time) {
          medication['taken'] = takenStatus;
        }
        return medication;
      }).toList();
    });
  }

  void startBarcodeScan(BuildContext context) async {
    String barcodeScanRes = await BarcodeScanner.startBarcodeScan(context);

    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }
}
