import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:noteapp_103/Api_Service/Auth_service/api_auth_service.dart';
import 'package:noteapp_103/main.dart';

import '../../constants/constants.dart';

enum AuthType { signup, login }

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  AuthType authType = AuthType.login;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final form = GlobalKey<FormState>();

  auth() async {
    ApiAuthService apiAuthService = ApiAuthService();

    if (!form.currentState!.validate()) {
      return;
    }
    if (authType == AuthType.signup) {
      final response = await apiAuthService.signup(usernameController.text,
          emailController.text, passwordController.text);
      if (response['status'] == 'user exists') {
        AwesomeDialog(
                context: context,
                body: Text(
                    'user with this email already exist, tyr to login or signup with different account'))
            .show();
      } else if (response['status'] == 'success') {
        setState(() {
          authType = AuthType.login;
        });
      } else {
        AwesomeDialog(context: context, body: Text('An error occured')).show();
      }
    } else {
      final response = await apiAuthService.login(
          emailController.text, passwordController.text);

      if (response['status'] == 'success') {
        await prefs.setString(
            'userData',
            jsonEncode({
              'email': emailController.text,
              'username': response['data']['username'],
            }));
        Navigator.pushNamedAndRemoveUntil(
            context, '/mainScreen', (route) => false);
      } else {
        AwesomeDialog(
            context: context,
            barrierColor: Env.red,
            body: Padding(
              padding: const EdgeInsets.all(25),
              child: Text('email and or password incorrect'),
            )).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff08282D),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 150,
            ),
            const SizedBox(
              height: 25,
            ),
            Form(
                key: form,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    if (authType == AuthType.signup)
                      TextFieldModel(
                          key: UniqueKey(),
                          controller: usernameController,
                          hintText: 'Username',
                          prefixIconData: Icons.person,
                          validate: (v) {
                            if (v!.isEmpty || v.length < 3) {
                              return 'Enter a valid username';
                            } else {
                              return null;
                            }
                          }),
                    const SizedBox(height: 10),
                    TextFieldModel(
                        key: UniqueKey(),
                        controller: emailController,
                        hintText: 'Email',
                        prefixIconData: Icons.email,
                        validate: (v) {
                          if (v!.isEmpty || !v.contains('@')) {
                            return 'Enter a valid email';
                          } else {
                            return null;
                          }
                        }),
                    const SizedBox(height: 10),
                    TextFieldModel(
                        key: UniqueKey(),
                        controller: passwordController,
                        hintText: 'Password',
                        prefixIconData: Icons.stars,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'Enter a valid password';
                          } else {
                            return null;
                          }
                        }),
                    const SizedBox(height: 40),
                    MaterialButton(
                        height: 50,
                        minWidth: 200,
                        color: Color(0xff820000),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        elevation: 5,
                        onPressed: () async {
                          auth();
                        },
                        child: authType == AuthType.signup
                            ? Text(
                                'Signup',
                                style: TextStyle(color: Color(0xffFAECD6)),
                              )
                            : Text('Login'.toLowerCase(),
                                style: TextStyle(color: Color(0xffFAECD6)))),
                    const SizedBox(height: 15),
                    if (authType == AuthType.signup)
                      Row(
                        children: [
                          Text('Already has account  ',
                              style: TextStyle(
                                color: Color(0xffFAECD6),
                              )),
                          InkWell(
                            onTap: () {
                              setState(() {
                                authType = AuthType.login;
                              });
                            },
                            child: Text(
                              'login',
                              style: TextStyle(
                                  color: Color(0xff820000),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    if (authType == AuthType.login)
                      Row(
                        children: [
                          Text('Dont\' has account  ',
                              style: TextStyle(
                                color: Color(0xffFAECD6),
                              )),
                          InkWell(
                            onTap: () {
                              setState(() {
                                authType = AuthType.signup;
                              });
                            },
                            child: Text(
                              'signup',
                              style: TextStyle(
                                  color: Color(0xff820000),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                  ],
                ))
          ],
        ),
      )),
    );
  }
}

class TextFieldModel extends StatelessWidget {
  const TextFieldModel({
    Key? key,
    required this.controller,
    required this.validate,
    this.hintText,
    this.prefixIconData,
  }) : super(key: key);

  final TextEditingController controller;
  final String? Function(String?)? validate;
  final String? hintText;
  final IconData? prefixIconData;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validate,
      controller: controller,
      decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xffFAECD6),
          hintText: hintText,
          prefixIcon: Icon(prefixIconData),
          focusColor: Color(0xffFAECD6),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))),
    );
  }
}
