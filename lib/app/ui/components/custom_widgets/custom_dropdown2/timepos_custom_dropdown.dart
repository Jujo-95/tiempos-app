import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/custom_dropdown2/custom_dropdown_search.dart';

// ignore: must_be_immutable
class TiemposCustomDropdown<T> extends StatelessWidget {
  final List<T>? items;
  final String hintText;
  void Function(T?)? onChanged;
  final padding;
  String Function(T?)? itemAsString;
  final Future<List<T>> Function(String?)? onFind;
  final bool showSearchBox;
  final validator;

  TiemposCustomDropdown(
      {super.key,
      this.items,
      this.hintText = '',
      this.onFind,
      this.onChanged,
      this.itemAsString,
      this.padding = const EdgeInsets.all(10),
      this.showSearchBox = true,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CustomDropdownSearch<T>(
        validator: validator,
        itemAsString: itemAsString,
        onChanged: onChanged,
        onFind: onFind,
        dropdownSearchDecoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        popupShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        mode: Mode.MENU,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
          ),
        ),
        showSearchBox: showSearchBox,
        items: items,
        enabled: true,
      ),
    );
  }
}
