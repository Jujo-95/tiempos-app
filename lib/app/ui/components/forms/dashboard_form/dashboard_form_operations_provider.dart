import 'package:flutter/material.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/operations_service.dart';
import 'package:tiempos_app/services/people_service.dart';

import '../../../../../models/people_model.dart';

class DashboardFormOperationProvider with ChangeNotifier {
  OperationService operationService = OperationService();
  ActivityModel selectedActivity =
      ActivityModel(activity_id: '', activity_name: '');
  List<OperationModel> itemsOperations = [];
  Set<String> selectedItems = {};
  bool selectAllBool = false;

  Future<List<OperationModel>> getOperationItems(
      ActivityModel documentId) async {
    itemsOperations =
        await operationService.fetchAllItemsByActivity(documentId);
    print(itemsOperations);

    return itemsOperations;
  }

  List<String?> getItemsId(List<OperationModel> selectedPeopleModel) {
    return selectedPeopleModel.map((e) => e.documentId).toList();
  }

  selectActivity(value) {
    selectedActivity = value;
  }

  clearOperations() {
    selectedItems.clear();
    notifyListeners();
  }

  void selectAll() {
    Set<String> itemsOperationsSet =
        itemsOperations.map((e) => e.documentId ?? '').toSet();
    if (selectAllBool) {
      selectedItems = itemsOperationsSet;
    } else {
      selectedItems.clear();
    }

    notifyListeners();
  }

  void toggleItemSelection(OperationModel item) {
    if (selectedItems.contains(item.documentId.toString())) {
      selectedItems.remove(item.documentId.toString());
    } else {
      selectedItems.add(item.documentId.toString());
    }

    print('the selected items are: ' + selectedItems.toString());

    notifyListeners();
  }
}
