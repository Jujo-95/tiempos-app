import 'package:flutter/material.dart';

class ButtonRounded extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  //this is the correct way to pass a functon to a widget
  final Function()? onPressed;
  final Color borderColor;
  final double width;

  final decoration;
  final shape;
  final height;

  const ButtonRounded({
    super.key,
    this.backgroundColor = const Color(0xFF2952E1),
    required this.child,
    required this.onPressed,
    this.borderColor = Colors.transparent,
    this.width = 100,
    this.decoration,
    this.shape,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    decoration ??
        BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
        );

    shape ??
        MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

    return Container(
      decoration: decoration,
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(backgroundColor),
              alignment: const Alignment(0, 0),
              shape: shape),
          child: child,
        ),
      ),
    );
  }
}
