import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/report_list_tile.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/controllers/users_view_model%20copy.dart';
import 'package:tiempos_app/models/user_model.dart';
import 'package:tiempos_app/services/user_service.dart';

class UserForm extends StatefulWidget {
  final bool edit;
  final UserModel? userToEdit;

  const UserForm({
    super.key,
    this.edit = false,
    this.userToEdit,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  UserViewModel adduserViewModel = UserViewModel();
  UserService userService = UserService();

  Map validationOptions = {};

  @override
  Widget build(BuildContext context) {
    print(widget.userToEdit);
    widget.edit ? adduserViewModel.fillUserToEdit(widget.userToEdit!) : null;

    validate() {
      setState(() {
        if (adduserViewModel.nameController.text.isEmpty) {
          validationOptions['idValidator'] = 'Debes ingresar un nombre';
        }
        if (adduserViewModel.emailController.text.isEmpty) {
          validationOptions['nameValidator'] = 'Debes ingresar un nombre';
        }
      });
    }

    void executeAdduser() {
      validate();

      if (adduserViewModel.nameController.text.isNotEmpty &&
          adduserViewModel.emailController.text.isNotEmpty) {
        userService.postUser(adduserViewModel.mapUser());
        //adduserViewModel.adduser();
        Navigator.pop(context);
      } else {}
    }

    void executeEdituser() {
      validate();
      if (adduserViewModel.nameController.text.isNotEmpty &&
          adduserViewModel.emailController.text.isNotEmpty) {
        print(adduserViewModel.mapUser().toMap());
        userService.patchUser(
            widget.userToEdit!.documentId!, adduserViewModel.mapUser());
        Navigator.pop(context);
      } else {}
    }

    void executeDeleteuser() {
      CentralDialogForm.manageDeleteAlert(context, () {
        userService.deleteUser(
          widget.userToEdit!,
        );
      }, widget.userToEdit!.first_name);
    }

    return CentralDialogForm(
        headerAdd: 'Nuevo usuario',
        headerEdit: 'Editar usuario',
        edit: widget.edit,
        executeEditRecord: executeEdituser,
        executeAddRecord: executeAdduser,
        context: context,
        child: userFormBuilder(executeDeleteuser));
  }

  Column userFormBuilder(Function() executeDeleteuser) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              initialsAvatarBuilder(
                  adduserViewModel.nameController.text, null, 35),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Container(),
                  Expanded(
                    child: TextFieldFormHeader(
                      controller: adduserViewModel.nameController,
                      keyboardType: TextInputType.name,
                      header: 'Nombre *',
                      obscureText: false,
                      customValidator: validationOptions['nameValidator'],
                    ),
                  ),
                ],
              ),
              TextFieldFormHeader(
                readOnly: widget.edit ? true : false,
                controller: adduserViewModel.emailController,
                keyboardType: TextInputType.number,
                header: 'Email',
                obscureText: false,
                customValidator: validationOptions['minuteRateValidator'],
              ),
            ],
          ))
    ]);
  }
}
