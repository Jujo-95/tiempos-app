import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/blinking_container.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/dashboard_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/dashboard_service.dart';

class ManageDashboardTable extends StatefulWidget {
  final CollectionReference activityCollection =
      ActivityService.activityCollection;
  // String dateController;

  StreamSubscription<dynamic>? subscription;
  Timer? timer;

  final Function(List<Map<String, dynamic>>) getUpdatedDashboard;
  final Function(String) lastSavedDashboard;
  final Function(bool) pendingChanges;
  final List<Map<String, dynamic>> dashboardItemsToSave;
  final String selectedDate;

  //final DashboardService dashboardService = DashboardService();

  final Stream<QuerySnapshot> filteredStream;
  //final Function() onDatePicked()

  ManageDashboardTable(
      {super.key,
      required this.pendingChanges,
      required this.filteredStream,
      required this.lastSavedDashboard,
      required this.getUpdatedDashboard,
      required this.dashboardItemsToSave,
      required this.selectedDate});

  @override
  State<ManageDashboardTable> createState() => _ManageDashboardTableState();
}

class _ManageDashboardTableState extends State<ManageDashboardTable> {
  int currentIndex = 0;
  final DashboardService dashboardService = DashboardService();
  late Stream<QuerySnapshot> filteredActivities;
  bool hasChanges = false;
  String lastUpdatedText = '';
  late Future<List<DashboardModel>> dashboardStageItems;
  List<Map<String, dynamic>> dashboardItemsToSave = [];

  Future<List<DashboardModel>> getDashboardStageItem() async {
    //List<DashboardModel> futureSnapshot =
    return await dashboardService.getDashboardItemsGroupByDate(
        DashboardService.dateIsoFormat(widget.selectedDate));
  }

  @override
  void initState() {
    super.initState();
    // filteredStream = _getFilteredStream();
    dashboardStageItems = getDashboardStageItem();
    #widget.filteredStream;
    streamSaverTimer();
    dashboardItemsToSave = widget.dashboardItemsToSave;
  }

  void streamSaverTimer() {
    // Start a periodic timer to save changes every 5 minutes
    widget.timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (hasChanges) {
        hasChanges = false; // Reset the flag after saving
        widget.getUpdatedDashboard(dashboardItemsToSave);
        widget.pendingChanges(false);
        setState(() {});
      }
    });
  }

  // Function to replace a map inside a list of maps
  List<Map<String, dynamic>> replaceItemInList(
      List<Map<String, dynamic>> list, Map<String, dynamic> item) {
    int index =
        list.indexWhere((map) => map['documentId'] == item['documentId']);
    if (index != -1) {
      list[index] = item;
    } else {
      throw 'Item with id ${item['id']} not found.';
    }
    return list;
  }

  @override
  void dispose() async {
    widget.timer?.cancel();
    widget.subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FutureBuilder(
        future: dashboardStageItems,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child:
                    Text('No es posible mostrar los datos en este momento :('));
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DashboardModel> documents = snapshot.data!; //!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final documentSnapshot = documents[index];
              return ChildPage(
                dashboardChangedItem: (dashboardItem) {
                  // action to save last changes
                  dashboardItemsToSave = documents.map(
                    (e) {
                      return e.toMap();
                    },
                  ).toList();

                  dashboardItemsToSave = replaceItemInList(
                      dashboardItemsToSave, dashboardItem.toMap());
                },
                hasChanged: (value) {
                  if (value) {
                    widget.pendingChanges(true);
                    hasChanges = true;
                  }
                },
                documentSnapshot: documentSnapshot,
              );
            },
          );
        },
      ),
    );
  }
}

class ChildPage extends StatefulWidget {
  //final DocumentSnapshot documentSnapshot;
  final DashboardModel documentSnapshot;
  final DashboardService dashboardService = DashboardService();
  final Function(bool) hasChanged;
  final Function(DashboardModel) dashboardChangedItem;
  //final DashboardModel.fromSnapshot(document);
  ChildPage(
      {super.key,
      required this.documentSnapshot,
      required this.hasChanged,
      required this.dashboardChangedItem});

  @override
  State<ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<ChildPage> {
  late DashboardModel dashboardModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dashboardModel = widget.documentSnapshot;
    dashboardModel.global_efficiency =
        dashboardModel.calculateGlobalEfficiency();
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DashboardItemCard(
          width: 290,
          child: DashboardHeader(
            dashboard: dashboardModel,
          ),
        ),
        Expanded(
            child: SizedBox(
                height: 160,
                child: DashboardItemsBuilderWithScroll(
                  dashboardModel: dashboardModel,
                  scrollController: scrollController,
                  onUnitsSubmited: (dashboardItem, index) {
                    // update the record
                    dashboardModel.dashboard[index] = dashboardItem.toMap();
                    dashboardModel.global_efficiency =
                        dashboardModel.calculateGlobalEfficiency();
                    widget.hasChanged(true);
                    widget.dashboardChangedItem(dashboardModel);
                  },
                ))),
      ],
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final DashboardModel dashboard;
  final DashboardService dashboardService = DashboardService();

  DashboardHeader({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis);
    TextStyle lableStyle = TextStyle(fontSize: 14, color: Colors.grey.shade500);

    Widget valuesWidget(text) {
      return const FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(height: 35, width: 80, child: Placeholder()));
    }

    headerItem(String title, String? childText,
            {double? width, Widget? child}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: lableStyle),
            SizedBox(
              height: 40,
              width: width ?? 120,
              child: childText != null
                  ? Text(
                      childText,
                      style: titleStyle,
                    )
                  : child,
            )
          ],
        );

    activityName() => FutureBuilder(
          future:
              ActivityService().getActivityByActivityId(dashboard.process_id),
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return headerItem('Referencia', null,
                  child: const BlinkingContainer());
            } else {
              return headerItem('Referencia', snapshot.data!.activity_name);
            }
          },
        );

    return SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.only(right: 1.0),
        child: Stack(
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      headerItem('Módulo', dashboard.module_name),
                      const SizedBox(
                        width: 4,
                      ),
                      activityName()
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      headerItem('Personas', dashboard.people_count.toString(),
                          width: 70),
                      const SizedBox(
                        width: 4,
                      ),
                      headerItem(
                          'SAM', dashboard.dashboard_sam.toStringAsFixed(1),
                          width: 50),
                      const SizedBox(
                        width: 4,
                      ),
                      headerItem(
                          'Objetivo (${(dashboard.efficiency - 1) > 0 ? '+${((dashboard.efficiency - 1) * 100).toStringAsFixed(0)}' : '-${((dashboard.efficiency - 1) * 100).toStringAsFixed(0)}'}%)',
                          '${(dashboard.available_working_time_minutes / (dashboard.dashboard_sam * dashboard.scheduled_hours) * dashboard.efficiency).toStringAsFixed(0)} und/h',
                          width: 120),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      EfficiencyDisplay(
                        efficiency: dashboard.global_efficiency,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('eficiencia módulo', style: lableStyle),
                    ],
                  ),
                ]),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.outlined(
                onPressed: () {
                  CentralDialogForm.manageDeleteAlert(context, () {
                    dashboardService.deleteDashboard(dashboard.documentId!);
                  }, dashboard.module_name, popCount: 1);
                },
                splashRadius: 30,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DashboardItemsBuilderWithScroll extends StatelessWidget {
  final Function(DashboardItemModel, int) onUnitsSubmited;

  const DashboardItemsBuilderWithScroll(
      {super.key,
      required this.dashboardModel,
      required this.scrollController,
      required this.onUnitsSubmited});

  final DashboardModel dashboardModel;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Update the scroll position based on the drag distance
        scrollController
            .jumpTo(scrollController.offset - details.primaryDelta!);
      },
      child: Listener(
        onPointerSignal: (event) {
          event = event as PointerScrollEvent;

          scrollController
              .jumpTo(scrollController.offset - event.scrollDelta.dy / 2);
        },
        child: dashboardItemsListBuilder(),
      ),
    );
  }

  ListView dashboardItemsListBuilder() {
    return ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: dashboardModel.dashboard.length,
      itemBuilder: ((context, index) {
        final dashboardItem =
            DashboardItemModel.fromDashboard(dashboardModel.dashboard[index]);
        return DashboardItemCard(
          child: SizedBox(
              height: 160,
              child: DashboardCardContent(
                dashboardItem: dashboardItem,
                onUnitsSubmited: (units) {
                  DashboardItemModel updatedItem = dashboardItem;
                  updatedItem.units = num.parse(units);
                  onUnitsSubmited(updatedItem, index);
                },
              )),
        );
      }),
    );
  }
}

class DashboardItemCard extends StatelessWidget {
  final Widget child;
  double? width;
  DashboardItemCard({super.key, required this.child, this.width});

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
        width: width ?? 200,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class DashboardCardContent extends StatelessWidget {
  final Function(String) onUnitsSubmited;
  const DashboardCardContent({
    super.key,
    required this.dashboardItem,
    required this.onUnitsSubmited,
  });

  final DashboardItemModel dashboardItem;

  @override
  Widget build(BuildContext context) {
    final TextEditingController unitsController = TextEditingController(
        text: dashboardItem.units == 0 ? '0' : dashboardItem.units.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimeOfDayDisplay(dashboardItem: dashboardItem, context: context),
        const SizedBox(
          height: 6,
        ),
        UnitsInput(
          dashboardItem: dashboardItem,
          unitsController: unitsController,
          onUnitsSubmitted: (units) => onUnitsSubmited(units),
        ),
        const SizedBox(
          height: 6,
        ),
        (DateTime.now().isAfter(DateTime.parse(dashboardItem.time_start)) &&
                DateTime.now().isBefore(DateTime.parse(dashboardItem.time_end)))
            ? EfficiencyBlinking(dashboardItem: dashboardItem)
            : EfficiencyDisplay(efficiency: dashboardItem.efficiency),
      ],
    );
  }
}

class TimeOfDayDisplay extends StatelessWidget {
  const TimeOfDayDisplay(
      {super.key, required this.dashboardItem, required this.context});

  final DashboardItemModel dashboardItem;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    String timeStart =
        DashboardService.toTimeOfDay(dashboardItem.time_start, context)
            .toLowerCase();
    String timeEnd =
        DashboardService.toTimeOfDay(dashboardItem.time_end, context)
            .toLowerCase();

    if (DateTime.now().isAfter(DateTime.parse(dashboardItem.time_start)) &&
        DateTime.now().isBefore(DateTime.parse(dashboardItem.time_end))) {
      return Row(
        children: [
          Row(
            children: [
              Text("$timeStart - ",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 80, child: BlinckingDot())
            ],
          ),
        ],
      );
    } else {
      return Text("$timeStart - $timeEnd",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
    }
  }
}

class UnitsInput extends StatelessWidget {
  final Function(String) onUnitsSubmitted;
  final TextEditingController unitsController;
  final DashboardItemModel dashboardItem;
  const UnitsInput({
    super.key,
    required this.onUnitsSubmitted,
    required this.unitsController,
    required this.dashboardItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
            width: 80,
            child: TextFieldFormHeader(
              controller: unitsController,
              hintText: '0',
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              onSubmitted: (units) {
                onUnitsSubmitted(units);
              },
            )),
        const SizedBox(
          width: 12,
        ),
        Column(
          children: [
            (DateTime.now().isAfter(DateTime.parse(dashboardItem.time_start)) &&
                    DateTime.now()
                        .isBefore(DateTime.parse(dashboardItem.time_end)))
                ? UnitObjectiveContinuous(
                    dashboardItem: dashboardItem,
                  )
                : const SizedBox.shrink(),
            const Text('und',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        )
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

  Color cardColor(num efficiency) {
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

class UnitObjectiveContinuous extends StatefulWidget {
  final DashboardItemModel dashboardItem;
  const UnitObjectiveContinuous({super.key, required this.dashboardItem});

  @override
  State<UnitObjectiveContinuous> createState() =>
      _UnitObjectiveContinuousState();
}

class _UnitObjectiveContinuousState extends State<UnitObjectiveContinuous>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.lightBlueAccent[100],
      end: Colors.blueAccent,
    ).animate(_controller);
  }

  late num percentageOfInterval;

  num getPercentageOfInterval() {
    return (DateTime.now()
            .difference(DateTime.parse(widget.dashboardItem.time_start))
            .inSeconds /
        DateTime.parse(widget.dashboardItem.time_end)
            .difference(DateTime.parse(widget.dashboardItem.time_start))
            .inSeconds *
        widget.dashboardItem.units_objective);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Text(
            ' / ${getPercentageOfInterval().toStringAsFixed(2)}',
            style: TextStyle(color: _animation.value),
          );
        },
      ),
    );
  }
}

class EfficiencyBlinking extends StatefulWidget {
  final DashboardItemModel dashboardItem;
  const EfficiencyBlinking({super.key, required this.dashboardItem});

  @override
  State<EfficiencyBlinking> createState() => _EfficiencyBlinkingState();
}

class _EfficiencyBlinkingState extends State<EfficiencyBlinking>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int?> _animation;

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
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = IntTween(
      begin: 100,
      end: 50,
    ).animate(_controller);
  }

  late num percentageOfInterval;

  num getIntervalEfficiency() {
    return ((widget.dashboardItem.units /
                    (DateTime.now()
                            .difference(
                                DateTime.parse(widget.dashboardItem.time_start))
                            .inSeconds /
                        DateTime.parse(widget.dashboardItem.time_end)
                            .difference(
                                DateTime.parse(widget.dashboardItem.time_start))
                            .inSeconds *
                        widget.dashboardItem.units_objective)) *
                10)
            .truncate() *
        10;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
              color: cardColor(getIntervalEfficiency())
                  .withAlpha(50)
                  .withAlpha(_animation.value!),
              border: Border.all(
                  color: cardColor(getIntervalEfficiency()), width: 1),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              "${getIntervalEfficiency().toStringAsFixed(0)} % ",
              style:
                  TextStyle(color: cardColor(widget.dashboardItem.efficiency)),
            ),
          ),
        );
      },
    );
  }
}
