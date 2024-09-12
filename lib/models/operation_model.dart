import 'package:cloud_firestore/cloud_firestore.dart';

class OperationModel {
  String? documentId;
  int active;
  String activity_id;
  String operation_name;
  String created;
  String operation_id;
  int position;
  String modified;
  String notes;
  num operation_sam;
  String machine_id;

  /// create current date

  OperationModel(
      {this.documentId,
      this.active = 1,
      this.activity_id = "",
      this.operation_name = "",
      this.created = "",
      this.operation_id = "",
      this.position = 0,
      this.modified = "",
      this.notes = "",
      this.operation_sam = 0,
      this.machine_id = ""});

  factory OperationModel.fromSnapshot(DocumentSnapshot snapshot) {
    return OperationModel(
        documentId: snapshot.id,
        active: snapshot['active'],
        activity_id: snapshot['activity_id'],
        operation_name: snapshot['operation_name'],
        created: snapshot['created'],
        operation_id: snapshot['operation_id'],
        position: snapshot['position'],
        modified: snapshot['modified'],
        notes: snapshot['notes'],
        operation_sam: snapshot['operation_sam'],
        machine_id: snapshot['machine_id']);
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'active': active,
      'activity_id': activity_id,
      'operation_name': operation_name,
      'created': created,
      'operation_id': operation_id,
      'position': position,
      'modified': modified,
      'notes': notes,
      'operation_sam': operation_sam,
      'machine_id': machine_id
    };
  }

  static OperationModel readRecordFromCsv(List<dynamic> record, newActivityID) {
    return OperationModel(
        activity_id: newActivityID,
        position: record[0].toInt(),
        operation_id: record[1] is! String ? record[1].toString() : record[1],
        operation_name: record[2] is! String ? record[1].toString() : record[2],
        operation_sam: record[3],
        machine_id: record[4] is! String ? record[4].toString() : record[4],
        notes:
            '{Máquina2: ${record[5]}, Kits: ${record[6]}, Normas Maq 1: ${record[7]}, Normas Maq 2: ${record[8]}, Métodos: ${record[9]}, Subproceso: ${record[10]}, Subensamble: ${record[11]}, CCosto: ${record[12]}}');
  }
}
