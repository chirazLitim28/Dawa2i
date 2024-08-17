import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../commons/colors.dart';

enum ActivePage { Home, Search, Medications, Notifications }

class BottomAppBarWidget extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback onMedicationsPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onHomePressed;
  final ActivePage activePage;

  const BottomAppBarWidget({
    Key? key,
    required this.onSearchPressed,
    required this.onMedicationsPressed,
    required this.onNotificationsPressed,
    required this.onHomePressed,
    required this.activePage,
  }) : super(key: key);

  String _getIconPath(String iconName) {
    String colorSuffix = '';

    switch (activePage) {
      case ActivePage.Home:
        colorSuffix = (iconName == 'home') ? '_b' : '';
        break;
      case ActivePage.Search:
        colorSuffix = (iconName == 'search') ? '_b' : '';
        break;
      case ActivePage.Medications:
        colorSuffix = (iconName == 'pill') ? '_b' : '';
        break;
      case ActivePage.Notifications:
        colorSuffix = (iconName == 'notification') ? '_b' : '';
        break;
    }

    return 'assets/images/$iconName$colorSuffix.svg';
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 5,
      shape: CircularNotchedRectangle(),
      color: white7Color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              _getIconPath('home'),
              width: 24,
              height: 24,
            ),
            onPressed: onHomePressed,
          ),
          IconButton(
            icon: SvgPicture.asset(
              _getIconPath('search'),
              width: 24,
              height: 24,
            ),
            onPressed: onSearchPressed,
          ),
          // Adjust the space for the notched area
          IconButton(
            icon: SvgPicture.asset(
              _getIconPath('pill'),
              width: 30,
              height: 30,
            ),
            onPressed: onMedicationsPressed,
          ),
          IconButton(
            icon: SvgPicture.asset(
              _getIconPath('notification'),
              width: 24,
              height: 24,
            ),
            onPressed: onNotificationsPressed,
          ),
        ],
      ),
    );
  }
}
