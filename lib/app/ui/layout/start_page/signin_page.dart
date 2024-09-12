import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/models/user_model.dart';
import 'package:tiempos_app/services/user_service.dart';

class SignInPage extends StatefulWidget {
  VoidCallback showLogInpage;

  SignInPage({super.key, required this.showLogInpage});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final UserService userService = UserService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String _errorSignInMessage = '';
  bool paswordCoincidence = false;

  Future signUp() async {
    // Progress bar in
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2952E1)));
        });

    // validate and authenticate user

    if (paswordCoincidence) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        userService.createUserInUserTable(emailController.text);

        //user info is automatically created by firebase Auth library.
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // if there is any problem in the creation of the user, catch the errorr and show the message.
        Navigator.pop(context);
        setState(() {
          _errorSignInMessage = e.message.toString();
        });
      }
    } else {
      Navigator.pop(context);
      setState(() {
        _errorSignInMessage = 'Las contraseñas no coinciden.';
      });
    }
  }

  //add details of the new user.

// password validation executed when the pasword changes
  void validate(String) {
    isPaswordCoincidence();
  }

  isPaswordCoincidence() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      setState(() {
        paswordCoincidence = true;
        _errorSignInMessage = '';
      });
    } else {
      setState(() {
        paswordCoincidence = false;
        _errorSignInMessage = 'Las contraseñas no coinciden.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 500
                    ? 500
                    : MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const Center(child: SizedBox(height: 80)),
                    const Center(
                        child: Text(
                      'regístrate en',
                      style: TextStyle(fontSize: 14),
                    )),
                    const Center(
                        child: Text(
                      'tiempos',
                      style: TextStyle(fontSize: 30, letterSpacing: 10),
                    )),
                    const Center(child: SizedBox(height: 24)),
                    Center(
                        child: TextFieldFormHeader(
                      controller: emailController,
                      header: 'Email',
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    )),
                    Center(
                        child: TextFieldFormHeader(
                      controller: passwordController,
                      header: 'Contraseña',
                      hintText: 'Contraseña',
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    )),
                    Center(
                        child: TextFieldFormHeader(
                            controller: confirmPasswordController,
                            header: 'Confirmar contraseña',
                            hintText: 'Contraseña',
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            onChanged: validate)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _errorSignInMessage == ''
                            ? const Text('')
                            : Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(_errorSignInMessage,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ],
                              ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(children: [
                        ButtonRounded(
                          backgroundColor: const Color(0xFF2952E1),
                          borderColor: Colors.transparent,
                          onPressed: signUp,
                          width: double.maxFinite,
                          child: const Text('Crear cuenta'),
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: 1,
                          child: Container(color: const Color(0xFFD9D9D9)),
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿Ya tienes una cuenta? '),
                              GestureDetector(
                                onTap: widget.showLogInpage,
                                child: const Text(
                                  'Inicia sesión',
                                  style: TextStyle(
                                    color: Color(0xFF2952E1),
                                  ),
                                ),
                              ),
                            ])
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
