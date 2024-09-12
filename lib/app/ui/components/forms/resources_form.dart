import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import '../../../../models/resource_model.dart';
import '../../../../services/resources_service.dart';
import '../custom_widgets/button_rounded.dart';
import '../custom_widgets/central_dialog_form.dart';

class ResourceForm extends StatefulWidget {
  final bool edit;
  final ResourceModel? resourceToEdit;

  const ResourceForm({super.key, this.resourceToEdit, this.edit = false});

  @override
  _ResourceFormState createState() => _ResourceFormState();
}

class _ResourceFormState extends State<ResourceForm> {
  final _formKey = GlobalKey<FormState>();
  final ResourceService _resourceService = ResourceService();
  late ResourceModel? newResource;

  // Define controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _operationsController;
  late TextEditingController _resource_nameController;
  late TextEditingController _resource_idController;
  late TextEditingController _notesController;
  Map validationOptions = {};

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  void initializeControllers() {
    if (widget.edit && widget.resourceToEdit != null) {
      _nameController =
          TextEditingController(text: widget.resourceToEdit!.resource_name);
      _operationsController = TextEditingController(
          text: widget.resourceToEdit!.operations.join(', '));
      _resource_nameController =
          TextEditingController(text: widget.resourceToEdit!.resource_name);
      _resource_idController =
          TextEditingController(text: widget.resourceToEdit!.resource_id);
      _notesController =
          TextEditingController(text: widget.resourceToEdit!.modified);
    } else {
      newResource = ResourceModel();
      _nameController = TextEditingController(text: newResource!.resource_name);
      _operationsController =
          TextEditingController(text: newResource!.operations.join(', '));
      _resource_nameController =
          TextEditingController(text: newResource!.resource_name);
      _resource_idController =
          TextEditingController(text: newResource!.resource_id);
      _notesController = TextEditingController(text: newResource!.modified);
    }
  }

  ResourceModel fillRrecordToSave() {
    ResourceModel resourceToSave;
    if (widget.edit) {
      resourceToSave = widget.resourceToEdit!;
    } else {
      resourceToSave = newResource!;
    }
    resourceToSave.resource_name = _nameController.text;
    resourceToSave.operations = _operationsController.text.split(', ');
    resourceToSave.resource_name = _resource_nameController.text;
    resourceToSave.resource_id = _resource_idController.text;
    resourceToSave.modified = _notesController.text;
    return resourceToSave;
  }

  bool validate() {
    setState(() {
      if (_nameController.text.isEmpty) {
        validationOptions['nameValidator'] = 'Debes ingresar un nombre';
      }
    });
    if (validationOptions == {}) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CentralDialogForm(
      headerAdd: 'Nuevo recurso',
      headerEdit: 'Editar recurso',
      edit: widget.edit,
      executeEditRecord: executeEditResource,
      executeAddRecord: executeAddResource,
      context: context,
      child: resourcesFormBuilder(context),
    );
  }

  void executeAddResource() {
    newResource = fillRrecordToSave();
    _resourceService.postResource(newResource!);
    Navigator.pop(context);
  }

  void executeEditResource() {
    // Update the fields of the People model
    ResourceModel resourceToEdit = fillRrecordToSave();
    // Patch the People model in Firebase
    _resourceService.patchResource(
        resourceToEdit.documentId!, widget.resourceToEdit!.toMap());
    Navigator.pop(context);
  }

  Column resourcesFormBuilder(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFieldFormHeader(
                    header: 'Nombre * ',
                    controller: _resource_nameController,
                    customValidator: validationOptions['nameValidator']),
                TextFieldFormHeader(
                  readOnly: true,
                  header: 'Operaciones relacionadas',
                  controller: _operationsController,
                ),
                TextFieldFormHeader(
                    header: 'Notes',
                    controller: _notesController,
                    customValidator: validationOptions['nameValidator']),
                Column(
                  children: [
                    widget.edit
                        ? ButtonRounded(
                            backgroundColor: Colors.grey.shade100,
                            width: double.infinity,
                            onPressed: () {
                              ResourceModel resourceToDelete =
                                  widget.resourceToEdit!;
                              CentralDialogForm.manageDeleteAlert(context, () {
                                _resourceService.deleteResource(
                                    resourceToDelete.documentId!);
                              }, resourceToDelete.resource_name);
                            },
                            borderColor: Colors.red,
                            child: const Text(
                              'Borrar recurso',
                              style: TextStyle(color: Colors.red),
                            ))
                        : const SizedBox.shrink(),
                    const Divider(
                      color: Colors.transparent,
                    ),
                  ],
                )
                // Add more TextFormFields here for other fields of the Resource model
              ],
            ),
          ),
        ),
      ],
    );
  }
}
