import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  String? documentId;
  String cufe;
  String id;
  String account_id;
  String account_name;
  String registration_name;
  String issue_date;
  String payment_due_date;
  String profile_id;
  num? payable_amount;

  String invoice_id;

  String created;

  String modified;

  InvoiceModel(
      {this.documentId,
      this.invoice_id = '',
      this.cufe = '',
      this.id = '',
      this.account_id = '',
      this.account_name = '',
      this.registration_name = '',
      this.issue_date = '',
      this.payment_due_date = '',
      this.profile_id = '',
      this.payable_amount,
      this.created = '',
      this.modified = ''});

  factory InvoiceModel.fromSnapshot(DocumentSnapshot snapshot) {
    return InvoiceModel(
      documentId: snapshot.id,
      cufe: snapshot["cufe"],
      id: snapshot["id"],
      account_id: snapshot["account_id"],
      account_name: snapshot["account_name"],
      registration_name: snapshot["registration_name"],
      issue_date: snapshot["issue_date"],
      payment_due_date: snapshot["payment_due_date"],
      profile_id: snapshot["profile_id"],
      payable_amount: snapshot["payable_amount"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "cufe": cufe,
      "id": id,
      "account_id": account_id,
      "account_name": account_name,
      "registration_name": registration_name,
      "issue_date": issue_date,
      "payment_due_date": payment_due_date,
      "profile_id": profile_id,
      "payable_amount": payable_amount,
    };
  }
}
