// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class UpdatePasswordTab extends StatefulWidget {
  const UpdatePasswordTab({super.key});

  @override
  State createState() => _UpdatePasswordTab();
}

class _UpdatePasswordTab extends State<UpdatePasswordTab> {
  bool updatePasswordIsLoading = false;
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confrmPasswordController = TextEditingController();

  @override
  void initState() {
    _passwordVisible = false;
    _confirmPasswordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // label
          Text(
            'Perbarui Password',
            style: poppins.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          // form
          Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: passwordController,
                  obscureText:
                      !_passwordVisible, //This will obscure text dynamically
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password Baru',
                    hintText: 'Masukkan password baru',
                    // Here is key idea
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: primary,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password baru tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: confrmPasswordController,
                  obscureText:
                      !_confirmPasswordVisible, //This will obscure text dynamically
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Konfirmasi password Baru',
                    hintText: 'Masukkan konfirmasi password baru',
                    // Here is key idea
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: primary,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password baru tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          // button
          updatePasswordIsLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        updatePasswordIsLoading = true;
                      });
                      await updatePassword(context, passwordController.text,
                          confrmPasswordController.text);
                      setState(() {
                        updatePasswordIsLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: primary,
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: poppins.copyWith(fontSize: 17, color: Colors.white),
                  ),
                )
        ],
      ),
    ));
  }
}

// METHODS

Future<void> updatePassword(
    BuildContext context, String password, String confirmPassword) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    final response = await http.post(Uri.parse(updateUserPassword), headers: {
      HttpHeaders.authorizationHeader: 'Bearer $loginToken',
      'Accept': 'application/json'
    }, body: {
      'password': password,
      'password_confirmation': confirmPassword
    });

    // decode response to json
    final responseDecoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        confirmBtnColor: primary,
        type: QuickAlertType.success,
        text: responseDecoded['message'],
      );
    } else {
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        confirmBtnColor: primary,
        type: QuickAlertType.warning,
        title: 'Oops...',
        text: responseDecoded['message'],
      );
    }
  } catch (e) {
    QuickAlert.show(
      barrierDismissible: false,
      context: context,
      confirmBtnColor: primary,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: 'Server Error!',
    );
  }
}
