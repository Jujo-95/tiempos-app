import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/time_record_model.dart';

class TimeRecordService {
  static final CollectionReference timeRecordsCollection =
      FirebasePaths.instance.getCollectionByName('time_records');

  // Get Resource
  Future<TimeRecordModel> getTimeRecord(String id) async {
    DocumentSnapshot doc = await timeRecordsCollection.doc(id).get();
    return TimeRecordModel.fromSnapshot(doc);
  }

  /// Get time record stream grater than 'date'
  Stream<QuerySnapshot> getFilteredStream(date) {
    // Get time record stream grater than date
    return timeRecordsCollection
        .where('created', isGreaterThan: date)
        .snapshots();
  }

  // Post TimeRecord
  Future<void> postTimeRecord(TimeRecordModel timeRecord) async {
    DocumentReference documentReference = timeRecordsCollection.doc();
    timeRecord.time_record_id = documentReference.id;
    timeRecord.created = DateTime.now().toIso8601String();
    return documentReference.set(timeRecord.toMap());
  }

  // Patch TimeRecord
  Future<void> patchTimeRecord(String id, Map<String, dynamic> data) async {
    return timeRecordsCollection.doc(id).update(data);
  }

  // Delete TimeRecord
  Future<void> deleteTimeRecord(String id) async {
    return timeRecordsCollection.doc(id).delete();
  }

  // Delete TimeRecord That contains Persoon
  Future<void> deleteResourcesByKey(String value, String key) async {
    QuerySnapshot resourcesmatchPersonId =
        await timeRecordsCollection.where(key, isEqualTo: value).get();

    resourcesmatchPersonId.docs.forEach((doc) {
      doc.reference.delete();
    });
  }

  List<TimeRecordModel> toListOfTimeRecords(List listOfDocumentsSnapshot) {
    try {
      return listOfDocumentsSnapshot
          .map((item) => TimeRecordModel.fromSnapshot(item))
          .toList() as List<TimeRecordModel>;
    } catch (e) {
      rethrow;
    }
  }
}
