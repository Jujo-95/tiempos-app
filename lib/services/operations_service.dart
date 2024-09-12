import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

import '../models/operation_model.dart';

class OperationService {
  static final CollectionReference operationCollection =
      FirebasePaths.instance.getCollectionByName('operations');

  // Get Operation
  Future<OperationModel> getOperation(String id) async {
    DocumentSnapshot doc = await operationCollection.doc(id).get();
    return OperationModel.fromSnapshot(doc);
  }

  // Post Operation
  Future<void> postOperation(OperationModel operation) async {
    DocumentReference docRef = operationCollection.doc();
    operation.documentId = docRef.id;
    return docRef.set(operation.toMap());
  }

  // Patch Operation
  Future<void> patchOperation(String id, Map<String, dynamic> data) async {
    return operationCollection.doc(id).update(data);
  }

  Future<void> deleteOperation(String id) async {
    return operationCollection.doc(id).delete();
  }

  Future<List<OperationModel>> fetchAllItemsByActivity(
      ActivityModel activityDocumentId) async {
    QuerySnapshot querySnapshot;

    querySnapshot = await operationCollection
        .where('activity_id', isEqualTo: activityDocumentId.activity_id)
        .orderBy('position')
        .get();

    List<OperationModel> items = [];
    querySnapshot.docs.forEach((doc) {
      items.add(OperationModel.fromSnapshot(doc));
    });
    return items;
  }

  Stream<QuerySnapshot<Object?>> getOperationsByActivity(
      ActivityModel activity) {
    Stream<QuerySnapshot<Object?>> querySnapshot = operationCollection
        .where('activity_id', isEqualTo: activity.activity_id)
        .orderBy('position')
        .snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> get operationStream {
    return operationCollection.snapshots();
  }
}
