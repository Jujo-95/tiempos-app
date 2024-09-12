import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/account_model.dart';
import 'package:tiempos_app/services/account_service.dart';
import '../../../../models/controllers/account_view_model.dart';

class AccountForm extends StatefulWidget {
  final bool edit;
  final AccountModel? accountToEdit;

  const AccountForm({
    super.key,
    this.edit = false,
    this.accountToEdit,
  });

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  AccountViewModel accountViewModel = AccountViewModel();
  AccountService accountService = AccountService();

  Map validationOptions = {};

  @override
  Widget build(BuildContext context) {
    widget.edit
        ? accountViewModel.fillAccountToEdit(widget.accountToEdit!)
        : null;

    validate() {
      setState(() {
        if (accountViewModel.accountNameController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
      });
    }

    void add() {
      validate();
      if (accountViewModel.accountNameController.text.isNotEmpty) {
        accountService.postAccount(accountViewModel.mapAccount());
        Navigator.pop(context);
      } else {}
    }

    void executeEditPeople() {
      validate();
      if (accountViewModel.accountNameController.text.isNotEmpty) {
        accountService.patchAccount(
            widget.accountToEdit!.account_id, accountViewModel.mapAccount());
        Navigator.pop(context);
      } else {}
    }

    void executeDeletePeople() {
      String accountName = widget.accountToEdit!.account_name;
      CentralDialogForm.manageDeleteAlert(context, () {
        accountService.deleteAccount(widget.accountToEdit!.account_id);
      }, accountName);
    }

    return CentralDialogForm(
        headerEdit: 'Editar proveedor',
        headerAdd: 'Nueva proveedor',
        edit: widget.edit,
        executeEditRecord: executeEditPeople,
        executeAddRecord: add,
        context: context,
        child: personFormBuilder(context, executeDeletePeople));
  }

  Column personFormBuilder(BuildContext context, executeDeleteAccount) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: TextFieldFormHeader(
                    controller: accountViewModel.accountNameController,
                    keyboardType: TextInputType.name,
                    header: 'Nombre *',
                    obscureText: false,
                    customValidator: validationOptions['nameValidator'],
                  ),
                ),
              ],
            ),
            !widget.edit
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      ButtonRounded(
                          backgroundColor: Colors.grey.shade100,
                          width: double.infinity,
                          onPressed: () {
                            executeDeleteAccount();
                          },
                          borderColor: Colors.red,
                          child: const Text(
                            'Borrar persona',
                            style: TextStyle(color: Colors.red),
                          )),
                      const Divider(
                        color: Colors.transparent,
                      ),
                    ],
                  )
          ]))
    ]);
  }
}
