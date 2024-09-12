import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/controller_search.dart';
import 'package:tiempos_app/app/ui/components/forms/activity_form.dart';
import 'package:tiempos_app/app/ui/components/forms/operation_form.dart';
import 'package:tiempos_app/app/ui/components/table_componet_styles.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/dashboard_service.dart';

import '../../../../services/operations_service.dart';
import '../../components/custom_widgets/central_dialog_form.dart';

class ManageActivityTable extends StatefulWidget {
  final Stream<QuerySnapshot<Object?>> activitiesStream;
  final Stream<QuerySnapshot<Object?>> operationsStream;
  final String searchText;
  const ManageActivityTable(
      {Key? key,
      required this.searchText,
      required this.activitiesStream,
      required this.operationsStream})
      : super(key: key);

  @override
  State<ManageActivityTable> createState() => _ManageActivityTableState();
}

class _ManageActivityTableState extends State<ManageActivityTable> {
  List<QueryDocumentSnapshot<Object?>> activitiesDocs = [];
  OperationService operationService = OperationService();

  @override
  void initState() {
    //activitySnapshot = activityCollection.snapshots();
    super.initState();
  }

  final Map<String, bool> _selectedDropdownIndexes = {};

  BorderRadius borderRadiusParentOpen = const BorderRadius.only(
      topLeft: Radius.circular(
          10.0), // Adjust the radius value to control the curvature
      topRight: Radius.circular(10.0));

  final CollectionReference activityCollection =
      ActivityService.activityCollection;
  final CollectionReference operationCollection =
      OperationService.operationCollection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: widget.activitiesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final activityFilterd = FilterSnapshot.filterSnapshot(
                        snapshot, widget.searchText);

                    return ListView.builder(
                      itemCount: activityFilterd.length + 1,
                      itemBuilder: (context, rowIndex) {
                        if (rowIndex == 0) {
                          return const HeaderTitleBuilder();
                        } else {
                          rowIndex = rowIndex - 1;
                          final activitiesDoc = activityFilterd[rowIndex];
                          final activity =
                              ActivityModel.fromSnapshot(activitiesDoc);
                          _selectedDropdownIndexes.putIfAbsent(
                              activity.activity_id, () => false);
                          return Column(
                            children: [
                              activityRowBuilder(activity, context),
                              if (_selectedDropdownIndexes[
                                      activity.activity_id] ??
                                  false)
                                Container(
                                  decoration: customRowDecoration,
                                  child: ListTile(
                                      subtitle: StreamBuilder(
                                          stream: operationService
                                              .getOperationsByActivity(
                                                  activity),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final filteredOperations =
                                                  snapshot.data!.docs;
                                              return OperationRowBuilder(
                                                  decoration:
                                                      childContainerBoxDecoration(),
                                                  filteredOperations:
                                                      filteredOperations,
                                                  activity: activity);
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          })),
                                )
                            ],
                          );
                        }
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  BoxDecoration childOperationsBoxDecoration() {
    return BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ));
  }

  openOperationForm(
    BuildContext context,
    ActivityModel activityParent,
  ) {
    return CentralDialogForm.openEditForm(
        context,
        OperationForm(
          activityParent: activityParent,
          edit: false,
        ));
  }

  activityRowBuilder(ActivityModel activity, BuildContext context) {
    return Container(
      decoration: parentContainerBoxDecoration(activity),
      child: ListTile(
        //shape: activityListTileShapeBuilder(activity),

        onTap: () {
          CentralDialogForm.openEditForm(
              context, ActivityForm(edit: true, activityToEdit: activity));
        },
        leading: IconButton(
          onPressed: () {
            print('build');
            Future.delayed(Duration.zero, () {
              setState(() {
                _selectedDropdownIndexes[activity.activity_id] =
                    !_selectedDropdownIndexes[activity.activity_id]!;
              });
            });
          },
          icon: Icon(_selectedDropdownIndexes[activity.activity_id]!
              ? Icons.expand_more
              : Icons.keyboard_arrow_right),
        ),
        //subtitle: Text(activity.activity_id),
        title: CustomRowTemplate(
          children: [
            Text(activity.activity_name),
            Text(
              activity.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(activity.responsable_people),
            Text(DashboardService.parseDateString(activity.created))
          ],
        ),
        trailing: ClipOval(
            child: Material(
          color: Colors.transparent, // Button color
          child: InkWell(
            onTap: () {
              openOperationForm(context, activity);
            },
            splashColor: Colors.grey, // Splash color
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Center(child: Icon(Icons.add)),
            ),
          ),
        )),
      ),
    );
  }

  BoxDecoration parentContainerBoxDecoration(ActivityModel activity) {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300, width: 1),
      borderRadius: _selectedDropdownIndexes[activity.activity_id] ?? false
          ? borderRadiusParentOpen
          : BorderRadius.circular(10),
    );
  }

  BoxDecoration childContainerBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300, width: 1),
      borderRadius: BorderRadius.circular(10),
    );
  }
}

class HeaderTitleBuilder extends StatelessWidget {
  const HeaderTitleBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SizedBox(width: 40),
      title: CustomRowTemplate(
        children: [
          Text('Nombre', style: TableComponentStyles.lableStyle),
          Text('Descripción', style: TableComponentStyles.lableStyle),
          Text('Responsable', style: TableComponentStyles.lableStyle),
          Text('Fecha creación', style: TableComponentStyles.lableStyle)
        ],
      ),
      trailing: const SizedBox(
        width: 35,
      ),
    );
  }
}

class HeaderTitleBuilderOperation extends StatelessWidget {
  const HeaderTitleBuilderOperation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: CustomRowTemplate(
        children: [
          Text('Posición', style: TableComponentStyles.lableStyle),
          Text('Nombre', style: TableComponentStyles.lableStyle),
          Text('Descripción', style: TableComponentStyles.lableStyle),
          Text('Fecha creación', style: TableComponentStyles.lableStyle)
        ],
      ),
    );
  }
}

class OperationRowBuilder extends StatelessWidget {
  BoxDecoration decoration;

  OperationRowBuilder({
    super.key,
    required this.filteredOperations,
    required this.activity,
    required this.decoration,
  });

  final List<QueryDocumentSnapshot<Object?>> filteredOperations;
  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderTitleBuilderOperation(),
        ListView.builder(
            // Prevent inner ListView from scrolling independently
            shrinkWrap: true,
            itemCount: filteredOperations.length,
            itemBuilder: (context, subRowIndex) {
              final operationDoc = filteredOperations[subRowIndex];
              final operation = OperationModel.fromSnapshot(operationDoc);
              openOperationForm() {
                CentralDialogForm.openEditForm(
                    context,
                    OperationForm(
                      activityParent: activity,
                      edit: true,
                      operationToEdit: operation,
                    ));
              }

              return Container(
                decoration: decoration,
                child: ListTile(
                    title: CustomRowTemplate(
                      children: [
                        Text(operation.position.toString()),
                        Text(operation.operation_name),
                        Text(operation.notes, maxLines: 1),
                        Text(activity.created)
                      ],
                    ),
                    onTap: openOperationForm),
              );
            }),
      ],
    );
  }
}
