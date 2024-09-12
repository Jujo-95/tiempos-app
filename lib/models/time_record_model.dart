import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

class TimeRecordModel {
  FirebasePaths firebasePaths = FirebasePaths.instance;

  String activity_id;
  String created;
  String id_number;
  String modified = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
  String notes;
  String operation_id;
  num quality;
  double sam;
  String user_id;
  String time_record_id;
  String worker_name;
  String activity_name;
  String operation_name;
  num sam_reference;

  /// create current date

  TimeRecordModel(
      {this.time_record_id = '',
      this.activity_id = '',
      this.created = '',
      this.id_number = '',
      this.modified = '',
      this.notes = "",
      this.operation_id = '',
      this.quality = 0,
      this.sam = 0,
      this.user_id = '',
      this.worker_name = '',
      this.activity_name = '',
      this.operation_name = '',
      this.sam_reference = 0});

  factory TimeRecordModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    T fromNone<T>(Map<String, dynamic> data, String key, {T? ifNone}) {
      return data.containsKey(key) ? data[key] as T : ifNone as T;
    }

    // return AccountModel(
    //   active: fromNone<int>(data, 'active', ifNone: 1),
    // );

    return TimeRecordModel(
      time_record_id: fromNone(data, 'time_record_id', ifNone: ''),
      activity_id: fromNone(data, 'activity_id', ifNone: ''),
      created: fromNone(data, 'created', ifNone: ''),
      id_number: fromNone(data, 'id_number', ifNone: ''),
      modified: fromNone(data, 'modified', ifNone: ''),
      notes: fromNone(data, 'notes', ifNone: ''),
      operation_id: fromNone(data, 'operation_id', ifNone: ''),
      quality: fromNone(data, 'quality', ifNone: 0),
      sam: fromNone(data, 'sam', ifNone: 0),
      user_id: fromNone(data, 'user_id', ifNone: ''),
      worker_name: fromNone(data, 'worker_name', ifNone: ''),
      activity_name: fromNone(data, 'activity_name', ifNone: ''),
      operation_name: fromNone(data, 'operation_name', ifNone: ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time_record_id': time_record_id,
      'activity_id': activity_id,
      'created': created,
      'id_number': id_number,
      'modified': modified,
      'notes': notes,
      'operation_id': operation_id,
      'quality': quality,
      'sam': sam,
      'user_id': user_id,
      'worker_name': worker_name,
      'activity_name': activity_name,
      'operation_name': operation_name,
    };
  }

  // validateTimeRecord(TimeRecordModel timeRecord) {
  //   timeRecord.toMap();
  // }

  // Future<void> addTimeRecord(TimeRecordModel timeRecord) async {
  //   try {
  //     await firebasePaths
  //         .getCollectionByName('time_records')
  //         .add(timeRecord.toMap());
  //   } catch (error) {}
  // }
}
