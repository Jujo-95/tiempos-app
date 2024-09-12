import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/circular_button.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/custom_dropdown2/custom_dropdown_search.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/custom_dropdown2/timepos_custom_dropdown.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/time_record_table.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/services/firebase_paths.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/models/people_model.dart';
import 'package:tiempos_app/models/time_record_model.dart';
import 'package:tiempos_app/services/time_record_service.dart';

class StopwatchComponents extends StatefulWidget {
  const StopwatchComponents({super.key});

  @override
  _StopwatchComponentsState createState() => _StopwatchComponentsState();
}

class _StopwatchComponentsState extends State<StopwatchComponents> {
  final formKey = GlobalKey<FormState>();
  bool _isRunning = false;
  bool _clearView = true;
  Duration _elapsedTime = Duration.zero;
  Stopwatch _stopwatch = Stopwatch();
  TimeRecordMetrics _timeRecordMetrics = TimeRecordMetrics();
  List<Map<String?, dynamic>> people = [];
  bool _hasFinished = false;
  TimeRecordModel timeRecord = TimeRecordModel();
  final FirebasePaths firebasePaths = FirebasePaths.instance;
  bool timeRecordRecorded = false;

  OperationModel operationSelected = OperationModel();
  TimeRecordService timeRecordService = TimeRecordService();

  @override
  void initState() {
    super.initState();
    loadPeople();
  }

  void loadPeople() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 100), _updateElapsedTime);

    onChangedActivity(ActivityModel? data) {
      timeRecord.activity_id = data!.activity_id;
      timeRecord.activity_name = data.activity_name;
    }

    activityItems(ActivityModel? p) => p != null ? p.activity_name : '';

    onFindActivity(String? filter) =>
        firebasePaths.getCollectionByName('activities').get().then((snapshot) {
          return snapshot.docs
              .map((doc) => ActivityModel.fromSnapshot(doc))
              .toList();
        });

    onChangedPerson(PeopleModel? data) {
      timeRecord.id_number = data!.documentId!;
      timeRecord.worker_name = '${data.first_name} ${data.last_name}';
    }

    personItems(PeopleModel? p) => p != null ? p.first_name : '';

    onFindPerson(String? filter) =>
        firebasePaths.getCollectionByName('people').get().then((snapshot) {
          return snapshot.docs
              .map((doc) => PeopleModel.fromSnapshot(doc))
              .toList();
        });

    onChangedOperation(OperationModel? data) {
      timeRecord.operation_id = data!.operation_id;
      timeRecord.operation_name = data.operation_name;
      operationSelected = data;
      _timeRecordMetrics.referenceSam = operationSelected.operation_sam;
    }

    operationItems(OperationModel? p) => p != null ? p.operation_name : '';

    onFindOperation(String? filter) => firebasePaths
            .getCollectionByName('operations')
            .where('activity_id', isEqualTo: timeRecord.activity_id)
            .get()
            .then((snapshot) {
          return snapshot.docs
              .map((doc) => OperationModel.fromSnapshot(doc))
              .toList();
        });

    raiseNoStopwatchElementAlert() {
      setState(() {
        timeRecordRecorded = true;
      });
    }

    validateAndSaveRecord() {
      final form = formKey.currentState;

      if (form!.validate() && _hasFinished) {
        timeRecord.sam = _timeRecordMetrics.sam;
        timeRecord.quality = _timeRecordMetrics.quality;
        timeRecord.created =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
        timeRecordService.postTimeRecord(timeRecord);

        Navigator.pop(context);
      } else if (!_hasFinished) {
        raiseNoStopwatchElementAlert();
      }
    }

    return CentralDialogForm(
        edit: false,
        executeEditRecord: () {},
        executeAddRecord: validateAndSaveRecord,
        context: context,
        headerAdd: 'Nuevo registro',
        child: stopwatchComponentBuilder(
            validateAndSaveRecord,
            personItems,
            onFindPerson,
            onChangedPerson,
            onChangedActivity,
            activityItems,
            onFindActivity,
            onChangedOperation,
            operationItems,
            onFindOperation));
  }

  Form stopwatchComponentBuilder(
      Null Function() validateAndSaveRecord,
      String Function(PeopleModel? p) personItems,
      Future<List<PeopleModel>> Function(String? filter) onFindPerson,
      Null Function(PeopleModel? data) onChangedPerson,
      Null Function(ActivityModel? data) onChangedActivity,
      String Function(ActivityModel? p) activityItems,
      Future<List<ActivityModel>> Function(String? filter) onFindActivity,
      Null Function(OperationModel? data) onChangedOperation,
      String Function(OperationModel? p) operationItems,
      Future<List<OperationModel>> Function(String? filter) onFindOperation) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TiemposCustomDropdown<PeopleModel>(
            validator: (PeopleModel? value) =>
                value == null ? 'Debes seleccionar una persona' : null,
            itemAsString: personItems,
            onFind: onFindPerson,
            onChanged: onChangedPerson,
            hintText: 'Persona*',
          ),
          TiemposCustomDropdown<ActivityModel>(
            validator: (ActivityModel? value) =>
                value == null ? 'Debes seleccionar una referencia' : null,
            onChanged: onChangedActivity,
            itemAsString: activityItems,
            onFind: onFindActivity,
            hintText: 'Actividad*',
          ),
          TiemposCustomDropdown<OperationModel>(
            validator: (OperationModel? value) =>
                value == null ? 'Debes seleccionar una operación' : null,
            onChanged: onChangedOperation,
            itemAsString: operationItems,
            onFind: onFindOperation,
            hintText: 'Operación*',
          ),
          Column(
            children: [
              StopwatchClock(
                add: _start,
                clearView: _clearView,
                elapsedTime: _elapsedTime,
                end: _stop,
                timeRecordMetrics: _timeRecordMetrics,
                lap: _lap,
                hasFinished: _hasFinished,
                reset: _reset,
              ),
              if (timeRecordRecorded)
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No has tomado ningún registro de tiempo',
                        style: TextStyle(
                            color: Color.fromARGB(255, 165, 47, 38),
                            fontSize: 12),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  void _start() {
    setState(() {
      timeRecordRecorded = false;
      _clearView = false;
      _isRunning = true;
      _stopwatch.start();
    });
  }

  void _stop() {
    setState(() {
      if (_isRunning) {
        _timeRecordMetrics.listToCalculateMean.add(_elapsedTime);
        _timeRecordMetrics.calculateMetris();
        _isRunning = false;
        _stopwatch.stop();
        _hasFinished = true;
      }
    });
  }

  void _reset() {
    setState(() {
      _isRunning = false;
      _stopwatch.reset();
      _clearAllMetrics();
      _clearView = true;
      _hasFinished = false;
    });
  }

  void _lap() {
    setState(() {
      if (_isRunning) {
        _timeRecordMetrics.listToCalculateMean.add(_elapsedTime);
        _timeRecordMetrics.calculateMetris();
        _stopwatch.reset();
        _stopwatch.start();
      }
    });
  }

  void _updateElapsedTime() {
    if (_isRunning) {
      setState(() {
        _elapsedTime = _stopwatch.elapsed;
      });
    }
  }

  void _clearAllMetrics() {
    // reset all metrics
    _isRunning = false;
    _clearView = true;
    _elapsedTime = Duration.zero;
    _stopwatch = Stopwatch();
    _timeRecordMetrics = TimeRecordMetrics();
    _hasFinished = false;
  }
}

class StopwatchModel {
  String? activity_id;
  String? created;
  String? id_number;
  String? modified;
  String? notes;
  String? operation_id;
  double? sam;
  String? user_id;
  String? worker_name;
}

class TimeRecordMetrics {
  List<Duration> listToCalculateMean = [];
  Duration meanDuration = Duration.zero;
  double sam = 0;
  num upm = double.infinity;
  int meanInSeconds = 0;
  int counterUnits = 0;
  Duration totalDuration = Duration.zero;
  int countUnits = 0;
  int meanDurationInSeconds = 0;
  List<Duration> filteredList = [];
  num quality = 0;
  int listLength = 0;
  List<num> qualityItems = [];
  num referenceSam = 0;
  bool recordFasterThanReferenceFlag = false;

  List<Duration> filterList() {
    return listToCalculateMean.whereType<Duration>().toList();
  }

  int calculateLength() {
    return filterList().length;
  }

  Duration calculateTotalDuration() {
    return filterList().fold<Duration>(Duration.zero,
        (Duration previousValue, Duration element) => previousValue + element);
  }

  Duration calculateMean() {
    return calculateTotalDuration() ~/ calculateLength();
  }

  int calculateMeanInSeconds() {
    return calculateMean().inSeconds;
  }

  double calculateSam() {
    return (calculateMeanInSeconds() * 1000).round() / 1000 / 60;
  }

  num calculateUpm() {
    return calculateMeanInSeconds() > 0
        ? (60 / calculateMeanInSeconds()).round()
        : double.infinity;
  }

  num calculateQuality({num listLenght = 0}) {
    quality = listLenght / calculateLength();
    return quality;
  }

  bool recordFasterThanReference() {
    bool recordFasterThanReferenceFlag = calculateSam() < referenceSam;
    return recordFasterThanReferenceFlag;
  }

  List<num> calculateQualityItems() {
    return List.generate(calculateLength() + 1, (index) => index);
  }

  calculateMetris() {
    listLength = calculateLength();
    meanDuration = calculateMean();
    countUnits = calculateLength();
    sam = calculateSam();
    upm = calculateUpm();
    qualityItems = calculateQualityItems();
    recordFasterThanReferenceFlag = recordFasterThanReference();
  }
}

class TimeRecordMetricsFromSam {}

class StopwatchClock extends StatelessWidget {
  final bool clearView;
  final Duration elapsedTime;
  final bool hasFinished;
  final add;
  final end;
  final lap;
  final reset;
  final TimeRecordMetrics timeRecordMetrics;

  const StopwatchClock({
    super.key,
    required this.timeRecordMetrics,
    this.clearView = true,
    this.elapsedTime = Duration.zero,
    this.hasFinished = false,
    this.add,
    this.end,
    this.lap,
    this.reset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Tiempo',
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        clearView
            ? const Text(
                style: TextStyle(
                  fontSize: 43,
                  letterSpacing: 1,
                ),
                '00:00.00')
            : Text(
                style: const TextStyle(
                  fontSize: 43,
                  letterSpacing: 1,
                ),
                elapsedTime.toString().substring(2, 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Promedio',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                clearView
                    ? const Text(
                        style: TextStyle(fontSize: 20),
                        '00:00.00',
                      )
                    : Text(
                        style: const TextStyle(fontSize: 20, letterSpacing: 1),
                        timeRecordMetrics.meanDuration
                            .toString()
                            .substring(2, 10),
                      ),
              ],
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'SAM',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                clearView
                    ? const Text(
                        style: TextStyle(fontSize: 20),
                        '--',
                      )
                    : Text(
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                timeRecordMetrics.recordFasterThanReferenceFlag
                                    ? Colors.green
                                    : Colors.red),
                        timeRecordMetrics.sam.toStringAsFixed(3),
                      )
              ],
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'und/min',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                clearView
                    ? const Text(
                        style: TextStyle(fontSize: 20),
                        '--',
                      )
                    : Text(
                        style: const TextStyle(fontSize: 20),
                        timeRecordMetrics.upm.toString(),
                      ),
              ],
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Conteo',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                clearView
                    ? const Text(
                        style: TextStyle(fontSize: 20),
                        '--',
                      )
                    : Text(
                        style: const TextStyle(fontSize: 20, letterSpacing: 1),
                        timeRecordMetrics.listLength.toString(),
                      ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 14,
        ),
        ActionButtons(
          timeRecordMetrics: timeRecordMetrics,
          add: add,
          clearView: clearView,
          end: end,
          hasFinished: hasFinished,
          lap: lap,
          reset: reset,
        ),
        const SizedBox(
          height: 14,
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  final bool clearView;
  final bool hasFinished;
  final add;
  final end;
  final lap;
  final reset;
  final TimeRecordMetrics timeRecordMetrics;

  const ActionButtons({
    super.key,
    required this.timeRecordMetrics,
    this.clearView = true,
    this.hasFinished = false,
    this.add,
    this.end,
    this.lap,
    this.reset,
  });

  @override
  Widget build(BuildContext context) {
    return !hasFinished
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularButton(
                backgroundColor: Colors.white70,
                borderColor: const Color(0xFF2952E1),
                onPressed: end,
                textColor: const Color(0xFF2952E1),
                child: const Text(
                  'Finalizar',
                  style: TextStyle(color: Color(0xFF2952E1)),
                ),
              ),
              clearView
                  ? CircularButton(
                      backgroundColor: Colors.white70,
                      borderColor: const Color(0xFF20BF86),
                      onPressed: add,
                      textColor: const Color(0xFF20BF86),
                      child: const Text(
                        'Inicio',
                        style: TextStyle(color: Color(0xFF20BF86)),
                      ))
                  : CircularButton(
                      backgroundColor: Colors.white70,
                      borderColor: const Color(0xFF20BF86),
                      onPressed: lap,
                      textColor: const Color(0xFF20BF86),
                      child: const Text(
                        'Vuelta',
                        style: TextStyle(color: Color(0xFF20BF86)),
                      ),
                    ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularButton(
                backgroundColor: Colors.white70,
                borderColor: const Color(0xFF2952E1),
                onPressed: reset,
                textColor: const Color(0xFF2952E1),
                child: const Text(
                  'Reiniciar',
                  style: TextStyle(color: Color(0xFF2952E1)),
                ),
              ),
              SizedBox(
                  width: 200,
                  child: TiemposCustomDropdown<num>(
                      validator: (value) =>
                          value == null ? 'selecciona unidades ok' : null,
                      showSearchBox: false,
                      hintText: 'Calidad*',
                      onChanged: (value) {
                        timeRecordMetrics
                            .calculateQuality(listLenght: value!)
                            .toString();
                      },
                      items: timeRecordMetrics.calculateQualityItems()))
            ],
          );
  }
}

class DropdownElementsStopWatch extends StatelessWidget {
  List<dynamic> activityTable;
  List<dynamic> operationsTable;
  List<dynamic> peopleTable;

  DropdownElementsStopWatch(
      {super.key,
      required this.peopleTable,
      required stopwatchProvider,
      required this.activityTable,
      required this.operationsTable});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownSearch<PeopleModel>(
      dropdownSearchDecoration: const InputDecoration(labelText: "Name"),
      itemAsString: (PeopleModel? p) => p != null ? p.first_name : '',
    );
  }
}
