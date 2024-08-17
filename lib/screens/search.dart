import 'dart:convert';

import 'package:connectivity/connectivity.dart';

import '../widgets/bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'leaflet.dart';
import 'search.dart';
import 'edit_med.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'Add_med.dart';
import '../utils/barcode_scan.dart';
import '../utils/OCR_scan.dart';
import 'Notifications.dart';
import 'homepage.dart';
import 'Medications.dart';
import '../commons/colors.dart';
import '../widgets/floating_action_button.dart';
import '../commons/images.dart';
import 'package:dio/dio.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    );
  }
}

final dio = Dio();

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _scanBarcodeResult = '';
  final _tx_barcode_controller = TextEditingController();
  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  void _toggleAnimation() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white5Color,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Find Medication',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: white1Color,
                ),
              ),
            ],
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
          titleSpacing: 16.0, // Adjust the spacing as needed
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // Set a height constraint
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_tx_barcode_controller.text.isNotEmpty) {
                        await saveRecentSearch(
                            _tx_barcode_controller.text.trim());
                        setState(() {});
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/images/search2.svg',
                        width: 24,
                        height: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _tx_barcode_controller,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search for medication',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _tx_barcode_controller.text.isEmpty,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      FutureBuilder<List<String>>(
                        future: getRecentSearches(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error loading recent searches");
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: snapshot.data!.map((search) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            _tx_barcode_controller.text =
                                                search;
                                            setState(() {});
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Text(
                                              search,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color: Colors
                                          .grey, // Set the color you prefer
                                      height:
                                          1, // Set the height of the divider
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          } else {
                            return Text("No recent searches");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: getSearchResultWidget(_tx_barcode_controller.text),
            ),
          ],
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
              MaterialPageRoute(builder: (context) => Notifications(notifications: [], )),
            );
          },
          onHomePressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          activePage: ActivePage.Search),
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

  Future<void> saveRecentSearch(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentSearches = prefs.getStringList('recentSearches') ?? [];

    // Remove the query if it already exists to keep the list unique
    recentSearches.remove(query);

    // Add the new query to the beginning of the list
    recentSearches.insert(0, query);

    // Limit the list to a certain number of recent searches (e.g., 5)
    if (recentSearches.length > 5) {
      recentSearches = recentSearches.sublist(0, 5);
    }

    // Save the updated list to SharedPreferences
    await prefs.setStringList('recentSearches', recentSearches);
  }

  Future<List<String>> getRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentSearches = prefs.getStringList('recentSearches') ?? [];
    return recentSearches;
  }

  void startBarcodeScan(BuildContext context) async {
    String barcodeScanRes = await BarcodeScanner.startBarcodeScan(context);

    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }

  Future<Map> getSearchResultData(String query) async {
    print("getting data....");
    var response = await dio.get(
        'https://flask-hello-world-psi-green.vercel.app/medication.searchByNameOrBarcode/$query');

    if (response.statusCode == 200) {
      print("${response.data}");
      Map ret = Map.from(jsonDecode(response.data));
      return ret;
    }
    return {};
  }

  Widget getSearchResultWidget(String name) {
    if (name.isEmpty) return Container();

    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        } else {
          var connectivityResult = snapshot.data as ConnectivityResult;

          if (connectivityResult == ConnectivityResult.none) {
            // No internet connection
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_wifi_off,
                  color: Colors.red,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  'You are offline',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          } else {
            // Internet connection is available
            Future<Map> data = getSearchResultData(name.trim());

            return SingleChildScrollView(
              child: FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else if (snapshot.hasData) {
                    Map item = snapshot.data as Map;
                    if (item == null ||
                        item.isEmpty ||
                        item['status'] != 'OK') {
                      return Container(
                        margin: EdgeInsets.only(
                            top: 20), // Adjust the top margin as needed
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Check if 'data' is not null before accessing its properties
                    if (item['data'] != null) {
                      // Use addPostFrameCallback to navigate after the current frame is built
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicationDetailsScreen(data: item['data']),
                          ),
                        );
                      });
                      // Return an empty container here or any widget you want to display on the current page
                      return Container();
                    } else {
                      return Text("No results");
                    }
                  } else {
                    return Text("No results");
                  }
                },
              ),
            );
          }
        }
      },
    );
  }
}
