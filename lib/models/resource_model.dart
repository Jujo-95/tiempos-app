import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

class ResourceModel {
  String? documentId;
  int active;
  List operations;
  String resource_name;
  String created;
  String resource_id;
  String modified;
  String notes;

  /// create current date

  ResourceModel({
    this.documentId,
    this.active = 1,
    this.operations = const [],
    this.resource_name = "",
    this.created = "",
    this.resource_id = "",
    this.modified = "",
    this.notes = "",
  });

  factory ResourceModel.fromSnapshot(DocumentSnapshot<Object?> snapshot) {
    return ResourceModel(
      documentId: snapshot.id,
      active: snapshot['active'],
      operations: snapshot['operations'],
      resource_name: snapshot['resource_name'],
      created: snapshot['created'],
      resource_id: snapshot['resource_id'],
      modified: snapshot['modified'],
      notes: snapshot['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'active': active,
      'operations': operations,
      'resource_name': resource_name,
      'created': created,
      'resource_id': resource_id,
      'modified': modified,
      'notes': notes,
    };
  }
}
