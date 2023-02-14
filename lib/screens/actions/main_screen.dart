import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:noteapp_103/Api_Service/Actions_services/actions.dart';
import 'package:noteapp_103/main.dart';
import 'package:noteapp_103/screens/actions/edit_note.dart';

import '../../constants/constants.dart';

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

  List fetched = [];
  Future getData() async {
    ActionsServices actionsServices = ActionsServices();
    try {
      var userId = jsonDecode(prefs.getString('userData')!)['id'].toString();

      final data = await actionsServices.getData(userId);

      if (data['status'] == 'success') {
        fetched = data['data'];
        print('fetched========${fetched.length}');
      } else {
        // AwesomeDialog(context: context, body: Text(data['status'])).show();
      }
    } catch (err) {
      AwesomeDialog(context: context, body: Text(err.toString())).show();
    }
  }

  Future deleteNote(String noteId) async {
    ActionsServices actionsServices = ActionsServices();
    try {
      final response = await actionsServices.delete({'note_id': noteId});
      if (response['status'] == 'success') {
        fetched.removeWhere((element) => element['note_id'] == noteId);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Note deleted successfully'),
          backgroundColor: Env.red,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Note can\'t be deleted'),
          backgroundColor: Env.red,
        ));
      }
    } catch (err) {
      //
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
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            Navigator.pushNamed(context, '/addNoteScreen');
          }),
          backgroundColor: Env.green,
          child: Icon(
            Icons.add,
            color: Env.offwhite,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                    itemCount: fetched.length,
                    itemBuilder: (context, index) {
                      if (fetched.isEmpty) {
                        return const Center(
                          child: Text('No notes available'),
                        );
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return EditNote(note: fetched[index]);
                          }));
                        },
                        child: Dismissible(
                          key: ValueKey(fetched[index]),
                          background: Container(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.delete,
                              color: Env.red,
                            ),
                          ),
                          onDismissed: (v) async {
                            await deleteNote(
                                fetched[index]['note_id'].toString());
                          },
                          direction: DismissDirection.endToStart,
                          child: Card(
                              margin: EdgeInsets.all(5),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              elevation: 5,
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                          child: Image.asset(
                                              'assets/images/logo.png'))),
                                  Expanded(
                                      flex: 3,
                                      child: ListTile(
                                        title:
                                            Text(fetched[index]['note_title']),
                                        subtitle:
                                            Text(fetched[index]['note_body']),
                                      )),
                                ],
                              )),
                        ),
                      );
                    });
              }),
        ));
  }
}
