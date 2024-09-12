import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/app/ui/components/forms/person_form.dart';
import 'package:tiempos_app/app/ui/components/table_componet_styles.dart';

import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/people_model.dart';

import '../../components/custom_widgets/central_dialog_form.dart';
import '../../components/custom_widgets/controller_search.dart';
import '../../components/custom_widgets/report_list_tile.dart';

class ManagePeopleTable extends StatefulWidget {
  final String searchText;
  final Stream stream;
  const ManagePeopleTable(
      {Key? key, required this.searchText, required this.stream})
      : super(key: key);

  @override
  State<ManagePeopleTable> createState() => _ManagePeopleTableState();
}

class _ManagePeopleTableState extends State<ManagePeopleTable> {
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
                  final peopleRecordsDoc = filteredData[rowIndex];
                  final peopleRecord =
                      PeopleModel.fromSnapshot(peopleRecordsDoc);
                  return peopleTableBuilder(context, peopleRecord, widget);
                }),
          );
        } else {
          return emptyListTile();
        }
      },
    );
  }
}

Column peopleTableBuilder(
    BuildContext context, PeopleModel peopleRecord, ManagePeopleTable widget) {
  return Column(
    children: [
      Container(
        decoration: customRowDecoration,
        child: ListTile(
          onTap: () {
            CentralDialogForm.openEditForm(
                context,
                PersonForm(
                  edit: true,
                  peopleToEdit: peopleRecord,
                ));
          },
          leading: SizedBox(
            width: 50,
            child: initialsAvatarBuilder(
                '${peopleRecord.first_name} ${peopleRecord.last_name}',
                null,
                20),
          ),
          subtitle: Text(peopleRecord.id_number),
          title: Text('${peopleRecord.first_name} ${peopleRecord.last_name}'),
        ),
      ),
    ],
  );
}
