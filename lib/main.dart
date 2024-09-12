import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/dashboard_form_operations_provider.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/dashboard_form_activities_provider.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/dashboard_form_people_provider.dart';

import 'app/ui/layout/start_page/main_page.dart';
import 'package:provider/provider.dart';

void main() async {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDTUzZryUnhv9usjWSPnkzn_AZSPxpYmz4",
      appId: "1:128155516744:web:b12a2b24ad8cf098793d7d",
      messagingSenderId: "128155516744",
      projectId: "tiempos-79cc3",
    ),
  );
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2952E1);
    const textColor = Color(0xFF4A4A4A);
    const backgroundColor = Color(0xFFF5F5F5);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DashboardFormPeopleProvider()..getPeopleItems()),
      ],
      child: MaterialApp(
        // (context, child) => MaterialApp(
        title: 'timepos app',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // colorSchemeSeed: primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
            primary: primary,
            secondary: primary,
          ),
          scaffoldBackgroundColor: backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: '',
                bodyColor: textColor,
                displayColor: textColor,
              ),
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        // navigatorKey: locator<NavigatorService>().navigatorKey,
        home: const MainPage(), //MainPage()
      ),
    );
  }
}
