// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/models/user_is_login_model.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';

class AuthProvider with ChangeNotifier {
  UserIsLogin? _user;

  UserIsLogin? get user => _user;

  Future<void> getMyProfile(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    if (loginToken == null) {
      Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()));
    }

    try {
      final response = await http.post(
        Uri.parse(meApiUrl),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $loginToken',
          'Accept': 'application/json'
        },
      );
      final responseData = jsonDecode(response.body);
      final responseDecoded = responseData['data'];

      if (response.statusCode == 200) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        String? loginToken = pref.getString('loginToken');

        if (loginToken != null) {
          _user = UserIsLogin(
            id: responseDecoded['id'],
            nama: responseDecoded['nama'],
            username: responseDecoded['username'],
            email: responseDecoded['email'],
            telepon: responseDecoded['telepon'],
            alamat: responseDecoded['alamat'],
            image: responseDecoded['image'],
            token: loginToken,
          );
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }

        notifyListeners();
      } else {
        throw Exception('Gagal memuat profil');
      }
    } catch (e) {
      print(e);
      throw Exception('Gagal memuat profil, Silahkan periksa jaringan Anda');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // get login token
      SharedPreferences pref = await SharedPreferences.getInstance();
      final loginToken = pref.getString('loginToken');

      // make request to logout
      final response = await http.post(Uri.parse(logoutApiUrl),
          headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'});
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('loginToken');
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

Future<void> initializeAuth(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.getMyProfile(context);
}
