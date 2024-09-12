import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/layout/start_page/toogle_page.dart';
import 'package:tiempos_app/app/ui/layout/start_page/start_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isAuthenticated = false;
  late Stream<User?> _userStream;
  @override
  void initState() {
    super.initState();
    _userStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // this allows to hear if the user is registered, works like notifyListeners()
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StartPage();
          } else {
            return const TooglePage();
          }
        },
      ),
    );
  }
}
