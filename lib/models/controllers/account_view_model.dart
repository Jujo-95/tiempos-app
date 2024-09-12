import 'package:flutter/material.dart';
import 'package:tiempos_app/models/account_model.dart';

class AccountViewModel extends ChangeNotifier {
  TextEditingController activeController = TextEditingController();
  TextEditingController createdController = TextEditingController();
  TextEditingController modifiedController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountIdController = TextEditingController();

  AccountModel mapAccount() {
    return AccountModel(
      created: createdController.text,
      modified: modifiedController.text,
      account_name: accountNameController.text,
      account_id: accountIdController.text,
    );
  }

  clearFields() {
    activeController.clear();
    createdController.clear();
    modifiedController.clear();
    accountNameController.clear();
    accountIdController.clear();
  }

  fillAccountToEdit(AccountModel accountToEdit) {
    activeController.text = accountToEdit.active.toString();
    createdController.text = accountToEdit.created.toString();
    modifiedController.text = accountToEdit.modified.toString();
    accountNameController.text = accountToEdit.account_name.toString();
    accountIdController.text = accountToEdit.account_id.toString();
  }
}
