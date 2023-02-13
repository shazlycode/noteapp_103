import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/constants.dart';

class ApiAuthService {
  Future signup(String username, String email, String password) async {
    try {
      final response = await http.post(Uri.parse(Env.signupUrl),
          body: {'username': username, 'email': email, 'password': password});
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        return response.statusCode;
      }
    } catch (err) {
      print(err);
    }
  }

  Future login(String email, String password) async {
    try {
      final response = await http.post(Uri.parse(Env.loginUrl),
          body: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        return response.statusCode;
      }
    } catch (err) {
      print(err);
    }
  }
}
