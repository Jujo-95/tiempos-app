import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardModel {
  String? date;
  num efficiency;
  String module_name;
  List<dynamic> people = [];
  String process_id;
  int scheduled_hours;
  String? documentId;
  num dashboard_sam;
  num dashboard_sam_with_eff;
  num people_count;
  List<dynamic> operations;
  num available_working_time_minutes;
  String start_time;
  List<dynamic> dashboard;
  num global_efficiency = 0;

  /// create current date

  DashboardModel(
      {this.documentId,
      this.date,
      this.efficiency = 1,
      this.module_name = "",
      this.people = const [],
      this.process_id = "",
      this.scheduled_hours = 8,
      this.dashboard_sam = 0,
      num dashboard_sam_with_eff = 0.1,
      people_count = 0,
      this.operations = const [],
      num available_working_time_minutes = 0,
      required this.dashboard,
      required this.start_time,
      global_efficiency = 0})
      : people_count = people.length,
        dashboard_sam_with_eff = dashboard_sam * efficiency,
        available_working_time_minutes = people.length * scheduled_hours * 60;

  factory DashboardModel.fromSnapshot(DocumentSnapshot snapshot) {
    try {
      print(
          'THHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHIIIIIIIIIIIIIISSSSSSSSSSSSS INN THE INPUT');
      print(snapshot.data);

      return DashboardModel(
          documentId: snapshot.id,
          date: snapshot?['date'], //
          efficiency: snapshot?['efficiency'], //
          module_name: snapshot?['module_name'], //
          people: snapshot?['people'], //
          people_count: snapshot?['people_count'], //
          process_id: snapshot?['process_id'], //
          scheduled_hours: snapshot?['scheduled_hours'], //
          dashboard_sam: snapshot?['dashboard_sam'], //
          dashboard_sam_with_eff: snapshot?['dashboard_sam_with_eff'], //
          available_working_time_minutes:
              snapshot?['available_working_time'], //
          start_time: snapshot?['start_time'],
          dashboard: snapshot?['dashboard'], //
          operations: snapshot?['operations'],
          global_efficiency: snapshot?['global_efficiency']);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  num calculateGlobalEfficiency() {
    num efficiency = 0;
    Iterable<DashboardItemModel> dashboarItems = dashboard
        .map((e) => DashboardItemModel.fromDashboard(e))
        .where((element) =>
            (DateTime.parse(element.time_start).compareTo(DateTime.now()) <=
                0));
    for (DashboardItemModel dashboarItem in dashboarItems) {
      efficiency += dashboarItem.efficiency;
    }

    return num.parse((efficiency / dashboarItems.length).toStringAsFixed(0));
  }

  Map<String, dynamic> toMap() {
    Map<String, Object?> map = {
      'documentId': documentId,
      'date': date,
      'efficiency': efficiency,
      'module_name': module_name,
      'people': people,
      'process_id': process_id,
      'scheduled_hours': scheduled_hours,
      'dashboard_sam': dashboard_sam,
      'dashboard_sam_with_eff': dashboard_sam_with_eff,
      'people_count': people_count,
      'operations': operations,
      'available_working_time': available_working_time_minutes,
      'start_time': start_time,
      'global_efficiency': global_efficiency,
      'dashboard': dashboard.map(
        (e) {
          if (e is DashboardItemModel) {
            return e.toMap();
          } else {
            return e;
          }
        },
      ).toList()
    };
    return map;
  }

  // Map<String, dynamic> toMapWithDashboardItem() {
  //   Map<String, Object?> map = {
  //     'date': date,
  //     'efficiency': efficiency,
  //     'module_name': module_name,
  //     'people': people,
  //     'process_id': process_id,
  //     'scheduled_hours': scheduled_hours,
  //     'dashboard_sam': dashboard_sam,
  //     'dashboard_sam_with_eff': dashboard_sam_with_eff,
  //     'people_count': people_count,
  //     'operations': operations,
  //     'available_working_time': available_working_time_minutes,
  //     'start_time': start_time,
  //     'global_efficiency': global_efficiency,
  //     'dashboard': dashboard.map((e) => print(e)).toList()
  //   };
  //   return map;
  // }
}

class DashboardItemModel {
  String time_start;
  String time_end;
  num units;
  num units_objective;
  num efficiency;
  String? record_time;

  DashboardItemModel(
      {required this.time_start,
      required this.time_end,
      required this.units_objective,
      this.units = 0})
      : efficiency =
            calculateEfficiency(units, units_objective, time_end, time_start);
  // (units / units_objective * 100).round() * (DateTime.now().minute);

  static num calculateEfficiency(units, units_objective, time_end, time_start) {
    getMilisecods(stringTime) =>
        DateTime.parse(stringTime).millisecondsSinceEpoch;
    num absEfficiency = (units / units_objective * 100).round();

    if (DateTime.now().millisecondsSinceEpoch < getMilisecods(time_end) &&
        DateTime.now().millisecondsSinceEpoch > getMilisecods(time_start)) {
      num percentajeOfThehour =
          DateTime.now().difference(DateTime.parse(time_start)).inSeconds /
              DateTime.parse(time_end)
                  .difference(DateTime.parse(time_start))
                  .inSeconds;
      return (units / (units_objective * percentajeOfThehour) * 100).round();
    } else {
      return absEfficiency;
    }
  }

  factory DashboardItemModel.fromDashboard(Map<String, dynamic> dashboarItem) {
    try {
      return DashboardItemModel(
          time_start: dashboarItem['time_start'],
          time_end: dashboarItem['time_end'],
          units_objective: dashboarItem['units_objective'],
          units: dashboarItem['units']);
    } catch (e) {
      print("""error generando DashboardItemModel.fromDashboard
      ${dashboarItem['units_objective']}
      ${dashboarItem['units']}
      """);
      throw e;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'time_start': time_start,
      'time_end': time_end,
      'units': units,
      'units_objective': units_objective,
      'efficiency': efficiency
    };
  }

  static getAvailableWorkingtimeminutes(people, scheduled_hours) {
    return people.length * scheduled_hours * 60;
  }

  static List<DashboardItemModel> generateDashboardItemModelList(
      int scheduled_hours,
      String start_time,
      num available_working_time_minutes,
      num dashboard_sam,
      num efficiency,
      int delta_minutes) {
    num units_objective = num.parse((available_working_time_minutes /
            (dashboard_sam * scheduled_hours) *
            efficiency)
        .toStringAsFixed(2));

    return List<DashboardItemModel>.generate(
        scheduled_hours * 60 ~/ delta_minutes, (index) {
      String time_start = DateTime.parse(start_time)
          .add(Duration(minutes: delta_minutes * index))
          .toIso8601String();
      String time_end = DateTime.parse(time_start)
          .add(Duration(minutes: delta_minutes))
          .toIso8601String();

      return DashboardItemModel(
          time_start: time_start,
          time_end: time_end,
          units_objective: units_objective);
    });
  }
}
