import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../commons/colors.dart';
import '../commons/images.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final Animation<double> animation;
  final Function() onBarcodePressed;
  final Function() onTextPressed;
  final Function() onScanPressed;

  const CustomFloatingActionButton({
    required this.animation,
    required this.onBarcodePressed,
    required this.onTextPressed,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(0, -10 * animation.value),
              child: Opacity(
                opacity: animation.value,
                child: FloatingActionButton(
                  onPressed: onBarcodePressed,
                  backgroundColor: blue4Color,
                  child: Image.asset(
                    barcode_image,
                    width: 30,
                    height: 30,
                    color: blue3Color,
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(0, -5.0 * animation.value),
              child: Opacity(
                opacity: animation.value,
                child: FloatingActionButton(
                  onPressed: onTextPressed,
                  backgroundColor: blue4Color,
                  child: Image.asset(
                    text_image,
                    width: 30,
                    height: 30,
                    color: blue3Color,
                  ),
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          onPressed: onScanPressed,
          backgroundColor: blue5Color,
          child: SvgPicture.asset(
            scan_image,
            width: 40,
            height: 40,
            color: white1Color,
          ),
        ),
      ],
    );
  }
}
