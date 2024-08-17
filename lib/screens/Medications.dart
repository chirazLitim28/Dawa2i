import 'package:app/screens/edit_med.dart';
import 'package:app/utils/OCR_scan.dart';
import 'package:app/utils/barcode_scan.dart';
import 'package:flutter/material.dart';
import '../databases/db_medications.dart';
import '../widgets/bottom_app_bar.dart';
import '../widgets/floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'Add_med.dart';
import 'Notifications.dart' as nt;
import 'homepage.dart';
import 'homepage.dart';
import 'search.dart';

import '../commons/colors.dart';
import '../commons/images.dart';
import '../databases/db_medications.dart';

class Medications extends StatefulWidget {
  @override
  _MedicationsState createState() => _MedicationsState();
}

class _MedicationsState extends State<Medications>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> medications = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _scanBarcodeResult = '';

  @override
  void initState() {
    super.initState();

    // Fetch Medications
    _fetchMedications();

    // Animation Setup
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _fetchMedications() async {
    List<Map<String, dynamic>> meds =
        await MedicationDB.getAllMedicationsForDisplay();
    setState(() {
      medications = meds;
    });
  }

  void _toggleAnimation() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: AppBar(
          backgroundColor: blue1Color,
          leading: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 28,
                color: white1Color,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0, top: 25),
                    child: Text(
                      "Medications",
                      style: TextStyle(fontSize: 20, color: white1Color),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 35, right: 10),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: white1Color,
                        size: 35,
                      ),
                      onPressed: () {
                        // Navigate to the Add medication  screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMed(
                                preFilledData: {}), // You need to pass the actual data here
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(18),
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
        child: medications.isEmpty
            ? Center(
                child: Image.asset(
                  medication_image, // Replace with your image path
                  width: 200, // Adjust the size of the image as needed
                  height: 200,
                ),
              )
            : ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return GestureDetector(
                    // Navigate to the EditMedication screen when the container is tapped
                    onTap: () async {
                      print("Medication data: ${medications[index]}");
                      final updatedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMed(
                            medicationData: medications[index],
                          ),
                        ),
                      );

                      // Check if updatedData is not null and update the medications list
                      if (updatedData != null) {
                        // Find the index of the updated medication in the list
                        int updatedIndex = medications.indexWhere(
                          (element) => element['id'] == updatedData['id'],
                        );

                        // Update the medications list
                        setState(() {
                          medications[updatedIndex] = updatedData;
                        });
                      }
                    },

                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: white1Color,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: grey1Color.withOpacity(0.5),
                            blurRadius: 5.0,
                            offset: Offset(1, 3.0),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                pill_image, // Replace with actual image path or URL
                                width: 55,
                                height: 59.32,
                              ),
                            ),
                          ),
                          SizedBox(width: 27),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication[
                                      'name'], // Replace with medication name from your data
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: black5Color,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '${medication['dose']} mg', // Replace with date from your data
                                  style: TextStyle(
                                      fontSize: 16, color: grey1Color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBarWidget(
          onSearchPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
          onMedicationsPressed: () {},
          onNotificationsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => nt.Notifications(
                        notifications: [],
                      )),
            );
          },
          onHomePressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          activePage: ActivePage.Medications),
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

  void startBarcodeScan(BuildContext context) async {
    String barcodeScanRes = await BarcodeScanner.startBarcodeScan(context);

    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }
}
