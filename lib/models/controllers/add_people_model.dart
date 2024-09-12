import 'package:flutter/material.dart';
import 'package:tiempos_app/models/people_model.dart';

class AddPersonViewModel extends ChangeNotifier {
  TextEditingController activeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  TextEditingController defaultHourlyRateController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController modifiedController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  List<TextEditingController> workDaysHoursController =
      List.generate(7, (index) => TextEditingController());

  getEachWorkDaysHoursControllerText(
      List<TextEditingController> workDaysHoursController) {
    return workDaysHoursController
        .map((e) => int.tryParse(e.text) ?? 0)
        .toList();
  }

  PeopleModel mapPerson() {
    var workDaysHoursControllerList =
        getEachWorkDaysHoursControllerText(workDaysHoursController);

    return PeopleModel(
      city: cityController.text,
      country: countryController.text,
      created: createdController.text,
      default_hourly_rate: int.tryParse(defaultHourlyRateController.text) ?? 0,
      department: departmentController.text,
      email: emailController.text,
      end_date: endDateController.text,
      first_name: firstNameController.text,
      id_number: idNumberController.text,
      job_title: jobTitleController.text,
      last_name: lastNameController.text,
      modified: modifiedController.text,
      notes: notesController.text,
      start_date: startDateController.text,
      user_id: userIdController.text,
      work_days_hours: workDaysHoursControllerList,
    );
  }

  clearFields() {
    activeController.clear();
    cityController.clear();
    countryController.clear();
    createdController.clear();
    defaultHourlyRateController.clear();
    departmentController.clear();
    emailController.clear();
    endDateController.clear();
    firstNameController.clear();
    idNumberController.clear();
    jobTitleController.clear();
    lastNameController.clear();
    modifiedController.clear();
    notesController.clear();
    startDateController.clear();
    userIdController.clear();
    workDaysHoursController.clear();
  }

  fillPersonToEdit(PeopleModel peopleToEdit) {
    activeController.text = peopleToEdit.active.toString();
    cityController.text = peopleToEdit.city.toString();
    countryController.text = peopleToEdit.country.toString();
    createdController.text = peopleToEdit.created.toString();
    defaultHourlyRateController.text =
        peopleToEdit.default_hourly_rate.toString();
    departmentController.text = peopleToEdit.department.toString();
    emailController.text = peopleToEdit.email.toString();
    endDateController.text = peopleToEdit.end_date.toString();
    firstNameController.text = peopleToEdit.first_name.toString();
    idNumberController.text = peopleToEdit.id_number.toString();
    jobTitleController.text = peopleToEdit.job_title.toString();
    lastNameController.text = peopleToEdit.last_name.toString();
    modifiedController.text = peopleToEdit.modified.toString();
    notesController.text = peopleToEdit.notes.toString();
    startDateController.text = peopleToEdit.start_date.toString();
    userIdController.text = peopleToEdit.user_id.toString();
    workDaysHoursController[0].text =
        peopleToEdit.work_days_hours[0].toString();
    workDaysHoursController[1].text =
        peopleToEdit.work_days_hours[1].toString();
    workDaysHoursController[2].text =
        peopleToEdit.work_days_hours[2].toString();
    workDaysHoursController[3].text =
        peopleToEdit.work_days_hours[3].toString();
    workDaysHoursController[4].text =
        peopleToEdit.work_days_hours[4].toString();
    workDaysHoursController[5].text =
        peopleToEdit.work_days_hours[5].toString();
    workDaysHoursController[6].text =
        peopleToEdit.work_days_hours[6].toString();
  }
}
