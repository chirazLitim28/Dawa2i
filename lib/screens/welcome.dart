// welcome_page.dart

import 'package:flutter/material.dart';
import '../commons/colors.dart';
import '../commons/images.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background with BoxDecoration
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    welcome_image), // Replace with your background image asset path
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content on top of the background image
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  logo_image, // Replace with your logo asset path
                  width: 130.0,
                  height: 130.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Dawa2i',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: blue1Color, // Adjust the color as needed
                  ),
                ),
                SizedBox(height: 16.0),
                // Additional content can be added here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
