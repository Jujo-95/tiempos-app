import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class GenericSearchController extends StatefulWidget {
  final Function(String) onTextChanged;
  String searchText;

  GenericSearchController(
      {Key? key, required this.onTextChanged, required this.searchText})
      : super(key: key);

  @override
  _GenericSearchControllerState createState() =>
      _GenericSearchControllerState();
}

class _GenericSearchControllerState extends State<GenericSearchController> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onTextChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldFormHeader(
      hintText: 'Buscar',
      controller: _controller,
    );
  }
}

class FilterSnapshot {
  static List<QueryDocumentSnapshot<Object?>> filterSnapshot(
      AsyncSnapshot snapshot, String searchText) {
    return snapshot.data!.docs
        .where((doc) => doc
            .data()
            .toString()
            .toLowerCase()
            .trim()
            .contains(searchText.toLowerCase().trim()))
        .toList();
  }
}
