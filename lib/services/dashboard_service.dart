import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/models/dashboard_model.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

class DashboardService {
  final CollectionReference dashboardCollection =
      FirebasePaths.instance.getCollectionByName('dashboard');

  static String parseDateString(String dateTimeAsString) {
    Map monthsToText = {
      1: 'Enero',
      2: 'Febrero',
      3: 'Marzo',
      4: 'Abril',
      5: 'Mayo',
      6: 'Junio',
      7: 'Julio',
      8: 'Agosto',
      9: 'Septiembre',
      10: 'Octubre',
      11: 'Noviembre',
      12: 'Diciembre'
    };
    try {
      DateTime dateTime = DateTime.parse(dateTimeAsString);
      String dateSting =
          '${monthsToText[dateTime.month]} ${dateTime.day}, ${dateTime.year}';
      return dateSting;
    } catch (e) {
      return '-';
    }
  }

  static String dateIsoFormat(String dateTimeAsString) {
    DateTime dateTime = DateTime.parse(dateTimeAsString);
    String dateSting =
        dateTime.toIso8601String().substring(0, 10).replaceAll('/', '-');
    return dateSting;
  }

  static String toTimeOfDay(String dateTimeString, BuildContext context) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String time =
        TimeOfDay(hour: dateTime.hour, minute: dateTime.minute).format(context);
    return time;
  }

  // Get Dashboard
  Future<DashboardModel> getDashboard(String id) async {
    DocumentSnapshot doc = await dashboardCollection.doc(id).get();
    return DashboardModel.fromSnapshot(doc);
  }

  // Post Dashboard
  Future<void> postDashboard(DashboardModel dashboard) async {
    try {
      DocumentReference docRef = dashboardCollection.doc();
      dashboard.documentId = docRef.id;
      return docRef.set(dashboard.toMap());
    } catch (e) {
      print('error creating dashboard ${e}');
      throw e;
    }
  }

  // Patch Dashboard
  Future<void> patchDashboard(String id, Map<String, dynamic> data) async {
    return dashboardCollection.doc(id).update(data);
  }

  // Patch Dashboard
  Future<void> deleteDashboard(
    String id,
  ) async {
    return dashboardCollection.doc(id).delete();
  }

  // Get Dashboard by Dashboard ID
  Future<DashboardModel> getDashboardByDashboardId(String dashboardId) async {
    QuerySnapshot doc = await dashboardCollection
        .where('dashboard_id', isEqualTo: dashboardId)
        .get();
    return DashboardModel.fromSnapshot(doc.docs[0]);
  }

  // // Get list of Dashboard
  // Future<List<DashboardModel>> getAllDashboardDashboard(
  //     String dashboardId) async {
  //   DocumentSnapshot doc = await dashboardCollection.get();
  //   return DashboardModel.fromSnapshot(doc);
  //   return DashboardModel.fromSnapshot(doc.docs[0]);
  // }

  // Get Dashboard
  Future<List<DashboardModel>> getDashboardItemsGroupByDate(
      String filterDate) async {
    List<DashboardModel> dashboardItems = [];
    QuerySnapshot snapshots =
        await dashboardCollection.where('date', isEqualTo: filterDate).get();

    for (QueryDocumentSnapshot snapshot in snapshots.docs) {
      DashboardModel data = DashboardModel.fromSnapshot(snapshot);
      dashboardItems.add(data);
    }

    return dashboardItems;
  }

  Stream<QuerySnapshot> get dashboardStream {
    return dashboardCollection.snapshots();
  }
}
