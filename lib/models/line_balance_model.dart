import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/models/people_model.dart';

class LineBalance {
  num unitsToProduce;
  num dailyTimeMinutes;
  bool hourly = true;
  List<OperationModel> operationSecuence;
  List<PeopleModel> peopleList;
  late num cycleTime;
  late int workStations;
  late List<Map<dynamic, dynamic>> peopleWithTimeLeft;
  late List<Map<dynamic, dynamic>> operationsToBalance;

  int initialHour;
  int initialMinutes;

  LineBalance(
      {required this.unitsToProduce,
      required this.dailyTimeMinutes,
      required this.operationSecuence,
      required this.peopleList,
      this.initialHour = 6,
      this.initialMinutes = 0});

  void _adjustForHourly() {
    unitsToProduce = unitsToProduce ~/ 8;
    dailyTimeMinutes = dailyTimeMinutes ~/ 8;
  }

  void _initialCicleTime() {
    if (hourly) _adjustForHourly();
    cycleTime = dailyTimeMinutes * 60 / unitsToProduce;
  }

  void _calculateWorkStations(
      List<OperationModel> operationSecuence, num cycleTime) {
    double totalOperationTime = 0;
    for (var operation in operationSecuence) {
      totalOperationTime += operation.operation_sam;
    }
    workStations = (totalOperationTime / cycleTime).round();
  }

  List<Map<dynamic, dynamic>> _addTimeLeftFieldToPeople(
      List<PeopleModel> people) {
    List<Map<dynamic, dynamic>> peopleWithTimeLeft = [];
    for (var person in people) {
      Map<dynamic, dynamic> personMap = person.toMap();
      personMap['time_left'] = dailyTimeMinutes;
      peopleWithTimeLeft.add(personMap);
    }
    return peopleWithTimeLeft;
  }

  List<Map<dynamic, dynamic>> _addFieldToOperations(
      List<OperationModel> operations) {
    List<Map<dynamic, dynamic>> operationsToBalance = [];
    for (var operation in operations) {
      Map<dynamic, dynamic> operationMap = operation.toMap();
      operationMap['total_time_left'] =
          operationMap['operation_sam'] * unitsToProduce;
      operationMap['units_person'] = [];
      operationsToBalance.add(operationMap);
    }

    return operationsToBalance;
  }

  List<dynamic> balanceLine() {
    _initialCicleTime();
    _calculateWorkStations(operationSecuence, cycleTime);

    List<Map<dynamic, dynamic>> people = _addTimeLeftFieldToPeople(peopleList);
    //_addTimeLeftFieldToPeople(this.people.sublist(0, workStations));
    List<Map<dynamic, dynamic>> operations =
        _addFieldToOperations(operationSecuence);

    for (var person in people) {
      for (var operation in operations) {
        num unitsProduced = 0;
        if (operation['total_time_left'] > 0 && person['time_left'] > 0) {
          if (person['time_left'] >= operation['total_time_left']) {
            var timeToDiscount = operation['total_time_left'];
            person['time_left'] -= timeToDiscount;
            unitsProduced = timeToDiscount / operation['operation_sam'];
            operation['total_time_left'] = 0;
            operation['units_person'].add({
              'name': '${person['first_name']} ${person['last_name']}',
              'units_per_person': unitsProduced.round()
            });
          } else if (person['time_left'] < operation['total_time_left']) {
            var timeToDiscount = person['time_left'];
            operation['total_time_left'] =
                operation['total_time_left'] - timeToDiscount;
            unitsProduced = timeToDiscount / operation['operation_sam'];
            person['time_left'] = 0;
            operation['units_person'].add({
              'name': '${person['first_name']} ${person['last_name']}',
              'units_per_person': unitsProduced.round()
            });
          }
        }
      }
    }
    for (var operation in operations) {
      var listHourly = [];
      var unitaryOperation = operation['units_person'];
      List.generate(8, (index) => index).forEach((element) {
        listHourly.add(unitaryOperation);
      });
      operation['units_person'] = listHourly;
    }

    return [people, operations];
  }
}
