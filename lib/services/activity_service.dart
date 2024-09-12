import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

import '../models/activity_model.dart';

class ActivityService {
  static final CollectionReference activityCollection =
      FirebasePaths.instance.getCollectionByName('activities');

  // Get Activity
  Future<ActivityModel> getActivity(String id) async {
    {}
    DocumentSnapshot doc = await activityCollection.doc(id).get();
    return ActivityModel.fromSnapshot(doc);
  }

  // Post Activity
  Future<void> postActivity(ActivityModel activity) async {
    DocumentReference<Object?> docRef = activityCollection.doc();
    activity.documentId = docRef.id;
    activity.activity_id = docRef.id;
    activity.created = DateTime.now().toIso8601String();
    docRef.set(activity.toMap());
  }

  // Patch Activity
  Future<void> patchActivity(String id, ActivityModel activity) async {
    activity.modified = DateTime.now().toIso8601String();
    return activityCollection.doc(activity.documentId).update(activity.toMap());
  }

  // Delete Activity
  Future<void> deleteActivity(String id) async {
    return activityCollection.doc(id).delete();
  }

  // Get Activity by Activity ID
  Future<ActivityModel> getActivityByActivityId(String activityId) async {
    QuerySnapshot doc = await activityCollection
        .where('activity_id', isEqualTo: activityId)
        .get();
    return ActivityModel.fromSnapshot(doc.docs[0]);
  }

  Future<List<ActivityModel>> fetchAllItems() async {
    QuerySnapshot querySnapshot = await activityCollection.get();

    List<ActivityModel> items = [];
    querySnapshot.docs.forEach((doc) {
      items.add(ActivityModel.fromSnapshot(doc));
    });

    return items;
  }

  Stream<QuerySnapshot> get activityStream {
    return activityCollection.snapshots();
  }
}
