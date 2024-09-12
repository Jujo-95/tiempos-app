import 'package:flutter/material.dart';
import 'package:tiempos_app/models/activity_model.dart';

class AddActivityViewModel extends ChangeNotifier {
  TextEditingController activeController = TextEditingController();
  TextEditingController activityIdController = TextEditingController();
  TextEditingController activityNameController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  TextEditingController defaultMinuteRateController = TextEditingController();
  TextEditingController responsablePeopleController = TextEditingController();
  TextEditingController modifiedController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  ActivityModel? activity;

  getEachWorkDaysHoursControllerText(
      List<TextEditingController> workDaysHoursController) {
    return workDaysHoursController
        .map((e) => int.tryParse(e.text) ?? 0)
        .toList();
  }

  ActivityModel mapActivity() {
    return ActivityModel(
      documentId: activity?.documentId,
      active: int.tryParse(activeController.text) ?? 1,
      activity_id: activityIdController.text,
      activity_name: activityNameController.text,
      created: createdController.text,
      default_minute_rate: int.tryParse(defaultMinuteRateController.text) ?? 0,
      responsable_people: responsablePeopleController.text,
      modified: modifiedController.text,
      notes: notesController.text,
    );
  }

  clearFields() {
    activeController.clear();
    activityIdController.clear();
    activityNameController.clear();
    createdController.clear();
    defaultMinuteRateController.clear();
    responsablePeopleController.clear();

    modifiedController.clear();
    notesController.clear();
  }

  // Future<void> addActivity() async {
  //   try {
  //     ActivityModel newActivity = mapActivity();

  //     await newActivity.addActivity(newActivity);

  //     // Clear the input fields after successful addition
  //     clearFields();

  //     //Show a success message or navigate to a different screen
  //   } catch (error) {}
  // }

  // Future<void> editActivity(activityToEdit) async {
  //   try {
  //     ActivityModel editActivity = mapActivity();

  //     editActivity.documentId = activityToEdit.documentId;

  //     await editActivity.editActivity(editActivity);

  //     // Clear the input fields after successful addition
  //     clearFields();

  //     //Show a success message or navigate to a different screen
  //   } catch (error) {}
  // }

  // Future<void> deleteActivity(ActivityModel activityToDelete) async {
  //   try {
  //     await activityToDelete.deleteActivity(activityToDelete);

  //     // Clear the input fields after successful addition
  //     clearFields();

  //     //Show a success message or navigate to a different screen
  //   } catch (error) {}
  // }

  fillActivityToEdit(ActivityModel activityToEdit) {
    activity = activityToEdit;
    activeController.text = activityToEdit.active.toString();
    activityIdController.text = activityToEdit.activity_id.toString();
    activityNameController.text = activityToEdit.activity_name.toString();
    createdController.text = activityToEdit.created.toString();
    defaultMinuteRateController.text =
        activityToEdit.default_minute_rate.toString();
    responsablePeopleController.text =
        activityToEdit.responsable_people.toString();
    modifiedController.text = activityToEdit.modified.toString();
    notesController.text = activityToEdit.notes.toString();
  }
}
