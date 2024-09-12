import 'package:flutter/material.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/people_service.dart';

import '../../../../../models/people_model.dart';

class DashboardFormPeopleProvider with ChangeNotifier {
  List<PeopleModel> items = [];
  List<PeopleModel> selectedItems = [];
  List<String?> selectedItemsCast = [];
  PeopleService peopleService = PeopleService();
  ActivityService activityService = ActivityService();
  List<ActivityModel> itemsActivities = [];
  List<ActivityModel> selectedActivities = [];
  List<OperationModel> itemsOperations = [];
  List<OperationModel> selectedOperations = [];

  // List<PeopleModel> get items => _items;
  // Set<PeopleModel> get selectedItems => _selectedItems;

  Future<void> getPeopleItems() async {
    try {
      items = await peopleService.fetchAllItems();
      print('getpeopleItems initial state');
    } catch (e) {
      print('Error getting documents: $e');
    }
    notifyListeners();
  }

  Future<void> getActivitiesItems() async {
    try {
      resetSelections();
      itemsActivities = await activityService.fetchAllItems();
      print('getpeopleItems initial state');
    } catch (e) {
      print('Error getting documents: $e');
    }
    notifyListeners();
  }

  List<String?> getItemsId(List<PeopleModel> selectedPeopleModel) {
    return selectedPeopleModel.map((e) => e.documentId).toList();
  }

  void toggleItemSelection(PeopleModel item) {
    selectedItemsCast = getItemsId(selectedItems);
    String? itemCast = item.documentId;
    if (selectedItemsCast.contains(itemCast)) {
      selectedItemsCast.remove(itemCast);
      selectedItems.remove(item);
    } else {
      selectedItemsCast.add(itemCast);
      selectedItems.add(item);
    }

    notifyListeners();
  }

  void toggleActivitiesSelection(OperationModel activity) {}

  void resetSelections() {
    selectedItems.clear();
    selectedItemsCast.clear();
  }

  void resetAll() {
    items.clear();
    selectedItems.clear();
    selectedItemsCast.clear();
    notifyListeners();
    getPeopleItems(); // Reload the items from the service
  }
}
