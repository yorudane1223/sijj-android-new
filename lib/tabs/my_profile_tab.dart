// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/functions/auth_function.dart';
import 'package:sijj_provinsi_banten/pages/crop_image.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class MyProfileTab extends StatefulWidget {
  const MyProfileTab({
    super.key,
  });

  @override
  State createState() => _MyProfileTabState();
}

class _MyProfileTabState extends State<MyProfileTab> {
  bool _isLoading = true;
  bool _updateProfileCredentials = false;

  // form update controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nomorTeleponController = TextEditingController();
  final alamatController = TextEditingController();

  @override
  void initState() {
    initializeAuth(context).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    setState(() {
      nameController.text = user!.nama;
      emailController.text = user.email;
      nomorTeleponController.text = user.telepon;
      alamatController.text = user.alamat;
    });

    return _isLoading
        ? Scaffold(
            body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/banten-logo.png',
                  width: 280,
                ),
              ),
              Text(
                'Loading..',
                style: poppins.copyWith(fontSize: 11),
              )
            ],
          ))
        : Scaffold(
            body: SingleChildScrollView(
                child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 210,
                    decoration: BoxDecoration(color: primary),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 147),
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            user!.image,
                                            // 'assets/images/banten-logo.png',
                                            width: 107,
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            left: 87,
                            top: 88,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(100)),
                              child: IconButton(
                                  onPressed: () {
                                    // _getImageFromGallery();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CropImage()));
                                  },
                                  icon: Icon(
                                    Icons.add_a_photo,
                                    color: white,
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Text(
                            'Profil Saya',
                            style: poppins.copyWith(
                                color: white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 89),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            user!.nama,
                            style: poppins.copyWith(
                                color: white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email,
                            style: poppins.copyWith(
                              color: white,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Biodata',
                          style: poppins.copyWith(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nama',
                                hintText: 'Masukkan Nama',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                                hintText: 'Masukkan Email',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email tidak boleh kosong!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: nomorTeleponController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nomor Telepon',
                                hintText: 'Masukkan Nomor Telepon',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nomor telepon tikak boleh kosong!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: alamatController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                                labelText: 'Alamat',
                                hintText: 'Masukkan Alamat',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Alamat tidak boleh kosong!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            _updateProfileCredentials
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _updateProfileCredentials = true;
                                        });
                                        await updateProfileUserCredentials(
                                            nameController.text,
                                            emailController.text,
                                            nomorTeleponController.text,
                                            alamatController.text);
                                        setState(() {
                                          _updateProfileCredentials = false;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      minimumSize:
                                          const Size(double.infinity, 60),
                                      backgroundColor: primary,
                                    ),
                                    child: Text(
                                      'Simpan Perubahan',
                                      style: poppins.copyWith(
                                          fontSize: 17, color: Colors.white),
                                    ),
                                  ),
                            const SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                      ))
                ],
              )
            ],
          )));
  }

  // METHODS

  // update profile user credentials
  Future<void> updateProfileUserCredentials(
      String nama, String email, String telepon, String alamat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    if (loginToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Center(
          child: Text(
              'Token login tidak ada, tidak di izinkan untuk memperbaharui biodata!'),
        ),
      ));
    }

    // send response to api update user profile
    try {
      final response = await http
          .post(Uri.parse(updateMyProfileCredentialsApiUrl), headers: {
        HttpHeaders.authorizationHeader: 'Bearer $loginToken',
        'Accept': 'application/json'
      }, body: {
        'nama': nama,
        'email': email,
        'telepon': telepon,
        'alamat': alamat
      });

      final responseDecoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        QuickAlert.show(
          barrierDismissible: false,
          context: context,
          confirmBtnColor: primary,
          type: QuickAlertType.success,
          text: responseDecoded['message'],
        );
        setState(() {
          initializeAuth(context).then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        });
      } else {
        QuickAlert.show(
          barrierDismissible: false,
          context: context,
          confirmBtnColor: primary,
          type: QuickAlertType.warning,
          text: responseDecoded['message'],
        );
      }
    } catch (e) {
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        confirmBtnColor: primary,
        type: QuickAlertType.error,
        text: '$e',
      );
    }
  }
}
