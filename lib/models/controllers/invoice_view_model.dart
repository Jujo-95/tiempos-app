import 'package:flutter/material.dart';
import 'package:tiempos_app/models/invoice_model.dart';

class InvoiceViewModel extends ChangeNotifier {
  TextEditingController documentIdController = TextEditingController();
  TextEditingController invoice_idController = TextEditingController();
  TextEditingController cufeController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController account_idController = TextEditingController();
  TextEditingController account_nameController = TextEditingController();
  TextEditingController registration_nameController = TextEditingController();
  TextEditingController issue_dateController = TextEditingController();
  TextEditingController payment_due_dateController = TextEditingController();
  TextEditingController profile_idController = TextEditingController();
  TextEditingController payable_amountController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  TextEditingController modifiedController = TextEditingController();

  InvoiceModel mapInvoice() {
    return InvoiceModel(
      documentId: documentIdController.text,
      invoice_id: invoice_idController.text,
      cufe: cufeController.text,
      id: idController.text,
      account_id: account_idController.text,
      account_name: account_nameController.text,
      registration_name: registration_nameController.text,
      issue_date: issue_dateController.text,
      payment_due_date: payment_due_dateController.text,
      profile_id: profile_idController.text,
      created: createdController.text,
      modified: modifiedController.text,
      payable_amount: num.parse(payable_amountController.text),
    );
  }

  clearFields() {
    documentIdController.clear();
    invoice_idController.clear();
    cufeController.clear();
    idController.clear();
    account_idController.clear();
    account_nameController.clear();
    registration_nameController.clear();
    issue_dateController.clear();
    payment_due_dateController.clear();
    profile_idController.clear();
    payable_amountController.clear();
    createdController.clear();
    modifiedController.clear();
  }

  fillInvoiceToEdit(InvoiceModel invoiceToEdit) {
    documentIdController.text = invoiceToEdit.documentId.toString();
    invoice_idController.text = invoiceToEdit.invoice_id.toString();
    cufeController.text = invoiceToEdit.cufe.toString();
    idController.text = invoiceToEdit.id.toString();
    account_idController.text = invoiceToEdit.account_id.toString();
    account_nameController.text = invoiceToEdit.account_name.toString();
    registration_nameController.text =
        invoiceToEdit.registration_name.toString();
    issue_dateController.text = invoiceToEdit.issue_date.toString();
    payment_due_dateController.text = invoiceToEdit.payment_due_date.toString();
    profile_idController.text = invoiceToEdit.profile_id.toString();
    payable_amountController.text = invoiceToEdit.payable_amount.toString();
    createdController.text = invoiceToEdit.created.toString();
    modifiedController.text = invoiceToEdit.modified.toString();
  }
}
