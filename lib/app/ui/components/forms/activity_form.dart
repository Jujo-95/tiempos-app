import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';

import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/controllers/add_activity_view_model.dart';
import 'package:tiempos_app/services/activity_service.dart';

class ActivityForm extends StatefulWidget {
  final bool edit;
  final ActivityModel? activityToEdit;

  const ActivityForm({
    super.key,
    this.edit = false,
    this.activityToEdit,
  });

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  AddActivityViewModel addActivityViewModel = AddActivityViewModel();
  ActivityService activityService = ActivityService();

  Map validationOptions = {};

  @override
  Widget build(BuildContext context) {
    widget.edit
        ? addActivityViewModel.fillActivityToEdit(widget.activityToEdit!)
        : null;

    validate() {
      setState(() {
        // if (addActivityViewModel.activityIdController.text.isEmpty) {
        //   validationOptions['idValidator'] = 'Debes ingresar un id';
        // }
        if (addActivityViewModel.activityNameController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
        // if (addActivityViewModel.defaultMinuteRateController.text.isEmpty) {
        //   validationOptions['minuteRateValidator'] =
        //       'Debes ingresar un documento tiempo estandar';
        // }
      });
    }

    void executeAddActivity() {
      validate();

      if (
          //addActivityViewModel.activityIdController.text.isNotEmpty &&
          addActivityViewModel.activityNameController.text.isNotEmpty
          //addActivityViewModel.defaultMinuteRateController.text.isNotEmpty

          ) {
        print(addActivityViewModel.mapActivity());
        activityService.postActivity(addActivityViewModel.mapActivity());
        //addActivityViewModel.addActivity();
        Navigator.pop(context);
      } else {}
    }

    void executeEditActivity() {
      validate();
      if (
          //addActivityViewModel.activityIdController.text.isNotEmpty &&
          addActivityViewModel.activityNameController.text.isNotEmpty
          //&&
          //addActivityViewModel.defaultMinuteRateController.text.isNotEmpty
          ) {
        activityService.patchActivity(widget.activityToEdit!.documentId!,
            addActivityViewModel.mapActivity());
        Navigator.pop(context);
      } else {}
    }

    void executeDeleteActivity() {
      CentralDialogForm.manageDeleteAlert(context, () {
        activityService.deleteActivity(
          widget.activityToEdit!.documentId!,
        );
      }, widget.activityToEdit!.activity_name);
    }

    return CentralDialogForm(
        headerAdd: 'Nueva referencia',
        headerEdit: 'Editar referencia',
        edit: widget.edit,
        executeEditRecord: executeEditActivity,
        executeAddRecord: executeAddActivity,
        context: context,
        child: activityFormBuilder(executeDeleteActivity));
  }

  Column activityFormBuilder(Function() executeDeleteActivity) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFieldFormHeader(
                      controller: addActivityViewModel.activityNameController,
                      keyboardType: TextInputType.name,
                      header: 'Nombre *',
                      obscureText: false,
                      customValidator: validationOptions['nameValidator'],
                    ),
                  ),
                  const VerticalDivider(
                    width: 14,
                  ),
                  // Expanded(
                  //   child: TextFieldFormHeader(
                  //     readOnly: widget.edit ? true : false,
                  //     controller: addActivityViewModel.activityIdController,
                  //     keyboardType: TextInputType.name,
                  //     header: 'Descripción *',
                  //     obscureText: false,
                  //     customValidator: validationOptions['idValidator'],
                  //   ),
                  // ),
                ],
              ),
              TextFieldFormHeader(
                controller: addActivityViewModel.defaultMinuteRateController,
                keyboardType: TextInputType.number,
                header: 'Tiempo estandar *',
                obscureText: false,
                customValidator: validationOptions['minuteRateValidator'],
              ),
              const Divider(
                height: 28,
              ),
              TextFieldFormHeader(
                  controller: addActivityViewModel.responsablePeopleController,
                  keyboardType: TextInputType.text,
                  header: 'Responsable',
                  obscureText: false),
              const Divider(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFieldFormHeader(
                        maxLines: 10,
                        fieldHeight: 100,
                        controller: addActivityViewModel.notesController,
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
                                onPressed: executeDeleteActivity,
                                borderColor: Colors.red,
                                child: const Text(
                                  'Borrar referencia',
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
    ]);
  }
}
