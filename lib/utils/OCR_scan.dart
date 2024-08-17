import 'dart:convert';
import 'dart:io';
import 'package:app/constants/endpoints.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import '../commons/colors.dart';
import '../screens/Add_med.dart';
import '../commons/images.dart';
import '../main.dart';
import '../screens/leaflet.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TScan Medication Name',
      theme: ThemeData(
        primarySwatch: blue6Color,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);

                    return Center(
                      child: Container(
                        width: 150, // Set your desired width
                        height: 400, // Set your desired height
                        child: CameraPreview(_cameraController!),
                      ),
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text("Scan Medication's Name"),
              ),
              backgroundColor: _isPermissionGranted ? black6Color : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _scanImage,
                              child: const Text('Scan text'),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          'Camera permission denied',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  void _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    // Set the zoom level
    _cameraController!.setZoomLevel(3); // Adjust the zoom level as needed

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    try {
      final pictureFile = await _cameraController!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Use the recognized text to search for medication in the database
      String query = recognizedText.text;
      var response = await dio.get(
       '$api_endpoint_searchbyname_or_barcode$query$query',
      );

      if (response.statusCode == 200) {
        Map item = Map.from(jsonDecode(response.data));
        if (item != null && item.isNotEmpty && item['status'] == 'OK') {
          // Show the dialog after processing the recognized text
          _showMedicationDialog(context, query, item);
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
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  void _showMedicationDialog(BuildContext context, String query, Map item) {
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
                GestureDetector(
                  onTap: () {
                    // Navigate to the medication details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicationDetailsScreen(
                            // Pass necessary data to the details screen
                            data: item['data']),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Medication',
                        style: TextStyle(
                          color: black1Color,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.48,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '$query',
                        style: TextStyle(
                          color: grey2Color,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.48,
                        ),
                      ),
                    ],
                  ),
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
                                  'name':
                                      query, // Use the recognized text as the name
                                  'dose': item['data']['dose'] ??
                                      '', // Use dose from item
                                  'date':
                                      item['date'] ?? DateTime.now().toString(),
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
