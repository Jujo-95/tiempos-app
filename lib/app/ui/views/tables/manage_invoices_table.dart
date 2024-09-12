import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/app/ui/components/forms/invoice_form.dart';
import 'package:tiempos_app/models/account_model.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import '../../../../models/invoice_model.dart';
import '../../components/custom_widgets/central_dialog_form.dart';
import '../../components/custom_widgets/controller_search.dart';
import '../../components/custom_widgets/report_list_tile.dart';

class ManageInvoicesTable extends StatefulWidget {
  final String searchText;
  final Stream stream;

  const ManageInvoicesTable(
      {Key? key, required this.searchText, required this.stream})
      : super(key: key);

  @override
  State<ManageInvoicesTable> createState() => _ManageInvoicesTableState();
}

class _ManageInvoicesTableState extends State<ManageInvoicesTable> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final filteredData =
              FilterSnapshot.filterSnapshot(snapshot, widget.searchText);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, rowIndex) {
                  final invoiceRecordsDoc = filteredData[rowIndex];
                  final invoiceRecord =
                      InvoiceModel.fromSnapshot(invoiceRecordsDoc);
                  return invoiceTableBuilder(context, invoiceRecord, widget);
                }),
          );
        } else {
          return emptyListTile();
        }
      },
    );
  }
}

Column invoiceTableBuilder(BuildContext context, InvoiceModel invoiceRecord,
    ManageInvoicesTable widget) {
  return Column(
    children: [
      ListTile(
        shape: listTileShapeBuilder(),
        onTap: () {
          CentralDialogForm.openEditForm(
              context,
              InvoiceForm(
                edit: true,
                invoiceToEdit: invoiceRecord,
              ));
        },
        leading: SizedBox(
          width: 50,
          child: initialsAvatarBuilder(invoiceRecord.account_name, null, 20),
        ),
        subtitle: Text("""\$${invoiceRecord.payable_amount!}"""),
        title: Text(invoiceRecord.account_name),
      ),
    ],
  );
}

RoundedRectangleBorder listTileShapeBuilder() {
  return RoundedRectangleBorder(
    side: BorderSide(color: Colors.grey.shade300, width: 1),
    borderRadius: BorderRadius.circular(10),
  );
}
