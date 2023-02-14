import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/constants.dart';

class ApiAuthService {
  Future signup(String username, String email, String password) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    try {
      final response = await http.post(Uri.parse(Env.signupUrl),
          body: {'username': username, 'email': email, 'password': password},
          headers: myheaders);
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
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    try {
      final response = await http.post(Uri.parse(Env.loginUrl),
          body: {'email': email, 'password': password}, headers: myheaders);
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
