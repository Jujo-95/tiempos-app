import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePaths {
  FirebasePaths._privateConstructor();
  static final FirebasePaths _instance = FirebasePaths._privateConstructor();
  static FirebasePaths get instance => _instance;

  String currentUserId = FirebaseAuth.instance.currentUser!.email ??
      FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> getCollectionByName(
      String collectionName) {
    String currentUserId = FirebaseAuth.instance.currentUser!.email ??
        FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('data')
        .doc(currentUserId)
        .collection(collectionName);
  }

  DocumentReference<Map<String, dynamic>> editCollectionByNameAndId(
          String collectionName, String? documentId) =>
      FirebaseFirestore.instance
          .collection('data')
          .doc(currentUserId)
          .collection(collectionName)
          .doc(documentId);

  ///EXAMPLE OF SOURCE AND DESTINATION DOC REFERENCE
  /// DocumentReference sourceDocRef = FirebaseFirestore.instance
  ///    .collection('data')
  ///    .doc('kRlYILOvrWbN0g63FBd1mjzMs722');
  ///DocumentReference destinationDocRef = FirebaseFirestore.instance
  ///    .collection('data')
  ///    .doc('suleasas01@gmail.com');""";
  void migrationCopyContent(DocumentReference sourceDocRef,
      DocumentReference destinationDocRef) async {
    //list of collections to migrate
    List collections = [
      'activities',
      'operations',
      'time_records',
      'resources',
      'people'
    ];

    for (var collection in collections) {
      QuerySnapshot snapshot = await sourceDocRef.collection(collection).get();

      for (var snap in snapshot.docs) {
        destinationDocRef
            .collection(collection)
            .doc(snap.id)
            .set(snap.data() as Map<String, dynamic>);
      }
    }
  }
}
