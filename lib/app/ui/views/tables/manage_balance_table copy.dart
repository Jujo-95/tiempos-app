import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import '../../../../models/line_balance_model.dart';
import '../../../../models/people_model.dart';
import '../../components/custom_widgets/report_list_tile.dart';

class ManageBalanceTable extends StatefulWidget {
  const ManageBalanceTable({Key? key}) : super(key: key);

  @override
  State<ManageBalanceTable> createState() => _ManageBalanceTableState();
}

class _ManageBalanceTableState extends State<ManageBalanceTable> {
  late CollectionReference operationRef;

  final FirebasePaths firebasePaths = FirebasePaths.instance;

  List<QueryDocumentSnapshot<Object?>> timeRecordsDocs = [];
  List<QueryDocumentSnapshot<Object?>> activitiesDocs = [];
  List<QueryDocumentSnapshot<Object?>> operationDocs = [];

  ActivityService activityService = ActivityService();

  Widget emptyListTile() => ListTileForReportView(
        chipColor: Colors.grey.shade200,
        subtitle: Text(
          ' ' * 10,
        ),
        title: Text(' ' * 10),
        trailing: Text(' ' * 10),
      );

  List? grouppedResults;

  @override
  Widget build(BuildContext context) {
    return operationsViewBuilder();
  }

  Widget operationsViewBuilder() {
    Future<QuerySnapshot<Map<String, dynamic>>> peopleFuture =
        firebasePaths.getCollectionByName('people').get();
    Future<QuerySnapshot<Map<String, dynamic>>> operationsFuture = firebasePaths
        .getCollectionByName('operations')
        .where('activity_id', isEqualTo: '[#735f0]')
        .get();

    return FutureBuilder(
      future: Future.wait([peopleFuture, operationsFuture]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return emptyListTile();
        } else {
          QuerySnapshot peopleSnapshot = snapshot.data![0];
          QuerySnapshot operationsSnapshot = snapshot.data![1];
          List<PeopleModel> people = [];
          for (var person in peopleSnapshot.docs) {
            people.add(PeopleModel.fromSnapshot(person));
          }
          List<OperationModel> operations = [];
          for (var operation in operationsSnapshot.docs) {
            operations.add(OperationModel.fromSnapshot(operation));
          }

          List<dynamic> lineBalance = LineBalance(
                  unitsToProduce: 100,
                  dailyTimeMinutes: 480,
                  operationSecuence: operations,
                  peopleList: people)
              .balanceLine();

          return ListView.builder(
              itemCount: lineBalance[1].length,
              itemBuilder: (context, index) {
                List operationsList = lineBalance[1];
                return ListTileForReportView(
                  height: 200,
                  chipColor: Colors.grey.shade200,
                  subtitle: Text(
                    '${operationsList[index]['activity_id']} - ${operationsList[index]['total_time_left']}',
                  ),
                  //leading: Text('${operationsList[index]['operation_name']} '),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: unitsPerHourChipsBuilder(
                        operationsList[index]['units_person']),
                  ),
                );
              });
        }
      },
    );
  }

  Widget unitsPerHourChipsBuilder(unitsPerPerson) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: unitsPerPerson.length,
        itemBuilder: (context, index1) {
          return SizedBox(
            width: 150,
            child: Column(
              children: [
                Text(
                    '${TimeOfDay(hour: 6 + index1, minute: 0).format(context)} - ${TimeOfDay(hour: 7 + index1, minute: 0).format(context)}',
                    style: TextStyle(fontSize: 12)),
                ListTile(
                  title: ListView.builder(
                    shrinkWrap: true,
                    itemCount: unitsPerPerson[index1].length,
                    itemBuilder: (context, index2) {
                      return initialsAvatarBuilder(
                          unitsPerPerson[index1][index2]['name'],
                          Text(unitsPerPerson[index1][index2]
                                  ['units_per_person']
                              .toString()),
                          null);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
