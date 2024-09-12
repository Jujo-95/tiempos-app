import 'package:flutter/material.dart';
import 'package:tiempos_app/models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  UserModel mapUser() {
    return UserModel(
        first_name: nameController.text, email: emailController.text);
  }

  clearFields() {
    nameController.clear();
  }

  fillUserToEdit(UserModel userToEdit) {
    nameController.text = userToEdit.first_name.toString();
    emailController.text = userToEdit.email.toString();
  }
}
