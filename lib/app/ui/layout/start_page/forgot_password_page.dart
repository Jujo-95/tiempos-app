import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/text_field_form_header.dart';
import 'package:tiempos_app/app/ui/layout/start_page/toogle_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  String _errorSignInMessage = '';

  Future sendPwRecoverMail() async {
    // Progress bar in
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2952E1)));
        });

    // validate and authenticate user
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      setState(() {
        _errorSignInMessage = 'success';
      });
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // if there is any problem in the creation of the user, catch the errorr and show the message.
      Navigator.pop(context);
      setState(() {
        _errorSignInMessage = e.message.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actionsIconTheme:
            const IconThemeData(color: Colors.black, opacity: 100),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 500
                ? 500
                : MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const Center(child: SizedBox(height: 80)),
                const Center(
                    child: Text(
                  'tiempos',
                  style: TextStyle(fontSize: 30, letterSpacing: 10),
                )),
                const Center(
                    child: Text(
                  'ingresa la dirección de correo electrónico inscrito para resetear tu contraseña',
                  style: TextStyle(fontSize: 14),
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
                SizedBox(
                    child: (_errorSignInMessage == ''
                        ? const Text('')
                        : _errorSignInMessage == 'success'
                            ? const Row(
                                children: [
                                  Icon(Icons.check),
                                  Text(
                                    'Link de reseteo de contraseña enviado satisfactoriamente. \n Por favor revise su bandeja de correo electrónico y siga instucciones para crear una nueva contraseña.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(Icons.warning_amber),
                                  Text(_errorSignInMessage),
                                ],
                              ))),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: Column(children: [
                    ButtonRounded(
                      backgroundColor: const Color(0xFF2952E1),
                      borderColor: Colors.transparent,
                      onPressed: sendPwRecoverMail,
                      width: double.maxFinite,
                      child: const Text('Enviar Correo'),
                    ),
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
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Volver a página de inicio de sesión '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const TooglePage();
                              },
                            ),
                          );
                        },
                        child: const Text('Volver',
                            style: TextStyle(color: Color(0xFF2952E1))),
                      )
                    ])
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
