import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/custom_tiempos_data_picker.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/controllers/add_people_model.dart';
import 'package:tiempos_app/models/people_model.dart';
import 'package:tiempos_app/services/people_service.dart';
import 'package:tiempos_app/services/time_record_service.dart';

class PersonForm extends StatefulWidget {
  final bool edit;
  final PeopleModel? peopleToEdit;

  const PersonForm({
    super.key,
    this.edit = false,
    this.peopleToEdit,
  });

  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> {
  AddPersonViewModel addPersonViewModel = AddPersonViewModel();
  PeopleService peopleService = PeopleService();
  Map validationOptions = {};

  @override
  Widget build(BuildContext context) {
    widget.edit
        ? addPersonViewModel.fillPersonToEdit(widget.peopleToEdit!)
        : null;

    validate() {
      setState(() {
        if (addPersonViewModel.firstNameController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
        if (addPersonViewModel.lastNameController.text.isEmpty) {
          validationOptions['lasNameValidator'] = 'Debes ingresar un apellido';
        }
        if (addPersonViewModel.idNumberController.text.isEmpty) {
          validationOptions['idValidator'] =
              'Debes ingresar un documento de identificación';
        }
      });
    }

    void add() {
      validate();
      if (addPersonViewModel.firstNameController.text.isNotEmpty &&
          addPersonViewModel.lastNameController.text.isNotEmpty &&
          addPersonViewModel.idNumberController.text.isNotEmpty) {
        peopleService.postPeople(addPersonViewModel.mapPerson());
        Navigator.pop(context);
      } else {}
    }

    void executeEditPeople() {
      validate();
      if (addPersonViewModel.firstNameController.text.isNotEmpty &&
          addPersonViewModel.lastNameController.text.isNotEmpty &&
          addPersonViewModel.idNumberController.text.isNotEmpty) {
        peopleService.patchPeople(widget.peopleToEdit!.documentId!,
            addPersonViewModel.mapPerson().toMap());
        Navigator.pop(context);
      } else {}
    }

    void executeDeletePeople() {
      TimeRecordService _timeRecordService = TimeRecordService();

      String personFullName =
          '${widget.peopleToEdit!.first_name} ${widget.peopleToEdit!.last_name}';
      CentralDialogForm.manageDeleteAlert(context, () {
        peopleService.deletePerson(widget.peopleToEdit!.documentId!);
        _timeRecordService.deleteResourcesByKey(
            widget.peopleToEdit!.id_number, 'id_number');
      }, personFullName);
    }

    presentDataPicker() {
      customTiemposDataPicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(DateTime.now().year),
              lastDate: DateTime.now())
          .then((pickedDate) {
        if (pickedDate == null) {
          return;
        }
        addPersonViewModel.startDateController.text =
            pickedDate.toString().substring(0, 10);
      });
    }

    return CentralDialogForm(
        headerEdit: 'Editar persona',
        headerAdd: 'Nueva persona',
        edit: widget.edit,
        executeEditRecord: executeEditPeople,
        executeAddRecord: add,
        context: context,
        child:
            personFormBuilder(context, presentDataPicker, executeDeletePeople));
  }

  Column personFormBuilder(
      BuildContext context, presentDataPicker, executeDeletePerson) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFieldFormHeader(
                      controller: addPersonViewModel.firstNameController,
                      keyboardType: TextInputType.name,
                      header: 'Nombre *',
                      obscureText: false,
                      customValidator: validationOptions['nameValidator'],
                    ),
                  ),
                  const VerticalDivider(
                    width: 14,
                  ),
                  Expanded(
                    child: TextFieldFormHeader(
                      controller: addPersonViewModel.lastNameController,
                      keyboardType: TextInputType.name,
                      header: 'Apellido *',
                      obscureText: false,
                      customValidator: validationOptions['lastNameValidator'],
                    ),
                  ),
                ],
              ),
              TextFieldFormHeader(
                controller: addPersonViewModel.idNumberController,
                keyboardType: TextInputType.number,
                header: 'Numero de identificación (C.C.) *',
                obscureText: false,
                customValidator: validationOptions['idValidator'],
              ),
              const Divider(
                height: 28,
              ),
              TextFieldFormHeader(
                  controller: addPersonViewModel.jobTitleController,
                  keyboardType: TextInputType.text,
                  header: 'Cargo',
                  obscureText: false),
              TextFieldFormHeader(
                  controller: addPersonViewModel.departmentController,
                  keyboardType: TextInputType.text,
                  header: 'Departamento',
                  obscureText: false),
              TextFieldFormHeader(
                  controller: addPersonViewModel.emailController,
                  keyboardType: TextInputType.text,
                  header: 'Correo Electrónico',
                  obscureText: false),
              TextFieldFormHeader(
                  controller: addPersonViewModel.countryController,
                  keyboardType: TextInputType.text,
                  header: 'País',
                  obscureText: false),
              TextFieldFormHeader(
                  controller: addPersonViewModel.cityController,
                  keyboardType: TextInputType.emailAddress,
                  header: 'Ciudad',
                  obscureText: false),
              TextFieldFormHeader(
                  controller: addPersonViewModel.startDateController,
                  keyboardType: TextInputType.datetime,
                  header: 'Fecha de inicio',
                  obscureText: false,
                  sufixIconColor: Theme.of(context).primaryColor,
                  suffixIcon: IconButton(
                    onPressed: presentDataPicker,
                    icon: const Icon(Icons.date_range_rounded),
                    splashRadius: 0.1,
                  )),
              TextFieldFormHeader(
                controller: addPersonViewModel.defaultHourlyRateController,
                keyboardType: TextInputType.number,
                header: 'Salario (por hora)',
                obscureText: false,
                inputFormatters: [InputTextFilteringOptions().doubleOrInt],
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horas de trabajo diario',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextFieldFormHeader(
                            controller:
                                addPersonViewModel.workDaysHoursController[0],
                            keyboardType: TextInputType.number,
                            header: 'Lun',
                            obscureText: false,
                            inputFormatters: [
                              InputTextFilteringOptions().maxOneDay
                            ],
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: TextFieldFormHeader(
                            controller:
                                addPersonViewModel.workDaysHoursController[1],
                            keyboardType: TextInputType.number,
                            header: 'Mar',
                            obscureText: false,
                            inputFormatters: [
                              InputTextFilteringOptions().maxOneDay
                            ],
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: TextFieldFormHeader(
                            controller:
                                addPersonViewModel.workDaysHoursController[2],
                            keyboardType: TextInputType.number,
                            header: 'Mie',
                            obscureText: false,
                            inputFormatters: [
                              InputTextFilteringOptions().maxOneDay
                            ],
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: TextFieldFormHeader(
                            controller:
                                addPersonViewModel.workDaysHoursController[3],
                            keyboardType: TextInputType.number,
                            header: 'Jue',
                            obscureText: false,
                            inputFormatters: [
                              InputTextFilteringOptions().maxOneDay
                            ],
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: TextFieldFormHeader(
                            controller:
                                addPersonViewModel.workDaysHoursController[4],
                            keyboardType: TextInputType.number,
                            header: 'Vie',
                            obscureText: false,
                            inputFormatters: [
                              InputTextFilteringOptions().maxOneDay
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Expanded(child: SizedBox()),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: TextFieldFormHeader(
                            controller:
                                addPersonViewModel.workDaysHoursController[5],
                            keyboardType: TextInputType.number,
                            header: 'Sab',
                            obscureText: false),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: TextFieldFormHeader(
                          controller:
                              addPersonViewModel.workDaysHoursController[6],
                          keyboardType: TextInputType.number,
                          header: 'Dom',
                          obscureText: false,
                          inputFormatters: [
                            InputTextFilteringOptions().maxOneDay
                          ],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFieldFormHeader(
                        maxLines: 10,
                        fieldHeight: 100,
                        controller: addPersonViewModel.notesController,
                        keyboardType: TextInputType.multiline,
                        header: 'Notas',
                        obscureText: false),
                  ),
                  !widget.edit
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            ButtonRounded(
                                backgroundColor: Colors.grey.shade100,
                                width: double.infinity,
                                onPressed: () {
                                  executeDeletePerson();
                                },
                                borderColor: Colors.red,
                                child: const Text(
                                  'Borrar persona',
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
          ),
        )
      ],
    );
  }
}
