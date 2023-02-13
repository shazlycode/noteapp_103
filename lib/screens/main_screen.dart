import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:noteapp_103/main.dart';

import '../constants/constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? username = '';

  getUsername() async {
    if (prefs.containsKey('userData')) {
      username = jsonDecode(prefs.getString('userData')!)['username'];
    }
  }

  @override
  Widget build(BuildContext context) {
    getUsername();
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
              itemBuilder: ((context) => [
                    PopupMenuItem(child: Text(username!)),
                    PopupMenuItem(
                        child: IconButton(
                      onPressed: (() async {
                        await prefs.remove('userData');
                        await prefs.clear();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/auth', (route) => false);
                      }),
                      icon: Icon(Icons.exit_to_app),
                      color: Env.red,
                    ))
                  ]))
        ],
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'My',
              style: TextStyle(color: Color(0xff4E6C50)),
            ),
            Text(
              'Notes',
              style: TextStyle(color: Color(0xffF2DEBA)),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(username!),
      ),
    );
  }
}
