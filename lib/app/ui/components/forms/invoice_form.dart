import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/custom_dropdown2/timepos_custom_dropdown.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/account_model.dart';
import 'package:tiempos_app/models/controllers/account_view_model.dart';
import 'package:tiempos_app/models/invoice_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/account_service.dart';
import 'package:tiempos_app/services/invoice_service.dart';
import '../../../../models/controllers/invoice_view_model.dart';

class InvoiceForm extends StatefulWidget {
  final bool edit;
  final InvoiceModel? invoiceToEdit;

  InvoiceForm({
    super.key,
    this.edit = false,
    this.invoiceToEdit,
  });

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  InvoiceViewModel invoiceViewModel = InvoiceViewModel();
  InvoiceService invoiceService = InvoiceService();
  AccountService accountService = AccountService();
  late Future<List<AccountModel>> accountsList;
  Map validationOptions = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAccountList();
  }

  initAccountList() async {
    accountsList = accountService.fetchAllItems().then((snapshot) {
      return snapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.edit
        ? invoiceViewModel.fillInvoiceToEdit(widget.invoiceToEdit!)
        : null;

    validate() {
      setState(() {
        if (invoiceViewModel.registration_nameController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
      });
    }

    void add() {
      validate();
      if (invoiceViewModel.registration_nameController.text.isNotEmpty) {
        invoiceService.postInvoice(invoiceViewModel.mapInvoice());
        Navigator.pop(context);
      } else {}
    }

    void executeEditInvoice() {
      validate();
      if (invoiceViewModel.registration_nameController.text.isNotEmpty) {
        invoiceService.patchInvoice(
            widget.invoiceToEdit!.invoice_id, invoiceViewModel.mapInvoice());
        Navigator.pop(context);
      } else {}
    }

    void executeDeleteInvoice() {
      String invoiceName =
          '${widget.invoiceToEdit!.invoice_id} de ${widget.invoiceToEdit!.account_name}';
      CentralDialogForm.manageDeleteAlert(context, () {
        invoiceService.deleteInvoice(widget.invoiceToEdit!.invoice_id);
      }, invoiceName);
    }

    accountItems(AccountModel? p) => p != null ? p.account_name : '';

    onChangedAccount(AccountModel? data) {
      invoiceViewModel.account_nameController.text = data!.account_name;
      invoiceViewModel.account_idController.text = data.account_name;
      invoiceViewModel.registration_nameController.text = data.account_name;
    }

    onFindAccount(String? filter) {
      return accountsList;
    }

    return CentralDialogForm(
        headerEdit: 'Editar factura',
        headerAdd: 'Nueva factura',
        edit: widget.edit,
        executeEditRecord: executeEditInvoice,
        executeAddRecord: add,
        context: context,
        child: invoiceFormBuilder(context, executeDeleteInvoice,
            onChangedAccount, accountItems, onFindAccount));
  }

  Column invoiceFormBuilder(BuildContext context, executeDeleteInvoice,
      onChangedAccount, accountItems, onFindAccount) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: TextFieldFormHeader(
                    controller: invoiceViewModel.registration_nameController,
                    keyboardType: TextInputType.name,
                    header: 'Proveedor *',
                    obscureText: false,
                    customValidator: validationOptions['nameValidator'],
                    fieldHeight: 50,
                    child: TiemposCustomDropdown<AccountModel>(
                      padding: const EdgeInsets.all(0),
                      validator: (AccountModel? value) => value == null
                          ? 'Debes seleccionar un proveedor'
                          : null,
                      onChanged: onChangedAccount,
                      itemAsString: accountItems,
                      onFind: onFindAccount,
                      hintText: '',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldFormHeader(
                    controller: invoiceViewModel.registration_nameController,
                    keyboardType: TextInputType.name,
                    header: 'Nombre (RegistrationName)*',
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
                            executeDeleteInvoice();
                          },
                          borderColor: Colors.red,
                          child: const Text(
                            'Borrar factura',
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
