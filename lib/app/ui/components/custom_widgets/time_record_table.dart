// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tiempos_app/models/firebase_paths.dart';

// class TimeRecordTableWidget extends StatefulWidget {
//   const TimeRecordTableWidget({Key? key}) : super(key: key);

//   @override
//   _TimeRecordTableWidget createState() => _TimeRecordTableWidget();
// }

// class _TimeRecordTableWidget extends State<TimeRecordTableWidget> {
//   late CollectionReference timeRecordsRef;
//   late CollectionReference operationsRef;
//   final FirebasePaths firebasePaths = FirebasePaths();

//   List<QueryDocumentSnapshot<Object?>> timeRecordsDocs = [];
//   List<QueryDocumentSnapshot<Object?>> operationsDocs = [];

//   @override
//   void initState() {
//     super.initState();
//     timeRecordsRef = firebasePaths.getCollectionByName('time_records');
//     operationsRef = firebasePaths.getCollectionByName('operations');
//     refreshTables();
//   }

//   Future<void> refreshTables() async {
//     final timerecordsQuerySnapshot = await timeRecordsRef.get();
//     final operationsSnapshot = await operationsRef.get();
//     setState(() {
//       operationsDocs = operationsSnapshot.docs;
//       timeRecordsDocs = timerecordsQuerySnapshot.docs;
//     });
//   }

//   final Set<int> _selectedDropdownIndexes = {};

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: ListView.builder(
//         itemCount: timeRecordsDocs.length,
//         itemBuilder: (context, rowIndex) {
//           final timeRecordDoc = timeRecordsDocs[rowIndex];
//           final timeRecord = TimeRecords.fromSnapshot(timeRecordDoc);
//           final isSelected = _selectedDropdownIndexes.contains(rowIndex);

//           return Column(
//             children: [
//               ListTile(
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(color: Colors.grey.shade300, width: 1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         _selectedDropdownIndexes.remove(rowIndex);
//                       } else {
//                         _selectedDropdownIndexes.add(rowIndex);
//                       }
//                     });
//                   },
//                   leading: Text(timeRecord.operation_id),
//                   title: Text(timeRecord.worker_name),
//                   trailing: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         if (isSelected) {
//                           _selectedDropdownIndexes.remove(rowIndex);
//                         } else {
//                           _selectedDropdownIndexes.add(rowIndex);
//                         }
//                       });
//                     },
//                     icon: Icon(
//                         isSelected ? Icons.expand_less : Icons.expand_more),
//                   )),
//               if (isSelected)
//                 SizedBox(
//                   child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: operationsDocs.length,
//                       itemBuilder: (context, subRowIndex) {
//                         final operationDoc = operationsDocs[subRowIndex];
//                         final operation = Operation.fromSnapshot(operationDoc);
//                         if (operation.activity_id != timeRecord.operation_id) {
//                           return const SizedBox.shrink();
//                         }

//                         return Row(
//                           children: [
//                             const Expanded(
//                               flex: 1,
//                               child: SizedBox.square(),
//                             ),
//                             Expanded(
//                               flex: 20,
//                               child: ListTile(
//                                   leading: Text(operation.operation_id),
//                                   title: Text(operation.activity_id)),
//                             ),
//                           ],
//                         );
//                       }),
//                 )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class Activity {
//   final String activity_name;
//   final String activity_id;

//   Activity({required this.activity_name, required this.activity_id});

//   factory Activity.fromSnapshot(DocumentSnapshot snapshot) {
//     return Activity(
//       activity_name: snapshot['activity_name'],
//       activity_id: snapshot['activity_id'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'activity_name': activity_name,
//       'activity_id': activity_id,
//     };
//   }
// }

// class Operation {
//   final String operation_id;
//   final String activity_id;
//   final String operation_name;

//   Operation(
//       {required this.operation_id,
//       required this.activity_id,
//       required this.operation_name});

//   factory Operation.fromSnapshot(snapshot) {
//     return Operation(
//         operation_id: snapshot['operation_id'],
//         activity_id: snapshot['activity_id'],
//         operation_name: snapshot['operation_name']);
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'operation_id': operation_id,
//       'activity_id': activity_id,
//       'operation_name': operation_name
//     };
//   }
// }

// class TimeRecords {
//   final String worker_name;
//   final String operation_id;

//   TimeRecords({required this.worker_name, required this.operation_id});

//   factory TimeRecords.fromSnapshot(DocumentSnapshot snapshot) {
//     return TimeRecords(
//         worker_name: snapshot['worker_name'],
//         operation_id: snapshot['operation_id']);
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'worker_name': worker_name,
//       'operation_id': operation_id,
//     };
//   }
// }
