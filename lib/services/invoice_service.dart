import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

import '../models/invoice_model.dart';

class InvoiceService {
  static CollectionReference invoiceCollection =
      FirebasePaths.instance.getCollectionByName('invoices');

  // Get Invoice
  Future<InvoiceModel> getInvoice(String id) async {
    DocumentSnapshot doc = await invoiceCollection.doc(id).get();
    return InvoiceModel.fromSnapshot(doc);
  }

  // Post Invoice
  Future<void> postInvoice(InvoiceModel invoice) async {
    DocumentReference<Object?> docRef = invoiceCollection.doc();
    invoice.invoice_id = docRef.id;
    invoice.created = DateTime.now().toIso8601String();
    docRef.set(invoice.toMap());
  }

  // Patch Invoice
  Future<void> patchInvoice(String id, InvoiceModel invoice) async {
    invoice.modified = DateTime.now().toIso8601String();
    return invoiceCollection.doc(invoice.documentId).update(invoice.toMap());
  }

  // Delete Invoice
  Future<void> deleteInvoice(String id) async {
    return invoiceCollection.doc(id).delete();
  }

  // Get Invoice by Invoice ID
  Future<InvoiceModel> getInvoiceByInvoiceId(String invoiceId) async {
    QuerySnapshot doc =
        await invoiceCollection.where('invoice_id', isEqualTo: invoiceId).get();
    return InvoiceModel.fromSnapshot(doc.docs[0]);
  }

  Future<List<InvoiceModel>> fetchAllItems() async {
    QuerySnapshot querySnapshot = await invoiceCollection.get();

    List<InvoiceModel> items = [];
    querySnapshot.docs.forEach((doc) {
      items.add(InvoiceModel.fromSnapshot(doc));
    });

    return items;
  }
}
