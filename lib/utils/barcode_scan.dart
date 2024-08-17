import 'dart:convert';
import 'package:app/screens/leaflet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:app/constants/endpoints.dart';
import '../commons/colors.dart';
import '../commons/images.dart';
import '../screens/Add_med.dart';
import '../widgets/barcode_dialog.dart';

final dio = Dio();

class BarcodeScanner {
  static Future<String> startBarcodeScan(BuildContext context) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version";
    }

    if (barcodeScanRes.isNotEmpty) {
      // Use the scanned barcode to search for medication in the database
      var response = await dio.get('$api_endpoint_medication_searchbybarcode$barcodeScanRes');
      if (response.statusCode == 200) {
        Map<String, dynamic> item = Map<String, dynamic>.from(jsonDecode(response.data));
        if (item != null && item.isNotEmpty && item['status'] == 'OK') {
          // Medication found, navigate to the details screen or display details here
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationDetailsScreen(data: item['data']),
            ),
          );

          // Show the dialog after processing the barcode
          BarcodeDialog.showBarcodeDialog(context, barcodeScanRes, item);
        } else {
          // Medication not found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication not found'),
            ),
          );
        }
      } else {
        // Handle the case where the server response is not successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred when searching for medication'),
          ),
        );
      }
    }

    return barcodeScanRes;
  }
}
