import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/table_componet_styles.dart';
import 'package:tiempos_app/models/data_transformation.dart';
import 'package:tiempos_app/models/time_record_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/dashboard_service.dart';
import 'package:tiempos_app/services/time_record_service.dart';
import '../../components/custom_widgets/central_dialog_form.dart';
import '../../components/custom_widgets/report_list_tile.dart';

class ManageTimeRecordsTable extends StatefulWidget {
  final CollectionReference timeRecordCollection =
      TimeRecordService.timeRecordsCollection;
  final CollectionReference activityCollection =
      ActivityService.activityCollection;
  final String dateController =
      DateTime.now().add(const Duration(days: -1008)).toIso8601String();

  final TimeRecordService timeRecordService = TimeRecordService();

  ManageTimeRecordsTable({super.key});

  @override
  State<ManageTimeRecordsTable> createState() => _ManageTimeRecordsTableState();
}

class _ManageTimeRecordsTableState extends State<ManageTimeRecordsTable> {
  int currentIndex = 0;
  late Stream<QuerySnapshot> filteredStream;
  late Stream<QuerySnapshot> filteredActivities;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filteredStream =
        widget.timeRecordService.getFilteredStream(widget.dateController);
  }

  void addOneDay() {}
  void substractOneDay() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: StreamBuilder<QuerySnapshot>(
            stream: filteredStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                    child: Text(
                        'No es posible mostrar los datos en este momento :('));
              } else if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              print(widget.dateController);
              final List<QueryDocumentSnapshot<Object?>> documents =
                  snapshot.data!.docs;
              return Column(children: [
                ChildPage(
                  documentSnapshot: documents,
                )
              ]);
            },
          ),
        ),
        Expanded(
          child: TimeRecordsTable(
            //searchText: '',
            stream: filteredStream,
          ),
        ),
      ],
    );
  }
}

class ChildPage extends StatelessWidget {
  final List<QueryDocumentSnapshot> documentSnapshot;
  final ScrollController scrollController = ScrollController();

  ChildPage({super.key, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
                height: 200,
                child: DashboardItemsBuilderWithScroll(
                  timeRecordDocuments: documentSnapshot,
                  scrollController: scrollController,
                ))),
      ],
    );
  }
}

class DashboardItemsBuilderWithScroll extends StatelessWidget {
  DashboardItemsBuilderWithScroll({
    super.key,
    required this.timeRecordDocuments,
    required this.scrollController,
  });

  final List<QueryDocumentSnapshot> timeRecordDocuments;
  final ScrollController scrollController;
  final TimeRecordService timeRecordService = TimeRecordService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Update the scroll position based on the drag distance
        scrollController
            .jumpTo(scrollController.offset - details.primaryDelta!);
      },
      child: dashboardItemsListBuilder(),
    );
  }

  ListView dashboardItemsListBuilder() {
    final distinctItems = distinctBy(
        timeRecordService.toListOfTimeRecords(timeRecordDocuments),
        (timeRecord) => timeRecord.worker_name);

    return ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: distinctItems.length,
      itemBuilder: ((context, index) {
        final distinctItem = distinctItems[index];
        return DashboardItemCard(
          child: SizedBox(
              height: 260,
              child: DashboardCardContent(
                timeRecordItem: distinctItem,
                timeRecordsDocuments:
                    timeRecordService.toListOfTimeRecords(timeRecordDocuments),
              )),
        );
      }),
    );
  }
}

class DashboardItemCard extends StatelessWidget {
  final Widget child;
  final double? width;
  const DashboardItemCard({super.key, required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          )),
      child: SizedBox(
        width: width ?? 250,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class DashboardCardContent extends StatelessWidget {
  final List<TimeRecordModel> timeRecordsDocuments;
  final String timeRecordItem;
  DashboardCardContent({
    super.key,
    required this.timeRecordItem,
    required this.timeRecordsDocuments,
  });

  TextStyle textStyleTitle = const TextStyle(fontSize: 10);
  TextStyle textStyleTrailing = const TextStyle(fontSize: 10);

  @override
  Widget build(BuildContext context) {
    final filteredTimeRecords = timeRecordsDocuments
        .where((element) => element.worker_name == timeRecordItem);

    final groupedTimeRecordsMap = averageBy(
        filteredTimeRecords,
        (timeRecord) =>
            (timeRecord.activity_name + ' / ' + timeRecord.operation_name),
        (timeRecord) => timeRecord.sam).entries.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 6,
        ),
        SizedBox(
          height: 50,
          child: initialsAvatarBuilder(
              timeRecordItem,
              SizedBox(
                width: 120,
                child: Text(
                  timeRecordItem.toString(),
                  overflow: TextOverflow.fade,
                ),
              ),
              40),
        ),

        const SizedBox(
          height: 6,
        ),
        const SizedBox(
          height: 30,
          child: HeaderTitleBuilderTimeRecordReport(),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: groupedTimeRecordsMap.length,
            itemBuilder: (context, index) {
              var entry = groupedTimeRecordsMap[index];
              return ReportGroupedByItemsTableStyle(
                  activityOperation: entry.key.toString(),
                  unitsPerHour: '${(60 / entry.value).toStringAsFixed(0)}');
              // ListTile(
              //   title: Text(
              //     '${entry.key.toString()}',
              //     style: textStyleTitle,
              //   ),
              //   trailing: Text(
              //     '${(60 / entry.value).toStringAsFixed(0)} unds/h',
              //     style: textStyleTrailing,
              //   ),
              // );
            },
          ),
        )

        //EfficiencyDisplay(efficiency: timeRecordItem)
      ],
    );
  }
}

class EfficiencyDisplay extends StatelessWidget {
  const EfficiencyDisplay({
    super.key,
    required this.efficiency,
  });

  final num efficiency;

  static Color cardColor(num efficiency) {
    if (efficiency >= 1) {
      return Colors.blueGrey;
    } else if ((efficiency > 0.8) & (efficiency < 1)) {
      return Colors.yellow.shade400;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: cardColor(efficiency).withAlpha(50),
            border: Border.all(color: cardColor(efficiency), width: 1),
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            "$efficiency % ",
            style: TextStyle(color: cardColor(efficiency)),
          ),
        ));
  }
}

class TimeRecordsTable extends StatefulWidget {
  //final String searchText;
  final Stream stream;
  final TimeRecordService timeRecordService = TimeRecordService();
  TimeRecordsTable(
      {Key? key,
      //required this.searchText,
      required this.stream})
      : super(key: key);

  @override
  State<TimeRecordsTable> createState() => _TimeRecordsTableState();
}

class _TimeRecordsTableState extends State<TimeRecordsTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderTitleBuilderTimeRecord(),
        Expanded(
          child: StreamBuilder(
            stream: widget.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, rowIndex) {
                        final timeRecordRecordsDoc =
                            snapshot.data.docs[rowIndex];
                        final timeRecordRecord =
                            TimeRecordModel.fromSnapshot(timeRecordRecordsDoc);
                        return timeRecordTableBuilder(
                            context, timeRecordRecord, widget);
                      }),
                );
              } else {
                if (snapshot.hasError) {
                  print(snapshot.error);
                }
                return emptyListTile();
              }
            },
          ),
        ),
      ],
    );
  }
}

Column timeRecordTableBuilder(BuildContext context,
    TimeRecordModel timeRecordRecord, TimeRecordsTable widget) {
  String parsedTime =
      """${DashboardService.dateIsoFormat(timeRecordRecord.created)} ${TimeOfDay.fromDateTime(DateTime.parse(timeRecordRecord.created)).format(context)}""";
  return Column(
    children: [
      CustomRowTemplate(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: customRowDecoration,
          children: [
            Text('${timeRecordRecord.worker_name} '),
            Text(timeRecordRecord.sam.toStringAsFixed(2)),
            Text(
                '${timeRecordRecord.activity_name} ${timeRecordRecord.operation_name}'),
            Text(parsedTime),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.outlined(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    CentralDialogForm.manageDeleteAlert(context, () {
                      widget.timeRecordService
                          .deleteTimeRecord(timeRecordRecord.time_record_id);
                    }, ' el registro de ${timeRecordRecord.worker_name}',
                        popCount: 1);
                  },
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ]),
    ],
  );
}

RoundedRectangleBorder listTileShapeBuilder() {
  return RoundedRectangleBorder(
    side: BorderSide(color: Colors.grey.shade300, width: 1),
    borderRadius: BorderRadius.circular(10),
  );
}

class HeaderTitleBuilderTimeRecord extends StatelessWidget {
  const HeaderTitleBuilderTimeRecord({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: CustomRowTemplate(
        children: [
          Text('Persona', style: TableComponentStyles.lableStyle),
          Text('SAM', style: TableComponentStyles.lableStyle),
          Text('Referencia/Operacion', style: TableComponentStyles.lableStyle),
          Text('Fecha creación', style: TableComponentStyles.lableStyle),
          Text('', style: TableComponentStyles.lableStyle),
        ],
      ),
    );
  }
}

class HeaderTitleBuilderTimeRecordReport extends StatelessWidget {
  const HeaderTitleBuilderTimeRecordReport({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: CustomRowTemplate(
        padding: EdgeInsets.all(0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Referencia/Operacion',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('unidades/hora',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportGroupedByItemsTableStyle extends StatelessWidget {
  final String activityOperation;
  final String unitsPerHour;

  const ReportGroupedByItemsTableStyle({
    required this.activityOperation,
    required this.unitsPerHour,
    super.key,
  });

  static BoxDecoration decoration = BoxDecoration(
    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
  );

  @override
  Widget build(BuildContext context) {
    String titleTile = activityOperation.toLowerCase().split('/')[0];
    String subtitleTile = activityOperation.toLowerCase().split('/')[1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: CustomRowTemplate(
        decoration: decoration,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(activityOperation.trim().toLowerCase(),
                  style: TextStyle(fontSize: 10)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(unitsPerHour.trim(), style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
