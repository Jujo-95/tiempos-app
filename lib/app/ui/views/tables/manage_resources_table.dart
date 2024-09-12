import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/controller_search.dart';

import 'package:tiempos_app/models/resource_model.dart';
import 'package:tiempos_app/services/resources_service.dart';

import '../../components/custom_widgets/central_dialog_form.dart';
import '../../components/forms/resources_form.dart';

class ManageResourceTable extends StatefulWidget {
  final String searchText;
  const ManageResourceTable({Key? key, required this.searchText})
      : super(key: key);

  @override
  State<ManageResourceTable> createState() => _ManageResourceTableState();
}

class _ManageResourceTableState extends State<ManageResourceTable> {
  final CollectionReference resourceCollection =
      ResourceService.resourceCollection;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Object?>> resourceStream =
        resourceCollection.snapshots();
    return StreamBuilder(
        stream: resourceStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final resourcesSnapshot =
                FilterSnapshot.filterSnapshot(snapshot, widget.searchText);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.builder(
                itemCount: resourcesSnapshot.length,
                itemBuilder: (context, rowIndex) {
                  final resourcesDoc = resourcesSnapshot[rowIndex];
                  final resource = ResourceModel.fromSnapshot(resourcesDoc);
                  return Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          side:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () {
                          CentralDialogForm.openEditForm(
                              context,
                              ResourceForm(
                                edit: true,
                                resourceToEdit: resource,
                              ));
                        },
                        subtitle: Text(resource.resource_id),
                        title: Text(resource.resource_name),
                      ),
                    ],
                  );
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
