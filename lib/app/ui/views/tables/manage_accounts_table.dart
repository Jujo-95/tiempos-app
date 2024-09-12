import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/app/ui/components/forms/account_form.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import '../../../../models/account_model.dart';
import '../../components/custom_widgets/central_dialog_form.dart';
import '../../components/custom_widgets/controller_search.dart';
import '../../components/custom_widgets/report_list_tile.dart';

class ManageAccountTable extends StatefulWidget {
  final String searchText;
  final Stream stream;

  const ManageAccountTable(
      {Key? key, required this.searchText, required this.stream})
      : super(key: key);

  @override
  State<ManageAccountTable> createState() => _ManageAccountTableState();
}

class _ManageAccountTableState extends State<ManageAccountTable> {
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
                  final accountRecordsDoc = filteredData[rowIndex];
                  final accountRecord =
                      AccountModel.fromSnapshot(accountRecordsDoc);
                  return accountTableBuilder(context, accountRecord, widget);
                }),
          );
        } else {
          return emptyListTile();
        }
      },
    );
  }
}

Column accountTableBuilder(BuildContext context, AccountModel accountRecord,
    ManageAccountTable widget) {
  return Column(
    children: [
      ListTile(
        shape: listTileShapeBuilder(),
        onTap: () {
          CentralDialogForm.openEditForm(
              context,
              AccountForm(
                edit: true,
                accountToEdit: accountRecord,
              ));
        },
        leading: SizedBox(
          width: 50,
          child:
              initialsAvatarBuilder('${accountRecord.account_name}', null, 20),
        ),
        subtitle: Text(accountRecord.account_invoices!.length.toString()),
        title: Text(accountRecord.account_name),
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
