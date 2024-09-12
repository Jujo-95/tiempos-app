import 'package:flutter/material.dart';
import 'package:tiempos_app/models/dashboard_model.dart';

class AddDashboardViewModel extends ChangeNotifier {
  TextEditingController dateController = TextEditingController();
  TextEditingController efficiencyController = TextEditingController(text: '1');
  TextEditingController module_nameController = TextEditingController();
  TextEditingController peopleController = TextEditingController();
  TextEditingController process_idController = TextEditingController();
  TextEditingController scheduled_hoursController = TextEditingController();
  TextEditingController dashboard_samController = TextEditingController();

  List<dynamic> operationList = [];
  List<dynamic> peopleList = [];
  String startTime = DateTime(2002).toIso8601String();
  int deltaMinutes = 60;

  DashboardModel mapDashboard() {
    int avilableWorkingTimeHours = peopleList.length * 8 * 60;
    int scheduled_hours = int.parse(scheduled_hoursController.text);
    num dashboard_sam = num.parse(dashboard_samController.text);
    num efficiency = num.parse(efficiencyController.text);

    List<DashboardItemModel> dashboard =
        DashboardItemModel.generateDashboardItemModelList(
            scheduled_hours,
            startTime,
            avilableWorkingTimeHours,
            dashboard_sam,
            efficiency,
            deltaMinutes);
    print(dashboard);

    return DashboardModel(
        dashboard_sam: dashboard_sam,
        date: dateController.text,
        efficiency: efficiency,
        module_name: module_nameController.text,
        process_id: process_idController.text,
        people: peopleList,
        operations: operationList,
        start_time: startTime,
        dashboard: dashboard);
  }

  clearFields() {
    dateController.clear();
    efficiencyController.clear();
    module_nameController.clear();
    peopleController.clear();
    process_idController.clear();
    scheduled_hoursController.clear();
    dashboard_samController.clear();
    peopleList.clear();
  }

  fillActivityToEdit(DashboardModel dashboardToEdit) {
    dateController.text = dashboardToEdit.date.toString();
    efficiencyController.text = dashboardToEdit.efficiency.toString();
    module_nameController.text = dashboardToEdit.module_name.toString();
    peopleList = dashboardToEdit.people;
    peopleController.text = dashboardToEdit.people.toString();
    process_idController.text = dashboardToEdit.process_id.toString();
    scheduled_hoursController.text = dashboardToEdit.scheduled_hours.toString();
    dashboard_samController.text = dashboardToEdit.dashboard_sam.toString();
  }
}
