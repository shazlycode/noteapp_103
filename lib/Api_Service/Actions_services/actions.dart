import 'dart:convert';

import '../../constants/constants.dart';
import 'package:http/http.dart' as http;

class ActionsServices {
  Future getData(String noteUser) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    var url = Uri.parse(Env.viewUrl);

    try {
      final response = await http.post(url,
          body: {'note_user': noteUser}, headers: myheaders);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future create(Map data) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    var url = Uri.parse(Env.createUrl);
    try {
      final response = await http.post(url, body: data, headers: myheaders);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future update(Map data) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    var url = Uri.parse(Env.updateUrl);
    try {
      final response = await http.post(url, body: data, headers: myheaders);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future delete(Map data) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('shazlycode:SagedSela2015'));

    Map<String, String> myheaders = {'authorization': basicAuth};
    var url = Uri.parse(Env.deleteUrl);
    try {
      final response = await http.post(url, body: data, headers: myheaders);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
    } catch (err) {
      rethrow;
    }
  }
}
