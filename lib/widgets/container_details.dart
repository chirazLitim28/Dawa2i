import 'package:flutter/material.dart';
import '../commons/colors.dart';
import '../commons/images.dart';

class ContainerDetails extends StatefulWidget {
  final String time;
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const ContainerDetails({
    required this.time,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDanger,
  });

  @override
  _ContainerDetailsState createState() => _ContainerDetailsState();
}

class _ContainerDetailsState extends State<ContainerDetails> {
  @override
  Widget build(BuildContext context) {
    String iconPath = widget.isDanger ? missed_image : taken_image;

    return GestureDetector(
      onTap: () => widget.onTap(),
      child: Container(
        padding: EdgeInsets.only(top: 2, left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.time,
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            SizedBox(height: 17.0),
            Container(
              height: 90.0,
              width: 400.0,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: white1Color,
                boxShadow: [
                  BoxShadow(
                    color: grey1Color.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    widget.imagePath,
                    width: 55.0,
                    height: 76.0,
                  ),
                  SizedBox(width: 44.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: black1Color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: grey1Color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 44.0),
                  Image.asset(
                    iconPath,
                    width: 27.0,
                    height: 29.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
