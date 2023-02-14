import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:noteapp_103/Api_Service/Actions_services/actions.dart';
import 'package:noteapp_103/main.dart';
import 'package:noteapp_103/screens/auth/auth.dart';

import '../../constants/constants.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final form = GlobalKey<FormState>();
  var isLoading = false;

  Future addNote() async {
    ActionsServices actionsServices = ActionsServices();
    final userId = jsonDecode(prefs.getString('userData')!)['id'];
    setState(() {
      isLoading = true;
    });
    final response = await actionsServices.create({
      'note_title': titleController.text,
      'note_body': bodyController.text,
      'note_user': userId.toString(),
    });
    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Note added succesfully!!!'),
        backgroundColor: Env.red,
      ));
      Navigator.pushNamedAndRemoveUntil(
          context, '/mainScreen', (route) => false);
    } else {
      AwesomeDialog(
          context: context,
          body: Padding(
            padding: EdgeInsets.all(25),
            child: Text('${response['status']}: an error occures'),
          )).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('add note'.toUpperCase()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: form,
          child: ListView(
            children: [
              TextFieldModel(
                controller: titleController,
                validate: (v) {
                  if (v!.isEmpty) {
                    return 'enter note title';
                  } else {
                    return null;
                  }
                },
                hintText: 'Title',
                prefixIconData: Icons.edit,
              ),
              const SizedBox(height: 30),
              TextFieldModel(
                controller: bodyController,
                validate: (v) {
                  if (v!.isEmpty) {
                    return 'enter note content';
                  } else {
                    return null;
                  }
                },
                hintText: 'Note',
                prefixIconData: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 50),
              MaterialButton(
                color: Env.red,
                minWidth: 200,
                height: 55,
                child: const Text(
                  'Add Note',
                  style: TextStyle(color: Color.fromARGB(255, 190, 188, 182)),
                ),
                onPressed: () async {
                  addNote();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
