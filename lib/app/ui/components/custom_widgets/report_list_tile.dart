// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:crypto/src/sha1.dart';
import 'package:flutter/material.dart';

Widget initialsAvatarBuilder(fullName, child, radius) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CircleAvatar(
            radius: radius,
            backgroundColor: getColorFromText(fullName).withOpacity(0.1),
            foregroundColor:
                getColorFromText(fullName).withAlpha(250).withOpacity(1),
            child: Text(getInitials(fullName)),
          ),
        ),
        child ?? Container()
      ],
    );

listTileShapeBuilder() => RoundedRectangleBorder(
      side: BorderSide(color: Colors.grey.shade300, width: 1),
      borderRadius: BorderRadius.circular(10),
    );

subtitleContainerStyle(Color? chipColor, child) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: chipColor ?? Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: child,
          ),
        ],
      ),
    );
titlteStyle(child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: child ?? const SizedBox.shrink(),
    );

leadingStyle(child, bool? isMiniChip) => ConstrainedBox(
      constraints: !isMiniChip!
          ? BoxConstraints.expand(width: 150)
          : BoxConstraints.expand(width: 196),
      child: child,
    );

Widget emptyListTile() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          ListTileForReportView(
            chipColor: Colors.grey.shade200,
            subtitle: Text(
              ' ' * 10,
            ),
            title: Text(' ' * 10),
            trailing: Text(' ' * 10),
          ),
          Center(child: CircularProgressIndicator())
        ],
      ),
    );

class ListTileForReportView extends StatelessWidget {
  Widget? subtitle;
  var onTap;
  Color? chipColor;
  Widget? title;
  Widget? trailing;
  Widget? leading;
  double? height;
  bool isMiniChip;

  ListTileForReportView(
      {super.key,
      this.subtitle,
      this.chipColor,
      this.onTap,
      this.title,
      this.trailing,
      this.leading,
      this.height,
      this.isMiniChip = false});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      height: height ??= 70, //200,
      child: ListTile(
        splashColor: null,
        shape: listTileShapeBuilder(),
        onTap: () => onTap,
        subtitle: subtitle != null
            ? subtitleContainerStyle(chipColor, subtitle)
            : const SizedBox.shrink(),
        title: titlteStyle(title),
        trailing: trailing ?? const SizedBox.shrink(),
        leading: leading != null ? leadingStyle(leading, isMiniChip) : null,
      ),
    ));
  }
}

String getInitials(String name) {
  final initials = RegExp(r'\b\w');
  final matches = initials.allMatches(name);
  final StringBuffer buffer = StringBuffer();

  for (final match in matches) {
    buffer.write(match.group(0));
  }

  String initialsLetters = '';

  if (buffer.toString().toUpperCase().length > 2) {
    initialsLetters = buffer.toString().toUpperCase().substring(0, 2);
  } else {
    initialsLetters = buffer.toString().toUpperCase();
  }

  return initialsLetters;
}

Color getColorFromText(String text) {
  final bytes = utf8.encode(text);
  final digest = sha1.convert(bytes);
  String hexColor = digest.toString().substring(0, 6);
  hexColor = '50$hexColor';
  Color color =
      Color(int.parse(hexColor.toUpperCase().replaceAll('#', ''), radix: 16));

  return color;
}
