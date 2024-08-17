import '../utils/OCR_scan.dart';
import '../utils/barcode_scan.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_app_bar.dart';
import 'Medications.dart';
import 'homepage.dart';
import 'search.dart';
import '../widgets/floating_action_button.dart';
import '../commons/colors.dart';
import '../commons/images.dart';

class NotificationItem {
  const NotificationItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

class Notifications extends StatefulWidget {
  final List<NotificationItem> notifications;
  

  const Notifications({
    Key? key,
    required this.notifications,
  }) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<NotificationItem> notifications = []; // Add this line
  String _scanBarcodeResult = '';

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _checkAndDisplayNotifications();
  }

  void _toggleAnimation() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

void _checkAndDisplayNotifications() {
  DateTime now = DateTime.now();
  List<NotificationItem> currentNotifications = widget.notifications
      .where((notification) {
        // Assuming the subtitle contains the scheduled time in the format "HH:mm"
        // You should modify this based on how you store the scheduled time in your data
        String scheduledTimeStr = notification.subtitle;

        // Parse the scheduled time string to DateTime
        DateTime scheduledTime = DateTime.parse("2023-01-01 $scheduledTimeStr:00");

        // Check if the scheduled time is before or equal to the current time
        return scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now);
      })
      .toList();

  setState(() {
    notifications = List.from(currentNotifications);
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(118.0),
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
                    padding: const EdgeInsets.only(right: 10.0, top: 35),
                    child: Text(
                      "Notifications",
                      style: TextStyle(fontSize: 20, color: white1Color),
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
            radius: 0.80,
            stops: [0.5, 1.0],
          ),
        ),
        child: ListView.builder(
          itemCount: widget.notifications.length,
          itemBuilder: (context, index) {
            final notification = widget.notifications[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16.0),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: white1Color,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: grey1Color.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: Offset(0, 3.0),
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
                        notification.image,
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
                          notification.title,
                          style: TextStyle(fontSize: 18, color: red1Color),
                        ),
                        Text(
                          notification.subtitle,
                          style: TextStyle(fontSize: 16, color: grey1Color),
                        ),
                      ],
                    ),
                  ),
                ],
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
        onMedicationsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Medications()),
          );
        },
        onNotificationsPressed: () {},
        onHomePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        activePage: ActivePage.Notifications,
      ),
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
      ),);
  }
  void startBarcodeScan(BuildContext context) async {
    String barcodeScanRes = await BarcodeScanner.startBarcodeScan(context);

    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }
}
 