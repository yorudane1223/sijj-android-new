// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class AbsenTab extends StatefulWidget {
  const AbsenTab({super.key});

  @override
  State createState() => _AbsenTabState();
}

class _AbsenTabState extends State<AbsenTab> {
  Position? _position;
  XFile? _image;

  // location
  String? _latittude;
  String? _longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Absensi Kehadiran',
                  style: poppins.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  )),
              const SizedBox(
                height: 20,
              ),
              Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        // action
                        print('hallo');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: SvgPicture.asset(
                                    'assets/icons/attendence.svg',
                                    color: white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                              'assets/icons/day.svg'),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          const Text('Selasa')
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                              'assets/icons/date.svg'),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          const Text('12-23-2024')
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/right.svg')
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // attendence action
          _openCamera();
        },
        backgroundColor: primary,
        foregroundColor: white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });

      await _getCurrentLocation();
      await attendence();
    } else {
      print('tidak jadi mengambil gambar');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      final latitude = position.latitude;
      final longitude = position.longitude;
      setState(() {
        _latittude = latitude.toString();
        _longitude = longitude.toString();
      });
    } catch (e) {
      print('Gagal mendapatkan lokasi: $e');
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak secara permanen';
    }
    return await Geolocator.getCurrentPosition();
  }

  // send to API
  Future<void> attendence() async {
    try {
      // ambil login token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('loginToken');

      //  request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(attendenceApiUrl),
      );
      request.headers['authorization'] = 'Bearer $loginToken';
      request.headers['Accept'] = 'application/json';

      // image
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ),
      );
      // coordinate
      request.fields['latitude'] = _latittude.toString();
      request.fields['longitude'] = _longitude.toString();

      final response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        QuickAlert.show(
          confirmBtnColor: primary,
          barrierDismissible: false,
          onConfirmBtnTap: () => {Navigator.pop(context)},
          context: context,
          type: QuickAlertType.success,
          text: responseData['message'],
        );
      } else {
        QuickAlert.show(
          confirmBtnColor: primary,
          barrierDismissible: false,
          onConfirmBtnTap: () => {Navigator.pop(context)},
          context: context,
          type: QuickAlertType.warning,
          text: responseData['message'],
        );
      }
    } catch (e) {
      print('error $e');
    }
  }
}
