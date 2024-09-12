import 'package:flutter/material.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/resource_model.dart';

//
class ResourceViewModelEdit extends ResourceModel {
  final ResourceModel? resourceToEdit;
  ResourceViewModelEdit({
    this.resourceToEdit,
  });

  @override
  TextEditingController activeController = TextEditingController();
  TextEditingController resourceIdController = TextEditingController();
  TextEditingController resourceNameController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  TextEditingController modifiedController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController operationsController = TextEditingController();
  @override
  fillRrecordToEdit() {
    activeController.text = resourceToEdit!.active.toString();
    resourceIdController.text = resourceToEdit!.resource_id.toString();
    resourceNameController.text = resourceToEdit!.resource_name.toString();
    createdController.text = resourceToEdit!.created.toString();
    modifiedController.text = resourceToEdit!.modified.toString();
    notesController.text = resourceToEdit!.notes.toString();
    operationsController.text = resourceToEdit!.operations.join(', ');
  }

  ResourceModel mapResource() {
    return ResourceModel(
      active: int.tryParse(activeController.text) ?? 1,
      operations: List<String>.from(operationsController.text.split(',')),
      resource_id: resourceIdController.text,
      resource_name: resourceNameController.text,
      created: createdController.text,
      modified: modifiedController.text,
      notes: notesController.text,
    );
  }

  clearFields() {
    activeController.clear();
    resourceIdController.clear();
    resourceNameController.clear();
    createdController.clear();
    modifiedController.clear();
    notesController.clear();
  }
}
