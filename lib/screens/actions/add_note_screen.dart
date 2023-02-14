import 'dart:convert';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
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
  File? file;

  Future addNote() async {
    // ActionsServices actionsServices = ActionsServices();
    final userId = jsonDecode(prefs.getString('userData')!)['id'];
    setState(() {
      isLoading = true;
    });
    // if (file == null) {
    //   final response = await actionsServices.create({
    //     'note_title': titleController.text,
    //     'note_body': bodyController.text,
    //     'note_user': userId.toString(),
    //   });
    //   if (response['status'] == 'success') {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text('Note added succesfully!!!'),
    //       backgroundColor: Env.red,
    //     ));
    //     Navigator.pushNamedAndRemoveUntil(
    //         context, '/mainScreen', (route) => false);
    //   } else {
    //     AwesomeDialog(
    //         context: context,
    //         body: Padding(
    //           padding: EdgeInsets.all(25),
    //           child: Text('${response['status']}: an error occures'),
    //         )).show();
    //   }
    // } else {
    final response = await createMultipart({
      'note_title': titleController.text,
      'note_body': bodyController.text,
      'note_user': userId.toString(),
    });
    print('rrrrrrrrrrrrreeeeesponse$response');
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

    setState(() {
      isLoading = false;
    });
  }

  Future createMultipart(Map data) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};

    var url = Uri.parse(Env.createUrl);
    final multpartRequest = http.MultipartRequest('POST', url);
    final length = await file!.length();
    final stream = http.ByteStream(file!.openRead());
    final fileName = path.basename(file!.path);

    final multipartFile =
        MultipartFile('file', stream, length, filename: fileName);
    multpartRequest.files.add(multipartFile);
    multpartRequest.headers.addAll(myheaders);
    multpartRequest.headers.addAll(myheaders);
    data.forEach((key, value) {
      multpartRequest.fields[key] = value;
    });
    var myRequest = await multpartRequest.send();
    final response = await http.Response.fromStream(myRequest);

    if (myRequest.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${myRequest.statusCode}');
    }
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
              if (file != null)
                Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image:
                          DecorationImage(image: FileImage(File(file!.path))),
                    )),
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
                                        picImage(false);
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
