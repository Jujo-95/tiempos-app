import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiempos_app/models/resource_model.dart';

import 'firebase_paths.dart';

class ResourceService {
  static final CollectionReference resourceCollection =
      FirebasePaths.instance.getCollectionByName('resources');

  // Get Resource
  Future<ResourceModel> getResource(String id) async {
    DocumentSnapshot doc = await resourceCollection.doc(id).get();
    return ResourceModel.fromSnapshot(doc);
  }

  // Post Resource
  Future<void> postResource(ResourceModel resource) async {
    return resourceCollection.doc(resource.documentId).set(resource.toMap());
  }

  // Patch Resource
  Future<void> patchResource(String id, Map<String, dynamic> data) async {
    return resourceCollection.doc(id).update(data);
  }

  // Delete Resource
  Future<void> deleteResource(String id) async {
    return resourceCollection.doc(id).delete();
  }
}
