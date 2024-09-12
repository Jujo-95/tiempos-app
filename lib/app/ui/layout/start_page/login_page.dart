import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/app/ui/layout/start_page/forgot_password_page.dart';
import 'package:tiempos_app/app/ui/layout/start_page/main_page.dart';
import 'package:tiempos_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showLogInpage;
  final AuthService authService = AuthService.instance;

  LoginPage({super.key, required this.showLogInpage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final String _errorSignInMessage = '';
  Map _logInErrors = {};

  validateFieldsAndSingIn(email, password) {
    _logInErrors = {};

    setState(() {
      if (email.isEmpty) {
        _logInErrors['emailError'] = 'Ingrese un usuario';
      }
      if (password.isEmpty) {
        _logInErrors['passwordError'] = 'Ingrese una contraseña';
      }

      if (_logInErrors['emailError'] == null &&
          _logInErrors['passwordError'] == null) {
        singUserIn(email, password);
        widget.authService.login('sakldjas');
      }
    });
  }

  singUserIn(String? email, String? password, {anonimus = false}) async {
    // Progress bar in
    // validate and authenticate user

    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2952E1)));
        });

    try {
      if (!anonimus) {
        await widget.authService.signInWithEmailAndPassword(email, password);
      } else if (anonimus) {
        await widget.authService
            .signInWithEmailAndPassword('jjgu95@gmail.com', 'jujo123');
      }

      Navigator.pop(context);
      // retry sign in when the user restablish his password
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MainPage();
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      parseException(e);
      Navigator.pop(context);
    }
  }

  parseException(FirebaseAuthException e) {
    setState(() {
      switch (e.code) {
        case 'invalid-email':
          _logInErrors['emailError'] = 'Correo inválido';
          break;
        case 'user-not-found':
          _logInErrors['emailError'] = 'Usuario no encontrado';
          break;
        case 'user-disabled':
          _logInErrors['emailError'] = 'Usuario deshabilitado';
          break;
        case 'wrong-password':
          _logInErrors['passwordError'] = 'Constaseña incorrecta';
          break;
        case 'unknown':
          _logInErrors['passwordError'] = '${e.message}';
          break;
        default:
          break;
      }
    });
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
                      'ingresa a',
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
                        customValidator: _logInErrors['emailError'],
                      ),
                    ),
                    Center(
                        child: TextFieldFormHeader(
                      maxLines: 1,
                      controller: passwordController,
                      header: 'Contraseña',
                      hintText: 'Contraseña',
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      customValidator: _logInErrors['passwordError'],
                    )),
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ForgotPasswordPage();
                                },
                              ),
                            );
                          },
                          child: const Text('¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Color(0xFF2952E1))),
                        )
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
                            onPressed: () {
                              validateFieldsAndSingIn(emailController.text,
                                  passwordController.text);
                            },
                            width: double.maxFinite,
                            child: const Text('Iniciar sesión')),
                        const SizedBox(
                          height: 48,
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: 1,
                          child: Container(color: const Color(0xFFD9D9D9)),
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('¿No tienes una cuenta? '),
                              GestureDetector(
                                onTap: widget.showLogInpage,
                                child: const Text(
                                  'Crear cuenta',
                                  style: TextStyle(
                                    color: Color(0xFF2952E1),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    singUserIn(null, null, anonimus: true),
                                child: const Text(
                                  'Acceso anónimo',
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
