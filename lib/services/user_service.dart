import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/user_model.dart';

class UserService {
  static final CollectionReference userCollection =
      FirebasePaths.instance.getCollectionByName('users');

  // Get User
  Future<UserModel> getUser(String id) async {
    DocumentSnapshot doc = await userCollection.doc(id).get();
    return UserModel.fromSnapshot(doc);
  }

  // Get User by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot doc =
          await userCollection.where('email', isEqualTo: email).limit(1).get();
      return UserModel.fromSnapshot(doc.docs.first);
    } catch (e) {}
  }

  // Post User
  Future<void> postUser(UserModel userModel) async {
    DocumentReference docRef = userCollection.doc();
    userModel.created = DateTime.now().toIso8601String();
    userModel.documentId = docRef.id;
    return docRef.set(userModel.toMap());
  }

  // Patch User
  Future<void> patchUser(String id, UserModel userModel) async {
    userModel.modified = DateTime.now().toIso8601String();
    userModel.toMap();
    return userCollection.doc(id).update(userModel.toMap());
  }

  // Delete User
  Future<void> deleteUser(UserModel userModel) async {
    return userCollection.doc(userModel.documentId).delete();
  }

  // Get User by User ID
  Future<UserModel> getUserByUserId(String UserId) async {
    QuerySnapshot doc =
        await userCollection.where('user_id', isEqualTo: UserId).get();
    return UserModel.fromSnapshot(doc.docs[0]);
  }

  // Get User
  Future<List<UserModel>> getUserItemsGroupByDate(String filterDate) async {
    List<UserModel> UserItems = [];
    QuerySnapshot snapshots =
        await userCollection.where('date', isEqualTo: filterDate).get();

    for (QueryDocumentSnapshot snapshot in snapshots.docs) {
      UserModel data = UserModel.fromSnapshot(snapshot);
      UserItems.add(data);
    }

    return UserItems;
  }

  createUserInUserTable(String email) {
    try {
      UserModel userModel = UserModel(email: email);
      postUser(userModel);
    } catch (e) {
      print('Unable to create user for: $email  -- $e');
    }
  }
}
