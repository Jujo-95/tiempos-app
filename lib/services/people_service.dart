import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/people_model.dart';

class PeopleService {
  final CollectionReference peopleCollection =
      FirebasePaths.instance.getCollectionByName('people');

  // Get People
  Future<PeopleModel> getPeople(String id) async {
    DocumentSnapshot doc = await peopleCollection.doc(id).get();
    return PeopleModel.fromSnapshot(doc);
  }

  // Post People
  Future<void> postPeople(PeopleModel people) async {
    return peopleCollection.doc(people.documentId).set(people.toMap());
  }

  // Patch People
  Future<void> patchPeople(String id, Map<String, dynamic> data) async {
    return peopleCollection.doc(id).update(data);
  }

  // Delete People
  Future<void> deletePerson(String id) async {
    return peopleCollection.doc(id).delete();
  }

  // Get People by People ID
  Future<PeopleModel> getPeopleByPeopleId(String peopleId) async {
    QuerySnapshot doc =
        await peopleCollection.where('people_id', isEqualTo: peopleId).get();
    return PeopleModel.fromSnapshot(doc.docs[0]);
  }

  Future<List<PeopleModel>> fetchAllItems() async {
    QuerySnapshot querySnapshot = await peopleCollection.get();

    List<PeopleModel> items = [];
    querySnapshot.docs.forEach((doc) {
      items.add(PeopleModel.fromSnapshot(doc));
    });

    return items;
  }

  Stream<QuerySnapshot> get peopleStream {
    return peopleCollection.snapshots();
  }
}
