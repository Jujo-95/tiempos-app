import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/layout/start_page/login_page.dart';
import 'package:tiempos_app/app/ui/layout/start_page/signin_page.dart';

class TooglePage extends StatefulWidget {
  const TooglePage({super.key});

  @override
  State<TooglePage> createState() => _TooglePageState();
}

class _TooglePageState extends State<TooglePage> {
  // initialy show the login page
  bool showLoginPage = true;

  toogleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        showLogInpage: toogleScreens,
      );
    } else {
      return SignInPage(
        showLogInpage: toogleScreens,
      );
    }
  }
}
