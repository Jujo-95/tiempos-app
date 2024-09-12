import 'package:flutter/material.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/operations_service.dart';
import 'package:tiempos_app/services/people_service.dart';

import '../../../../../models/people_model.dart';

class DashboardFormActivitiesProvider with ChangeNotifier {
  List<String?> selectedOperationsCast = [];
  ActivityService activityService = ActivityService();
  OperationService operationService = OperationService();
  List<ActivityModel> itemsActivities = [];
  ActivityModel selectedActivity =
      ActivityModel(activity_id: 'Seleccionar ', activity_name: 'referencia');
  List<OperationModel> itemsOperations = [];
  List<OperationModel> selectedOperations = [];
  List<ActivityModel> _items = [];

  List<ActivityModel> get items => _items;
  //ActivityModel get selectedActivity => _selectedActivity;
  // Set<PeopleModel> get selectedItems => _selectedItems;

  Future<List<ActivityModel>> getActivitiesItems() async {
    _items = await activityService.fetchAllItems();
    notifyListeners();
    return _items;
  }

  void setActivity(ActivityModel value) {
    selectedActivity = value;
  }

  Future<List<OperationModel>> getOperationItems(
      ActivityModel activityId) async {
    return itemsOperations =
        await operationService.fetchAllItemsByActivity(activityId);
  }

  List<String?> getItemsId(List<OperationModel> selectedPeopleModel) {
    return selectedPeopleModel.map((e) => e.documentId).toList();
  }

  void toggleItemSelection(OperationModel item) {
    List<String?> selectedOperationsCast = getItemsId(selectedOperations);
    String? selectedOperationId = item.documentId;
    if (selectedOperationsCast.contains(selectedOperationId)) {
      selectedOperationsCast.remove(selectedOperationId);
      selectedOperations.remove(item);
    } else {
      selectedOperationsCast.add(selectedOperationId);
      selectedOperations.add(item);
    }
    notifyListeners();
  }
}
