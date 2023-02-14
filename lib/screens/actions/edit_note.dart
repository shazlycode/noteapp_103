import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:noteapp_103/main.dart';
import 'package:noteapp_103/screens/auth/auth.dart';

import '../../Api_Service/Actions_services/actions.dart';
import '../../constants/constants.dart';

class EditNote extends StatefulWidget {
  const EditNote({super.key, this.note});
  final Map? note;
  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final form = GlobalKey<FormState>();
  var isLoading = false;

  Future updateNote() async {
    ActionsServices actionsServices = ActionsServices();
    final userId = jsonDecode(prefs.getString('userData')!)['id'];
    setState(() {
      isLoading = true;
    });
    final response = await actionsServices.update({
      'note_id': widget.note!['note_id'].toString(),
      'note_title': titleController.text,
      'note_body': bodyController.text,
    });
    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Note updated succesfully!!!'),
        backgroundColor: Env.red,
      ));
      Navigator.pushNamedAndRemoveUntil(
          context, '/mainScreen', (route) => false);
      setState(() {});
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
  void initState() {
    titleController.text = widget.note!['note_title'];
    bodyController.text = widget.note!['note_body'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit note'.toUpperCase()),
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
                  'Edit Note',
                  style: TextStyle(color: Color.fromARGB(255, 190, 188, 182)),
                ),
                onPressed: () async {
                  updateNote();
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
