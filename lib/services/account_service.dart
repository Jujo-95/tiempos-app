import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/models/account_model.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

class AccountService {
  static final CollectionReference accountCollection =
      FirebasePaths.instance.getCollectionByName('accounts');

  // Get Account
  Future<AccountModel> getAccount(String id) async {
    DocumentSnapshot doc = await accountCollection.doc(id).get();
    return AccountModel.fromSnapshot(doc);
  }

  // Post Account
  Future<void> postAccount(AccountModel account) async {
    DocumentReference<Object?> docRef = accountCollection.doc();
    account.account_id = docRef.id;
    account.created = DateTime.now().toIso8601String();
    docRef.set(account.toMap());
  }

  // Patch Account
  Future<void> patchAccount(String id, AccountModel account) async {
    account.modified = DateTime.now().toIso8601String();
    return accountCollection.doc(account.account_id).update(account.toMap());
  }

  // Delete Account
  Future<void> deleteAccount(String id) async {
    return accountCollection.doc(id).delete();
  }

  // Get Account by Account ID
  Future<AccountModel> getAccountByAccountId(String accountId) async {
    QuerySnapshot doc =
        await accountCollection.where('account_id', isEqualTo: accountId).get();
    return AccountModel.fromSnapshot(doc.docs[0]);
  }

  Future<List<AccountModel>> fetchAllItems() async {
    QuerySnapshot querySnapshot = await accountCollection.get();

    List<AccountModel> items = [];
    querySnapshot.docs.forEach((doc) {
      items.add(AccountModel.fromSnapshot(doc));
    });

    return items;
  }
}
