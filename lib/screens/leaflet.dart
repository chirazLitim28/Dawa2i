import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../commons/colors.dart';
import '../commons/images.dart';
import 'Add_med.dart';
import 'Notifications.dart';
import 'homepage.dart';
import 'Medications.dart';
import '../widgets/bottom_app_bar.dart';
import '../widgets/floating_action_button.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Map data;

  const MedicationDetailsScreen({Key? key, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here
        // You can navigate back to the search screen without redoing the search
        Navigator.pop(context);
        return false; // Return false to prevent default behavior
      },
      child: Scaffold(
        backgroundColor: white5Color,
        appBar: AppBar(
          title: Text(
            data['name'] ?? 'Medication Details',
            style: TextStyle(
              color: white1Color,
            ),
          ),
          backgroundColor: blue1Color,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: white1Color,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          titleSpacing: 16.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 50),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 30),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            pill_image1,
                            width: 90,
                            height: 90,
                            fit: BoxFit.scaleDown,
                          ),
                        ]),
                    SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pill Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          data['name'] ?? '',
                          style: TextStyle(
                            color: Color(0xFF00B4D8),
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.54,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Pill Dosage',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          '${data['dose'] ?? ''} mg',
                          style: TextStyle(
                            color: Color(0xFF00B4D8),
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.54,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Number of Pills',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          '${data['pill_num']?.toString() ?? 'Number of Pills'}',
                          style: TextStyle(
                            color: blue1Color,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indications',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 15),
                      // Display indications
                      for (var indication in data['indications'] ?? [])
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: ShapeDecoration(
                                color: Color(0xFF00B4D8),
                                shape: CircleBorder(),
                              ),
                            ),
                            SizedBox(width: 15),
                            SizedBox(
                              width: 320,
                              child: Text(
                                indication,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Color(0xFF6F6E6E),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      //////////////////////////////////////
                      Text(
                        'Side effects',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 15),
                      // Display indications
                      for (var effect in data['effects'] ?? [])
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: ShapeDecoration(
                                color: Color(0xFF00B4D8),
                                shape: CircleBorder(),
                              ),
                            ),
                            SizedBox(width: 15),
                            SizedBox(
                              width: 320,
                              child: Text(
                                effect,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Color(0xFF6F6E6E),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to AddMed with pre-filled data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMed(
                          preFilledData: {
                            'name': data['name'] ?? '', // Use name from data
                            'dose': data['dose'] ?? '', // Use dose from data
                            // Add other fields as needed
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: blue1Color, // Set button's background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          14), // Set button's border radius
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 10), // Set button's padding
                  ),
                  child: Container(
                    width: 250, // Set the width of the button
                    child: Center(
                      child: Text(
                        'Add To Schedule',
                        style: TextStyle(
                          color: white1Color,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBarWidget(
          onSearchPressed: () {},
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
          onHomePressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          activePage: ActivePage.Search,
        ),
      ),
    );
  }
}
