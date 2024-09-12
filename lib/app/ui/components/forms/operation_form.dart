import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/controllers/add_operation_view_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/services/operations_service.dart';
import '../../../../services/time_record_service.dart';

class OperationForm extends StatefulWidget {
  final bool edit;
  final OperationModel? operationToEdit;
  final ActivityModel activityParent;

  const OperationForm({
    super.key,
    this.edit = false,
    this.operationToEdit,
    required this.activityParent,
  });

  @override
  State<OperationForm> createState() => _OperationFormState();
}

class _OperationFormState extends State<OperationForm> {
  AddOperationViewModel addOperationViewModel = AddOperationViewModel();
  OperationService operationService = OperationService();
  Map validationOptions = {};

  @override
  Widget build(BuildContext context) {
    widget.edit
        ? addOperationViewModel.fillOperationToEdit(widget.operationToEdit!)
        : null;

    validate() {
      setState(() {
        if (addOperationViewModel.operationIdController.text.isEmpty) {
          validationOptions['idValidator'] = 'Debes ingresar un id';
        }
        if (addOperationViewModel.operationNameController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
        if (addOperationViewModel.operationSamController.text.isEmpty) {
          validationOptions['samValidator'] =
              'Debes ingresar un documento tiempo estandar';
        }
      });
    }

    void add() {
      validate();
      if (
          //addOperationViewModel.operationIdController.text.isNotEmpty &&
          addOperationViewModel.operationNameController.text.isNotEmpty &&
              addOperationViewModel.operationSamController.text.isNotEmpty) {
        addOperationViewModel.activityIdController.text =
            widget.activityParent.documentId!;
        print(addOperationViewModel.mapOperation().toMap());
        operationService.postOperation(addOperationViewModel.mapOperation());
        //addOperationViewModel.addOperation(widget.activityParent);
        Navigator.pop(context);
      } else {}
    }

    void executeEditOperation() {
      validate();
      if (
          //addOperationViewModel.operationIdController.text.isNotEmpty &&
          addOperationViewModel.operationNameController.text.isNotEmpty &&
              addOperationViewModel.operationSamController.text.isNotEmpty) {
        operationService.patchOperation(widget.operationToEdit!.documentId!,
            widget.operationToEdit!.toMap());
        Navigator.pop(context);
      } else {}
    }

    void executeDeleteOperation() {
      TimeRecordService _timeRecordService = TimeRecordService();

      OperationService _operationService = OperationService();

      CentralDialogForm.manageDeleteAlert(context, () {
        _operationService.deleteOperation(widget.operationToEdit!.documentId!);

        _timeRecordService.deleteResourcesByKey(
            widget.operationToEdit!.operation_id, 'operation_id');
      }, widget.operationToEdit!.operation_name);
    }

    return CentralDialogForm(
        headerAdd: 'Nueva operación',
        headerEdit: 'Editar operación',
        edit: widget.edit,
        executeEditRecord: executeEditOperation,
        executeAddRecord: add,
        context: context,
        child: operationFormBuilder(context, executeDeleteOperation));
  }

  Column operationFormBuilder(
      BuildContext context, Function() executeDeleteOperation) {
    print('operation form created');
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
                      controller: addOperationViewModel.operationNameController,
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
                  //     controller: addOperationViewModel.operationIdController,
                  //     keyboardType: TextInputType.name,
                  //     header: 'Identificador *',
                  //     obscureText: false,
                  //     customValidator: validationOptions['idValidator'],
                  //   ),
                  // ),
                ],
              ),
              TextFieldFormHeader(
                controller: addOperationViewModel.positionController,
                keyboardType: TextInputType.number,
                header: 'Position *',
                obscureText: false,
                customValidator: validationOptions['positionValidator'],
              ),
              const Divider(
                height: 28,
              ),
              TextFieldFormHeader(
                  controller: addOperationViewModel.operationSamController,
                  keyboardType: TextInputType.text,
                  header: 'SAM *',
                  obscureText: false),
              const Divider(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFieldFormHeader(
                        maxLines: 10,
                        fieldHeight: 100,
                        controller: addOperationViewModel.notesController,
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
                                onPressed: executeDeleteOperation,
                                borderColor: Colors.red,
                                child: const Text(
                                  'Borrar operación',
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
