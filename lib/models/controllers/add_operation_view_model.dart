import 'package:flutter/material.dart';
import 'package:tiempos_app/models/operation_model.dart';

class AddOperationViewModel extends ChangeNotifier {
  TextEditingController activeController = TextEditingController();
  TextEditingController activityIdController = TextEditingController();
  TextEditingController operationNameController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  TextEditingController operationIdController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController modifiedController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController operationSamController = TextEditingController();

  OperationModel mapOperation() {
    return OperationModel(
      active: int.tryParse(activeController.text) ?? 1,
      activity_id: activityIdController.text,
      operation_name: operationNameController.text,
      created: createdController.text,
      operation_id: operationIdController.text,
      position: int.tryParse(positionController.text) ?? 0,
      modified: modifiedController.text,
      notes: notesController.text,
      operation_sam: num.tryParse(operationSamController.text) ?? 0,
    );
  }

  clearFields() {
    activeController.clear();
    activityIdController.clear();
    operationNameController.clear();
    createdController.clear();
    operationIdController.clear();
    positionController.clear();
    modifiedController.clear();
    notesController.clear();
    operationSamController.clear();
  }

  fillOperationToEdit(OperationModel operationToEdit) {
    activeController.text = operationToEdit.active.toString();
    activityIdController.text = operationToEdit.activity_id.toString();
    operationNameController.text = operationToEdit.operation_name.toString();
    createdController.text = operationToEdit.created.toString();
    operationIdController.text = operationToEdit.operation_id.toString();
    positionController.text = operationToEdit.position.toString();
    modifiedController.text = operationToEdit.modified.toString();
    notesController.text = operationToEdit.notes.toString();
    operationSamController.text = operationToEdit.operation_sam.toString();
  }
}
