import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
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
  File? file;

  Future updateNote() async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    ActionsServices actionsServices = ActionsServices();
    final userId = jsonDecode(prefs.getString('userData')!)['id'];
    setState(() {
      isLoading = true;
    });

    if (file == null) {
      final response = await actionsServices.update({
        'note_id': widget.note!['note_id'].toString(),
        'note_title': titleController.text,
        'note_body': bodyController.text,
        'note_image': widget.note!['note_image']
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
    } else {
      setState(() {
        isLoading = true;
      });
      print('start update with image==============');
      Map data = {
        'note_id': widget.note!['note_id'].toString(),
        'note_title': titleController.text,
        'note_body': bodyController.text,
        'note_image': widget.note!['note_image']
      };

      final multiPartRequest =
          http.MultipartRequest('POST', Uri.parse(Env.updateUrl));
      final stream = http.ByteStream(file!.openRead());
      final length = await file!.length();
      final multPartFile = http.MultipartFile('field', stream, length,
          filename: path.basename(file!.path));

      multiPartRequest.files.add(multPartFile);
      multiPartRequest.headers.addAll(myheaders);
      data.forEach((key, value) {
        multiPartRequest.fields[key] = value;
      });

      final request = await multiPartRequest.send();
      final response = await http.Response.fromStream(request);
      setState(() {
        isLoading = false;
      });
      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
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
              child: Text('${result['status']}: an error occures'),
            )).show();
      }
    }
  }

  @override
  void initState() {
    titleController.text = widget.note!['note_title'];
    bodyController.text = widget.note!['note_body'];

    super.initState();
  }

  Future picImage(bool isCamera) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      file = File(pickedImage.path);
    });
    Navigator.pop(context);
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
              const SizedBox(height: 30),
              MaterialButton(
                color: Env.red,
                minWidth: 200,
                height: 55,
                child: const Text(
                  'Add Image',
                  style: TextStyle(color: Color.fromARGB(255, 190, 188, 182)),
                ),
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 250,
                          decoration: BoxDecoration(
                              color: Env.green,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          child: Column(
                            children: [
                              Text(
                                'Select Image',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(color: Env.offwhite),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                      onTap: () async {
                                        await picImage(true);
                                        Navigator.pop(context);
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.camera_enhance_outlined,
                                            color: Env.offwhite,
                                            size: 100,
                                          ),
                                          Text(
                                            'Camera',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(color: Env.offwhite),
                                          )
                                        ],
                                      ),
                                    )),
                                    Expanded(
                                        child: InkWell(
                                      onTap: () async {
                                        await picImage(false);
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            color: Env.offwhite,
                                            size: 100,
                                          ),
                                          Text(
                                            'Gallery',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(color: Env.offwhite),
                                          )
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              const SizedBox(height: 50),
              MaterialButton(
                color: Env.red,
                minWidth: 200,
                height: 55,
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        'Edit Note',
                        style: TextStyle(
                            color: Color.fromARGB(255, 190, 188, 182)),
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
