// ignore_for_file: unused_element, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/models/user_is_login_model.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';
import 'package:sijj_provinsi_banten/services/realtime_location.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';

class AuthProvider with ChangeNotifier {
  UserIsLogin? _user;
  final LocationService _locationService = LocationService();
  // final Session _sessionCheck = Session();

  UserIsLogin? get user => _user;

  Future<void> getMyProfile(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    if (loginToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(meApiUrl),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $loginToken',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final responseDecoded = responseData['data'];

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

        notifyListeners();
        // _locationService.startTracking(context);
        // _sessionCheck.sessionCheck();
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Gagal memuat profil';
        throw Exception(message);
      }
    } catch (e) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('loginToken');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      QuickAlert.show(
        barrierDismissible: false,
        headerBackgroundColor: primary,
        context: context,
        type: QuickAlertType.info,
        text: 'Sesi Anda telah habis, silahkan login kembali!',
        confirmBtnColor: primary,
      );

      print('sesi anda telah habis silahkan login kembali!');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // get login token
      SharedPreferences pref = await SharedPreferences.getInstance();
      final loginToken = pref.getString('loginToken');

      if (loginToken != null) {
        // make request to logout
        final response = await http.post(
          Uri.parse(logoutApiUrl),
          headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'},
        );

        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('loginToken');
          _locationService.stopTracking();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          throw Exception('Failed to log out');
        }
      }
    } catch (e) {
      print(e);
    }
  }
}

Future<void> initializeAuth(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.getMyProfile(context);
}
