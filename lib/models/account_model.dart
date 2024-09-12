import 'package:tiempos_app/models/invoice_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  int? active;
  String account_id;
  String account_name;
  List<InvoiceModel>? account_invoices;
  String? created;
  String? modified;

  AccountModel({
    this.active = 1,
    this.account_id = "",
    this.account_name = "",
    this.created,
    this.account_invoices = const [],
    this.modified,
  });

  factory AccountModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    T fromNone<T>(Map<String, dynamic> data, String key, {T? ifNone}) {
      return data.containsKey(key) ? data[key] as T : ifNone as T;
    }

    return AccountModel(
      active: fromNone<int>(data, 'active', ifNone: 1),
      account_id: fromNone<String>(data, 'account_id', ifNone: ''),
      account_name: fromNone<String>(data, 'account_name', ifNone: ''),
      created: fromNone<String>(data, 'created', ifNone: ''),
      modified: fromNone<String>(data, 'modified', ifNone: ''),
      account_invoices: fromNone<List>(data, 'account_invoices', ifNone: [])
          .map((invoice) => InvoiceModel.fromSnapshot(invoice))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'account_id': account_id,
      'account_name': account_name,
      'created': created,
      'modified': modified,
      'account_invoices': account_invoices!.isNotEmpty
          ? account_invoices!.map((invoice) => invoice.toMap()).toList()
          : [],
    };
  }
}
