import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:http/http.dart' as http;


class Session {
  Future<void> sessionCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    if (loginToken == null || loginToken.isEmpty) {
      print('Login token is null or empty');
    }

    final response = await http.post(Uri.parse(verifyTokenApiUrl), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $loginToken',
      'Accept': 'application/json'
    });

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 401) {
      final message = responseData['message'];
      print('this message from session function : $message');
      prefs.remove('loginToken');
      // lempar ke login
    }
  }
}
