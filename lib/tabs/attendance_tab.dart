import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sijj_provinsi_banten/models/attendance_model.dart';
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
import 'package:sijj_provinsi_banten/pages/attendance_page.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';
import 'package:sijj_provinsi_banten/services/realtime_location.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

// Mengambil data absensi
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
    print('token telah kadaluarsa!');
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

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State createState() => _AbsenTabState();
}

class _AbsenTabState extends State<AttendanceTab> {
  bool isLoading = false;
  List<Attendance> attendances = [];
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // _locationService.startTracking(context);
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

  void loading() {
    if (_isLoading) {}
  }

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
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
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
                                child: Text('Tidak ada data absensi tersedia'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: attendances.length,
                                itemBuilder: (context, index) {
                                  final attendance = attendances[index];

                                  // Mengubah status dari angka ke kata
                                  String status = '';
                                  if (attendance.status == 0) {
                                    status = 'Keluar';
                                  } else if (attendance.status == 1) {
                                    status = 'Masuk';
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      print('ditekan');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AttendancePage(
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'Latitude : ${attendance.latitude}'),
                                                        Text(
                                                            'Longitude : ${attendance.longitude}'),
                                                        Text(
                                                            'Status : $status'),
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
    location_on();
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      setState(() {
        _isLoading = true;
      });
      await attendence(context);
      setState(() {
        _isLoading = false;
      });
    } else {
      print('tidak jadi mengambil gambar');
    }
  }

  Future<void> location_on() async {
    _locationService.startTracking(context);
  }

  Future<void> location_off() async {
    _locationService.stopTracking();
  }

  Future<void> attendence(BuildContext context) async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    final latitude = locationModel.latitude;
    final longitude = locationModel.longitude;

    if (latitude == null || longitude == null) {
      QuickAlert.show(
        context: context,
        barrierDismissible: false,
        type: QuickAlertType.warning,
        confirmBtnColor: primary,
        text: 'Lokasi tidak tersedia!',
      );
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
      QuickAlert.show(
        context: context,
        barrierDismissible: false,
        type: QuickAlertType.warning,
        confirmBtnColor: primary,
        text: 'Gagal membaca gambar!',
      );
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

      if (response.statusCode == 201) {
        getAttendance();
        QuickAlert.show(
          context: context,
          barrierDismissible: false,
          type: QuickAlertType.success,
          confirmBtnColor: primary,
          text: responseBody['message'],
        );
        location_off();
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          confirmBtnColor: primary,
          text: responseBody['message'],
        );
        location_off();
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Error mengirim absensi: $e',
      );
    }
  }
}
