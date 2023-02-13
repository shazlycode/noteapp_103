import 'package:flutter/material.dart';
import 'package:noteapp_103/screens/auth/auth.dart';
import 'package:noteapp_103/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: const Color(0xff820000),
      )),
      initialRoute: prefs.containsKey('userData') ? '/mainScreen' : '/auth',
      routes: {
        '/mainScreen': (context) => MainScreen(),
        '/auth': (context) => Auth(),
      },
    );
  }
}
