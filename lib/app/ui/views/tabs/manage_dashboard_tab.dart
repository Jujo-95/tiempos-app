import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form.dart';
import 'package:tiempos_app/services/dashboard_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../tables/manage_dashboard_table.dart';

class ManageDashboardTab extends StatefulWidget {
  final Stream dashboardStream;
  final CollectionReference dashboardCollection =
      DashboardService().dashboardCollection;
  String dateController =
      DashboardService.dateIsoFormat(DateTime.now().toIso8601String());

  ManageDashboardTab({Key? key, required this.dashboardStream})
      : super(key: key);

  bool pendingChanges = false;
  DashboardService dashboardService = DashboardService();

  @override
  State<ManageDashboardTab> createState() => _ManageDashboardTabState();
}

class _ManageDashboardTabState extends State<ManageDashboardTab> {
  late Stream<QuerySnapshot> filteredStream;
  String headerPageName = 'Tablero';
  TextStyle headerTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 30);

  DateTime selectedDate = DateTime.now();
  String lastUpdatedTime = DateTime.now().toIso8601String();
  // Dashboard with chenges to save
  List<Map<String, dynamic>> dashboardsWithChanges = [];

  late ManageDashboardTable manageDasboardTable;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filteredStream = _getFilteredStream(
        DashboardService.dateIsoFormat(DateTime.now().toIso8601String()));
    manageDasboardTable = ManageDashboardTable(
      selectedDate: selectedDate.toIso8601String(),
      dashboardItemsToSave: dashboardsWithChanges,
      pendingChanges: (p0) {
        setState(() {
          widget.pendingChanges = p0;
        });
      },
      getUpdatedDashboard: (p0) {
        dashboardsWithChanges = p0;
        saveChanges(dashboardsWithChanges);
      },
      filteredStream: filteredStream,
      lastSavedDashboard: (value) {
        setState(() {
          lastUpdatedTime = value;
        });
      },
      //stream: widget.dashboardStream,
    );
  }

  void saveChanges(List<Map<String, dynamic>> dashboardsWithChanges) {
    dashboardsWithChanges.forEach(
        (e) => widget.dashboardService.patchDashboard(e['documentId'], e));
    dashboardsWithChanges.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000, selectedDate.month, 1),
        lastDate: DateTime.now());

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        manageDasboardTable.createState();
      });
    }
  }

  Stream<QuerySnapshot> _getEmptyStream() {
    return DashboardService()
        .dashboardCollection
        .where('date', isEqualTo: 'a3sd21f2s3ad12f312asdf321dsf')
        .snapshots();
  }

  Stream<QuerySnapshot> _getFilteredStream(dateController) {
    return DashboardService()
        .dashboardCollection
        .where('date', isEqualTo: dateController)
        .snapshots();
  }

  void refreshDashboads() {
    filteredStream = _getEmptyStream();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {
          filteredStream = _getFilteredStream(
              DashboardService.dateIsoFormat(DateTime.now().toIso8601String()));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;

    setState(() {
      windowSize = MediaQuery.of(context).size;
    });

    Widget headerWebUI = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Text(
              headerPageName,
              style: headerTextStyle,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          width: 300,
          child: lastUpdatedBuilder(lastUpdatedTime),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          width: 200,
          child: buttonBuilder2(),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: buttonBuilder(),
          ),
        ),
      ],
    );

    Widget headerMobileUI = Column(children: [
      SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            headerPageName,
            style: headerTextStyle,
          ),
        ),
      ),
      buttonBuilder2(),
      SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: buttonBuilder(),
        ),
      ),
    ]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        windowSize.width <= 800 ? headerMobileUI : headerWebUI,
        Expanded(child: manageDasboardTable),
        Container(),
      ],
    );
  }

  updateDasboardTable() {
    setState(() {
      manageDasboardTable = ManageDashboardTable(
        selectedDate: selectedDate.toIso8601String(),
        dashboardItemsToSave: dashboardsWithChanges,
        pendingChanges: (p0) {
          setState(() {
            widget.pendingChanges = p0;
          });
        },
        getUpdatedDashboard: (p0) {
          dashboardsWithChanges = p0;
          saveChanges(dashboardsWithChanges);
        },
        filteredStream: filteredStream,
        lastSavedDashboard: (value) {
          setState(() {
            lastUpdatedTime = value;
          });
        },
        //stream: widget.dashboardStream,
      );
    });
  }

  SizedBox calendarButtonBuilder(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(DashboardService.parseDateString(
                selectedDate.toIso8601String())),
            const SizedBox(
              width: 6,
            ),
            Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    border: Border.all(color: Colors.grey.shade300)),
                child: IconButton(
                  splashRadius: 0.1,
                  onPressed: () => _selectDate(context),
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF2952E1),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  lastUpdatedBuilder(lastUpdatedTime) => Container(
        padding: const EdgeInsets.only(top: 4),
        child: Expanded(
          child: TextButton.icon(
            clipBehavior: Clip.none,
            onPressed: () {},
            icon: Icon(
              Icons.save,
              size: 15,
              color: Colors.grey.shade600,
            ),
            label: widget.pendingChanges
                ? Text(
                    'Cambios pendientes por guardar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  )
                : Text(
                    'Cambios guardados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
          ),
        ),
      );

  buttonBuilder2() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                label: Text(DashboardService.parseDateString(
                    selectedDate.toIso8601String())),
                onPressed: () => _selectDate(context),
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF2952E1),
                ),
              ),
            ),
          ],
        ),
      );

  buttonBuilder() => Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey.shade300)),
        constraints: const BoxConstraints(
          minHeight: 40.0,
          minWidth: 80.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                label: const Text('Nuevo tablero'),
                onPressed: () {
                  CentralDialogForm.openEditForm(context, DashboardForm(
                    reloadDashboards: (p0) {
                      setState(() {
                        refreshDashboads();
                      });
                    },
                  ));
                },
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF2952E1),
                ),
              ),
            ),
          ],
        ),
      );
}
