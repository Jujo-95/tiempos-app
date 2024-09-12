import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/dropdown_multiselect/custom_dropdown_multiselector.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/operations_service.dart';

import '../../../../../models/activity_model.dart';

class DropdownButtonFromFirestore extends StatefulWidget {
  ActivityService activityService = ActivityService();
  OperationService operationService = OperationService();
  final Function(num) onSumChanged;
  final Function(String) onActivitySelected;
  final Function(List<OperationModel>) onSelectedOperations;
  String? initalActivity;
  List<String>? initialOperations;
  List<OperationModel>? selectedItems;
  InputDecoration? inputDecoration;

  DropdownButtonFromFirestore(
      {Key? key,
      required this.onSumChanged,
      required this.onActivitySelected,
      this.initalActivity,
      this.selectedItems,
      this.inputDecoration,
      required this.onSelectedOperations})
      : super(key: key);

  @override
  _DropdownButtonFromFirestoreState createState() =>
      _DropdownButtonFromFirestoreState();
}

class _DropdownButtonFromFirestoreState
    extends State<DropdownButtonFromFirestore> {
  ActivityModel dropdownValue = ActivityModel();
  OperationModel operationDropdownValue = OperationModel();
  List<ActivityModel> items = [];
  List<OperationModel> oerationItemsList = [];
  List<OperationModel> selectedOperations = [];
  num sum = 0;

  @override
  void initState() {
    super.initState();
    _getActivityItems();
  }

  Future<void> _getActivityItems() async {
    try {
      List<ActivityModel> activityItems =
          await widget.activityService.fetchAllItems();

      if (widget.initalActivity == null) {
        setState(() {
          List<ActivityModel> initList = [
            ActivityModel(activity_id: '', activity_name: '')
          ];
          //ActivityModel(activity_id: '', activity_name: '')
          items = initList + activityItems;
          dropdownValue = items.isNotEmpty
              ? items.first
              : ActivityModel(activity_id: '', activity_name: '');
        });
      } else {
        setState(() {
          items = activityItems;
          ActivityModel initialActivityModel = items
              .where((element) => element.activity_id == widget.initalActivity!)
              .first;
          dropdownValue =
              items.isNotEmpty ? initialActivityModel : ActivityModel();
          _getOperationItems(initialActivityModel);
        });
      }
    } catch (e) {
      print('Error getting documents: $e');
    }
  }

  Future<void> _getOperationItems(ActivityModel documentId) async {
    try {
      List<OperationModel> operationItems =
          await widget.operationService.fetchAllItemsByActivity(documentId);
      setState(() {
        oerationItemsList = operationItems;
        operationDropdownValue = oerationItemsList.isNotEmpty
            ? oerationItemsList.first
            : OperationModel();
      });
    } catch (e) {
      print('Error getting documents: $e');
    }
  }

  void sumSam() {
    sum = 0;
    for (var operation in selectedOperations) {
      sum = operation.operation_sam + sum;
    }
    widget.onSumChanged(sum);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<ActivityModel>(
          decoration: widget.inputDecoration,
          borderRadius: BorderRadius.circular(10.0),
          isExpanded: true,
          value: dropdownValue,
          style: TextStyle(overflow: TextOverflow.visible),
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          onChanged: (ActivityModel? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
              widget.onActivitySelected(dropdownValue.activity_id);
              _getOperationItems(value);
            });
          },
          items:
              items.map<DropdownMenuItem<ActivityModel>>((ActivityModel value) {
            return DropdownMenuItem<ActivityModel>(
              value: value,
              child: Text('${value.activity_id} ${value.activity_name}'),
            );
          }).toList(),
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          // decoration: BoxDecoration(
          //     borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          //     border: Border.all(color: Colors.grey.shade300, width: 1)),
          child: MultiSelectDropdownWidget<OperationModel>(
            items: oerationItemsList,
            displayItem: (item) =>
                "${item.position}. ${item.operation_name} (${item.operation_sam})", // Change to your property to display
            onSelectionChanged: (selectedItems) {
              setState(() {
                selectedOperations = selectedItems;
                widget.onSelectedOperations(selectedOperations);
                sumSam();
              });

              // Handle selected items
            },
          ),
        )
      ],
    );
  }

  InputDecoration dropdownButtonDecorationBuilder() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
    );
  }

  RoundedRectangleBorder childOperationsListBuilderShape() {
    return RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ));
  }
}
