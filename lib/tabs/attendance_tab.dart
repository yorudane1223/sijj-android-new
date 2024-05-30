// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sijj_provinsi_banten/models/location_model.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/pages/attendance_detail.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

// fetch attendance
Future<AttendanceModel> fetchAttendance(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginToken = prefs.getString('loginToken');

  final response = await http.get(
    Uri.parse(attendanceApiUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'},
  );

  if (response.statusCode == 200) {
    return AttendanceModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else if (response.statusCode == 401) {
    print('token has expired!');
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
  }
  throw Exception(response.body);
}

class AttendanceModel {
  final bool success;
  final String message;
  final List<Attendance> data;

  AttendanceModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceModel.fromRawJson(String str) =>
      AttendanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        success: json["success"],
        message: json["message"],
        data: List<Attendance>.from(
          json["data"].map((x) => Attendance.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Attendance {
  final int id;
  final String latitude;
  final String longitude;
  final int status;
  final String image;
  final String thumbnail;
  final int penilikId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.image,
    required this.thumbnail,
    required this.penilikId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromRawJson(String str) =>
      Attendance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        status: json["status"],
        image: json["image"],
        thumbnail: json["thumbnail"],
        penilikId: json["penilik_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "status": status,
        "image": image,
        "thumbnail": thumbnail,
        "penilik_id": penilikId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class AbsenTab extends StatefulWidget {
  const AbsenTab({super.key});

  @override
  State createState() => _AbsenTabState();
}

class _AbsenTabState extends State<AbsenTab> {
  bool isLoading = false;
  List<Attendance> attendances = [];

  @override
  void initState() {
    super.initState();
    getAttendance();
  }

  Future<void> getAttendance() async {
    setState(() {
      isLoading = true;
    });
    final attendanceModel = await fetchAttendance(context);
    setState(() {
      attendances = attendanceModel.data;
      isLoading = false;
    });
  }

  XFile? _image;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sedang mengambil titik koordinat ruas jalan..',
                    style: poppins,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Absensi Kehadiran',
                      style: poppins.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    attendances.isEmpty
                        ? const Center(
                            child: Text('No attendance data available'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: attendances.length,
                            itemBuilder: (context, index) {
                              final attendance = attendances[index];

                              // change status from number to word
                              String status = '';
                              if (attendance.status == 0) {
                                status = 'Keluar';
                              } else if (attendance.status == 1) {
                                status = 'Masuk';
                              }

                              return GestureDetector(
                                onTap: () {
                                  print('tapped');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AttendanceDetail(
                                        latitude: attendance.latitude,
                                        longitude: attendance.longitude,
                                        imageUrl: attendance.image,
                                        status: status,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'Lokasi : ${attendance.latitude}, ${attendance.longitude}'),
                                                    Text('Status : $status'),
                                                  ],
                                                ),
                                                SvgPicture.asset(
                                                    'assets/icons/right.svg')
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        backgroundColor: primary,
        foregroundColor: white,
        child: SvgPicture.asset(
          'assets/icons/camera.svg',
          color: white,
        ),
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
      setState(() {
        _isLoading = true;
      });
      await _getCurrentLocation();
      await attendence(context);
      setState(() {
        _isLoading = false;
      });
    } else {
      print('tidak jadi mengambil gambar');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      final latitude = position.latitude;
      final longitude = position.longitude;
      // Set lokasi menggunakan provider
      Provider.of<LocationModel>(context, listen: false)
          .setLocation(latitude, longitude);
    } catch (e) {
      print('Gagal mendapatkan lokasi: $e');
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> attendence(BuildContext context) async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    final latitude = locationModel.latitude;
    final longitude = locationModel.longitude;

    if (latitude == null || longitude == null) {
      print('Lokasi tidak tersedia');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    if (loginToken == null) {
      print('Login token is null');
      return;
    }

    final imageBytes = await _image?.readAsBytes();
    if (imageBytes == null) {
      print('Gagal membaca gambar');
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse(attendanceApiUrl));
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $loginToken';
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'attendance.jpg',
    ));

    try {
      final response = await request.send();
      final responseJson = await response.stream.bytesToString();
      final responseBody = jsonDecode(responseJson);

      if (response.statusCode == 200) {
        await locationModel.startLocationUpdates();
        print(responseBody);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: primary,
          text: responseBody['message'],
        );
      } else {
        await locationModel.startLocationUpdates();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          confirmBtnColor: primary,
          text: responseBody['message'],
        );
      }
      locationModel.stopLocationUpdates();
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Error submitting attendance : $e',
      );
    }
  }
}
