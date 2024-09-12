import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final Widget child;
  final Function()? onPressed;
  final Color borderColor;

  const CircularButton({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: SizedBox(
        width: 90,
        height: 90,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: backgroundColor,
              textStyle: TextStyle(color: textColor),
              shape: const CircleBorder(eccentricity: 0.5)),
          child: child,
        ),
      ),
    );
  }
}
