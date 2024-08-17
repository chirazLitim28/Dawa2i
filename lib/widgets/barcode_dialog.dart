import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../commons/colors.dart';
import '../commons/images.dart';
import '../screens/Add_med.dart';
import '../constants/endpoints.dart';
import '../screens/leaflet.dart';

class BarcodeDialog {
  static void showBarcodeDialog(BuildContext context, String barcode, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.zero,
          backgroundColor: white1Color,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.0),
          content: SizedBox(
            height: 80, // Adjust the height as needed
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 20), // Adjust left padding as needed
                      child: Image.asset(
                        pill_image,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'medication',
                      style: TextStyle(
                        color: black1Color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.48,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      item['data']['name'],
                      style: TextStyle(
                        color: grey2Color,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.48,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20,
                          right: 16.0), // Adjust left padding as needed
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/plus.svg',
                          width: 35,
                          height: 35,
                        ),
                        onPressed: () {
                          // Navigate to AddMed with pre-filled data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMed(
                                preFilledData: {
                                  'name': item['data']['name'] ?? '', // Use name from item
                                  'dose': item['data']['dose'] ?? '', // Use dose from item
                                  'date': item['date'] ?? DateTime.now().toString(),
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
