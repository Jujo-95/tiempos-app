import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/activities_dropdown.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/dashboard_form_people_provider.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/dashboard_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/models/people_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/dashboard_service.dart';
import 'package:tiempos_app/services/operations_service.dart';
import 'package:tiempos_app/services/people_service.dart';

import '../../../../models/controllers/dashboard_view_model.dart';
import '../custom_widgets/custom_multi_select_v2/custom_multi_select_v2.dart';

class DashboardForm extends StatefulWidget {
  final bool edit;
  final DashboardModel? dashboardToEdit;
  int currentPageIndex;
  List<PeopleModel> peopleItemList;
  Future<List<OperationModel>>? selectedOperations;
  List<OperationModel>? initiallySelectedOperations;
  late Future<List<ActivityModel>> activityItemsList;
  ActivityModel selectedActivity =
      ActivityModel(activity_name: 'Seleccionar referencia');
  bool clearItems = false;

  late Future<List<PeopleModel>> peopleItemListFuture;

  List<PeopleModel>? initiallySelectedPeople;

  bool clearPeopleItems = false;

  Function(bool) reloadDashboards;

  DashboardForm(
      {super.key,
      int? currentPageIndex,
      this.edit = false,
      this.dashboardToEdit,
      this.initiallySelectedOperations,
      this.initiallySelectedPeople,
      required this.reloadDashboards})
      : currentPageIndex = 0,
        peopleItemList = [];

  @override
  State<DashboardForm> createState() => _DashboardFormState();
}

class _DashboardFormState extends State<DashboardForm> {
  AddDashboardViewModel addDashboardViewModel = AddDashboardViewModel();
  DashboardService dashboardService = DashboardService();
  ActivityService activityService = ActivityService();
  OperationService operationService = OperationService();
  PeopleService peopleService = PeopleService();

  final List<int> deltaMinutesList = [60]; //[5, 10, 15, 30, 45, 60];
  String samTextReference = '';
  String peopleCountText = '';

  List<PeopleModel> _items = [];

  num countOfPeople = 0;

  Map validationOptions = {};

  num samAndEfficiency = 0;

  List<TimeOfDay> generateTimesOfDay() {
    List<TimeOfDay> listTimeOfDay = [];
    List<int> hours = List.generate(24, (index) => index);
    List<int> minutes = [0, 15, 30, 45];

    for (int hour in hours) {
      for (int minute in minutes) {
        listTimeOfDay.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return listTimeOfDay;
  }

  List<ActivityModel> selectedActivities = [];
  Future<List<OperationModel>>? _selectedOperations;

  @override
  void initState() {
    super.initState();
    // init all default controllers
    addDashboardViewModel.efficiencyController.text = 1.toString();
    addDashboardViewModel.deltaMinutes = 60;
    addDashboardViewModel.scheduled_hoursController.text = 8.toString();
    addDashboardViewModel.startTime =
        formatDatetime(DateTime.now()); //formatDatetime(DateTime.now());
    widget.activityItemsList = activityService.fetchAllItems();
    widget.peopleItemListFuture = peopleService.fetchAllItems();
    _selectedOperations = widget.selectedOperations;
  }

  String formatDatetime(DateTime now) {
    return DateTime(now.year, now.month, now.day, 6, 0).toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    widget.edit
        ? addDashboardViewModel.fillActivityToEdit(widget.dashboardToEdit!)
        : null;

    validate() {
      setState(() {
        if (addDashboardViewModel.module_nameController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
        if (addDashboardViewModel.efficiencyController.text.isEmpty) {
          validationOptions['efficiencyController'] =
              'Debes ingresar una eficiencia';
        }
        if (addDashboardViewModel.peopleList.isEmpty) {
          validationOptions['peopleSelectedValidator'] =
              'Debes seleccionar las personas y operaciones';
        }
      });
    }

    void executeAddActivity() {
      validate();

      if (addDashboardViewModel.module_nameController.text.isNotEmpty &&
          addDashboardViewModel.efficiencyController.text.isNotEmpty) {
        addDashboardViewModel.dateController.text =
            DashboardService.dateIsoFormat(DateTime.now().toIso8601String());
        print(addDashboardViewModel.mapDashboard().toMap());
        try {
          dashboardService.postDashboard(addDashboardViewModel.mapDashboard());
        } catch (e) {
          print(e);
        }
        Navigator.pop(context);
        widget.reloadDashboards(true);
      } else {}
    }

    void executeEditActivity() {
      validate();
      if (addDashboardViewModel.module_nameController.text.isNotEmpty &&
          addDashboardViewModel.efficiencyController.text.isNotEmpty) {
        dashboardService.patchDashboard(widget.dashboardToEdit!.documentId!,
            widget.dashboardToEdit!.toMap());
        Navigator.pop(context);
      } else {}
    }

    void executeDeleteActivity() {
      // CentralDialogForm.manageDeleteAlert(context, () {
      //   dashboardService.(widget.dashboardToEdit!);
      // }, widget.dashboardToEdit!.activity_name);
    }

    final PageController pageController = PageController();
    List<bool> isSelected = [
      true,
      false
    ]; // Initially the first button is selected

    void selectPage(int pageIndex) {
      setState(() {
        widget.currentPageIndex = pageIndex;
        pageController.animateToPage(
          widget.currentPageIndex,
          duration: const Duration(milliseconds: 100),
          curve: Curves.ease,
        );
      });
    }

    return CentralDialogForm(
        headerAdd: 'Nuevo tablero',
        headerEdit: 'Editar tablero',
        edit: widget.edit,
        executeEditRecord: executeEditActivity,
        executeAddRecord: executeAddActivity,
        context: context,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldFormHeader(
                          controller:
                              addDashboardViewModel.module_nameController,
                          keyboardType: TextInputType.name,
                          header: 'Nombre *',
                          obscureText: false,
                          customValidator: validationOptions['nameValidator'],
                        ),
                      ),
                      const VerticalDivider(
                        width: 12,
                      ),
                      Expanded(
                        child: TextFieldFormHeader(
                            controller:
                                addDashboardViewModel.efficiencyController,
                            keyboardType: TextInputType.number,
                            header: 'Eficiencia',
                            obscureText: false,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200),
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      splashRadius: 0.01,
                                      onPressed: () {
                                        setState(() {
                                          samAndEfficiency -= 5;
                                          addDashboardViewModel
                                                  .efficiencyController.text =
                                              (samAndEfficiency / 100 + 1)
                                                  .toStringAsFixed(2);
                                        });
                                      },
                                      icon: const Icon(Icons.remove)),
                                  Text(
                                    '${samAndEfficiency > 1 ? '+' : samAndEfficiency == 1 ? '' : ''} $samAndEfficiency  % ',
                                    style: TextStyle(
                                        color: samAndEfficiency > 1
                                            ? Colors.blueAccent
                                            : samAndEfficiency == 1
                                                ? Colors.black
                                                : Colors.red),
                                  ),
                                  IconButton(
                                      splashRadius: 0.01,
                                      onPressed: () {
                                        setState(() {
                                          samAndEfficiency += 5;
                                          addDashboardViewModel
                                                  .efficiencyController.text =
                                              (samAndEfficiency / 100 + 1)
                                                  .toStringAsFixed(2);
                                        });
                                      },
                                      icon: const Icon(Icons.add))
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldFormHeader(
                            keyboardType: TextInputType.name,
                            header: 'Horas a programar',
                            obscureText: false,
                            customValidator:
                                validationOptions['scheduled_hoursController'],
                            child: DropdownButtonFormField<int>(
                              value: 8,
                              decoration: dropdownInputDecoration(),
                              onChanged: (value) {
                                setState(() {
                                  addDashboardViewModel
                                      .scheduled_hoursController
                                      .text = value.toString();
                                });
                              },
                              items: List.generate(24, (index) => index)
                                  .map<DropdownMenuItem<int>>(
                                      (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e.toString()),
                                          ))
                                  .toList(),
                            )),
                      ),
                      const VerticalDivider(
                        width: 12,
                      ),
                      Expanded(
                        child: TextFieldFormHeader(
                            readOnly: true,
                            keyboardType: TextInputType.name,
                            header: 'Hora Inicio',
                            obscureText: false,
                            customValidator:
                                validationOptions['startTimeValidator'],
                            child: DropdownButtonFormField<TimeOfDay>(
                                value: const TimeOfDay(hour: 6, minute: 0),
                                decoration: dropdownInputDecoration(),
                                items: generateTimesOfDay()
                                    .map<DropdownMenuItem<TimeOfDay>>(
                                        (TimeOfDay e) {
                                  return DropdownMenuItem<TimeOfDay>(
                                    value: e,
                                    child: Text(e.format(context)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    DateTime now = DateTime.now();

                                    addDashboardViewModel.startTime = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            value!.hour,
                                            value.minute)
                                        .toIso8601String();
                                  });
                                })),
                      ),
                      const VerticalDivider(
                        width: 12,
                      ),
                      Expanded(
                        child: TextFieldFormHeader(
                            readOnly: true,
                            keyboardType: TextInputType.name,
                            header: 'Intervalo',
                            obscureText: false,
                            customValidator:
                                validationOptions['deltaMinutesValidator'],
                            child: DropdownButtonFormField<int>(
                                value: 60,
                                decoration: dropdownInputDecoration(),
                                items: deltaMinutesList.map((int e) {
                                  return DropdownMenuItem(
                                      value: e, child: Text('$e min'));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    addDashboardViewModel.deltaMinutes = value!;
                                  });
                                })),
                      ),
                    ],
                  ),
                  Container(
                    height: 45,
                    padding: const EdgeInsets.all(4),
                    decoration: toogleButtonDecoration('background'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                              child: Container(
                                height: double.infinity,
                                decoration: toogleButtonDecoration(
                                    widget.currentPageIndex == 0
                                        ? 'on'
                                        : 'off'),
                                child: Center(
                                  child: Text(
                                    'Referencia $samTextReference',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: widget.currentPageIndex == 0
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                ),
                              ),
                              onTap: () => selectPage(0)),
                        ),
                        Expanded(
                          child: GestureDetector(
                              child: Container(
                                height: 40,
                                decoration: toogleButtonDecoration(
                                    widget.currentPageIndex == 1
                                        ? 'on'
                                        : 'off'),
                                child: Center(
                                  child: Text(
                                    'Personas $peopleCountText',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: widget.currentPageIndex == 1
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                ),
                              ),
                              onTap: () {
                                selectPage(1);
                                DashboardFormPeopleProvider().getPeopleItems();
                                //triggerGetPeopleItems();
                              }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 200,
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          widget.currentPageIndex = index;
                          isSelected = List.generate(
                              isSelected.length, (i) => i == index);
                        });
                      },
                      children: [
                        SizedBox(
                            height: 45,
                            child: processDropdownBuilder(false, (sam) {
                              setState(() {
                                samTextReference =
                                    ' (${sam.toStringAsFixed(2)})';
                              });
                            })),
                        SizedBox(
                            height: 100,
                            child: peopleMultiSelectBuilder(_items)),
                      ],
                    ),
                  ),
                  Container(),
                  Column(
                    children: [
                      !widget.edit
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                ButtonRounded(
                                    backgroundColor: Colors.grey.shade100,
                                    width: double.infinity,
                                    onPressed: executeDeleteActivity,
                                    borderColor: Colors.red,
                                    child: const Text(
                                      'Borrar tablero',
                                      style: TextStyle(color: Colors.red),
                                    )),
                                const Divider(
                                  color: Colors.transparent,
                                ),
                              ],
                            )
                    ],
                  ),
                ],
              ))
        ]));
  }

  BoxDecoration toogleButtonDecoration(String? type) {
    if (type == 'background') {
      return BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(
            width: 0,
            color: Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(8));
    } else if (type == 'on') {
      return BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 0,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(12));
    } else if (type == 'off') {
      return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 0,
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12));
    } else {
      return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 0,
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12));
    }
  }

  InputDecoration dropdownInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(12),
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget peopleMultiSelectBuilder(List<PeopleModel> items) {
    return Column(
      children: [
        FutureBuilder(
            future: widget.peopleItemListFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Text(snapshot.data.toString());
                return MultiSelector<PeopleModel>(
                  clearItems: widget.clearPeopleItems,
                  resetClearBool: (resetClearBool) {
                    widget.clearPeopleItems = resetClearBool;
                  },
                  initialSelectedItems: widget.initiallySelectedPeople ?? [],
                  itemsFuture: snapshot
                      .data!, //operationService.fetchAllItemsByActivity(selectedActivity),
                  displayItem: (item) => item.first_name,
                  onSelectItem: (peopleSelected) {
                    widget.initiallySelectedPeople = peopleSelected;
                    addDashboardViewModel.peopleList =
                        peopleSelected.map(((e) => e.id_number)).toList();
                    print(peopleSelected);
                  },
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return MultiSelector.emptyCheckBox();
              }
            }),
      ],
    );
  }

  Widget processDropdownBuilder(bool a, Function(num) sam) {
    void sumSam(List<OperationModel> operations) {
      num samValueSum =
          operations.fold(0, (sum, operation) => sum + operation.operation_sam);

      // to be used
      sam(samValueSum);

      setState(() {
        addDashboardViewModel.dashboard_samController.text =
            samValueSum.toStringAsFixed(3);
      });
    }

    generatelistOfOperationId(List<OperationModel> operations) {
      List<dynamic> operationList = operations.map((OperationModel e) {
        return e.operation_id.toString();
      }).toList();

      setState(() {
        addDashboardViewModel.operationList = operationList;
      });
    }

    void onActivityChanged(ActivityModel activity) {
      setState(() {
        widget.clearItems = true;
        widget.initiallySelectedOperations = [];
        widget.selectedActivity = activity;
        _selectedOperations =
            operationService.fetchAllItemsByActivity(activity);
        addDashboardViewModel.operationList = [];
        addDashboardViewModel.process_idController.text = activity.activity_id;
        addDashboardViewModel.dashboard_samController.clear();
      });
    }

    return Column(
      children: [
        FutureBuilder(
            future: widget.activityItemsList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    SizedBox(
                      child: DropdownActivities(
                          items: snapshot.data!,
                          activitySelected: widget.selectedActivity,
                          onChangedActivity: onActivityChanged),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        FutureBuilder(
          future: _selectedOperations, //widget.selectedOperations,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return MultiSelector<OperationModel>(
                clearItems: widget.clearItems,
                resetClearBool: (resetClearBool) {
                  widget.clearItems = resetClearBool;
                },
                initialSelectedItems: widget.initiallySelectedOperations ?? [],
                itemsFuture: snapshot
                    .data!, //operationService.fetchAllItemsByActivity(selectedActivity),
                displayItem: (item) => item.operation_name,
                onSelectItem: (operationsSelected) {
                  widget.initiallySelectedOperations = operationsSelected;
                  addDashboardViewModel.operationList = operationsSelected;

                  sumSam(operationsSelected);
                  generatelistOfOperationId(operationsSelected);
                },
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return MultiSelector.emptyCheckBox();
            }
          }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
