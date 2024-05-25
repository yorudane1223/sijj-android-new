import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

// fetch attendance
Future<AttendanceModel> fetchAttendance() async {
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
  } else {
    throw Exception('Failed to load attendance');
  }
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
    final attendanceModel = await fetchAttendance();
    setState(() {
      attendances = attendanceModel.data;
      isLoading = false;
    });
  }

  XFile? _image;
  bool _isLoading = false;
  String? _latitude;
  String? _longitude;
  final statusDefault = 1;

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
                            shrinkWrap: true, // Add this line
                            physics:
                                const NeverScrollableScrollPhysics(), // Add this line
                            itemCount: attendances.length,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 60,
                                decoration: BoxDecoration(color: Colors.black),
                                child: Text(
                                  attendances[index].latitude,
                                  style: TextStyle(color: Colors.white),
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
      await attendence();
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
      setState(() {
        _latitude = latitude.toString();
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

  Future<void> attendence() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('loginToken');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(attendanceApiUrl),
      );
      request.headers['authorization'] = 'Bearer $loginToken';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ),
      );

      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();
      request.fields['status'] = statusDefault.toString();

      final response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = jsonDecode(responseBody);

      if (response.statusCode == 201) {
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
