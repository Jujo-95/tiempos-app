import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class TextFieldFormHeader extends StatefulWidget {
  final TextInputType? keyboardType;
  final String? header;
  final bool? obscureText;
  void Function(String)? onChanged;
  TextEditingController? controller;
  Widget? prefixIcon;
  Widget? suffixIcon;
  Color? prefixIconColor;
  Color? sufixIconColor;
  final double fieldHeight;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final validator;
  EdgeInsetsGeometry padding;
  final customValidator;
  EdgeInsetsGeometry? validatorPadding;
  final bool readOnly;
  final String hintText;
  var initialValue;
  final Widget? child;
  void Function(String)? onSubmitted;
  TextStyle? style;
  TextAlign? textAlign;
  TextAlignVertical? textAlignVertical;

  //String initialText;

  TextFieldFormHeader(
      {super.key,
      this.child,
      this.keyboardType = TextInputType.name,
      this.header = '',
      this.obscureText = false,
      this.hintText = '',
      this.controller,
      this.onChanged,
      this.prefixIcon,
      this.suffixIcon,
      this.prefixIconColor,
      this.sufixIconColor,
      this.fieldHeight = 45,
      this.maxLines = 1,
      this.inputFormatters = const [],
      this.validator,
      this.padding = const EdgeInsets.all(0),
      this.validatorPadding = const EdgeInsets.only(top: 2, bottom: 5),
      this.customValidator,
      this.readOnly = false,
      this.initialValue,
      this.onSubmitted,
      this.style,
      this.textAlign,
      this.textAlignVertical});

  @override
  State<TextFieldFormHeader> createState() => _TextFieldFormHeaderState();
}

class _TextFieldFormHeaderState extends State<TextFieldFormHeader> {
  @override
  Widget build(BuildContext context) {
    if (widget.header!.isNotEmpty && widget.customValidator != null) {
      widget.padding = const EdgeInsets.only(top: 8.0);
    } else if (widget.header!.isNotEmpty) {
      widget.padding = const EdgeInsets.only(top: 8.0, bottom: 12);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.header!.isEmpty
            ? const SizedBox.shrink()
            : Text(
                widget.header!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        Padding(
          padding: widget.padding,
          child: GestureDetector(
              child: Container(
            height: widget.fieldHeight,
            decoration: BoxDecoration(
              border: null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.child ??
                TextFormField(
                  style: widget.style,
                  onFieldSubmitted: widget.onSubmitted,
                  initialValue: widget.initialValue,
                  readOnly: widget.readOnly,
                  validator: widget.validator,
                  textCapitalization: TextCapitalization.words,
                  textAlignVertical:
                      widget.textAlignVertical ?? TextAlignVertical.top,
                  textAlign: widget.textAlign ?? TextAlign.start,
                  onChanged: widget.onChanged,
                  controller: widget.controller,
                  obscureText: widget.obscureText!,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  inputFormatters: widget.inputFormatters,
                  decoration: inputDecorationBuilder(hintText: widget.hintText),
                ),
          )),
        ),
        if (widget.customValidator != null)
          ValidationWidget(
            validationText: widget.customValidator,
            validatorPadding: widget.validatorPadding,
          ),
      ],
    );
  }

  InputDecoration inputDecorationBuilder(
          {prefixIcon,
          prefixIconColor,
          suffixIcon,
          sufixIconColor,
          hintText}) =>
      InputDecoration(
        contentPadding: const EdgeInsets.all(12),
        hintText: hintText,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: suffixIcon,
        suffixIconColor: sufixIconColor,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}

// this class is created to customize the optional parameter inputFormatters of TextFieldFormHeader and is used to validate using regex the values that are allowed in the fields
class InputTextFilteringOptions {
  InputTextFilteringOptions();
  // a value between 0.5 inclusive and 24 inclusive.
  final maxOneDay = FilteringTextInputFormatter.allow(RegExp(
      r"^(0*(?:0\.[5-9]|[1-9](?:\.\d+)?|1\d(?:\.\d+)?|2[0-4](?:\.\d+)?))$"));
  final doubleOrInt =
      FilteringTextInputFormatter.allow(RegExp(r"^[+-]?\d+(\.\d+)?$"));
}

class ValidationWidget extends StatelessWidget {
  final String validationText;
  final validatorPadding;

  const ValidationWidget(
      {super.key, this.validationText = '', this.validatorPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: validatorPadding,
      child: SizedBox(
        height: 15,
        child: Text(
          validationText,
          style: const TextStyle(
            color: Color.fromARGB(255, 196, 53, 43),
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
