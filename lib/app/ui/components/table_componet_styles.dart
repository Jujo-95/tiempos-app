import 'package:flutter/material.dart';

class TableComponentStyles {
  static TextStyle titleStyle =
      const TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle lableStyle =
      TextStyle(fontSize: 14, color: Colors.grey.shade500);
}

class CustomRowTemplate extends StatelessWidget {
  final List<Widget> children;
  BoxDecoration? decoration;
  EdgeInsets? padding;

  CustomRowTemplate({
    Key? key,
    required this.children,
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: decoration,
      child: Row(
        children: children.map((child) => Expanded(child: child)).toList(),
      ),
    );
  }
}

BoxDecoration customRowDecoration = BoxDecoration(
  border: Border.all(color: Colors.grey.shade300, width: 1),
  borderRadius: BorderRadius.circular(10),
);
