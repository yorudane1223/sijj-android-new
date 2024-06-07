import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/models/report_model.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';
import 'package:sijj_provinsi_banten/pages/create_report.dart';
import 'package:sijj_provinsi_banten/pages/report_detail_page.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

// Mengambil data absensi
Future<ReportModel> fetchReport(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginToken = prefs.getString('loginToken');

  final response = await http.get(
    Uri.parse(reportApiUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'},
  );

  if (response.statusCode == 200) {
    return ReportModel.fromJson(
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

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  bool isLoading = false;
  List<Report> reports = [];

  @override
  void initState() {
    super.initState();
    // _locationService.startTracking(context);
    getReports();
  }

  Future<void> getReports() async {
    setState(() {
      isLoading = true;
    });
    final reportModel = await fetchReport(context);
    setState(() {
      reports = reportModel.data;
      isLoading = false;
    });
  }

  bool _isLoading = false;

  void loading() {
    if (_isLoading) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Daftar Pengaduan',
                      style: poppins.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    reports.isEmpty
                        ? const Center(
                            child: Text('Tidak ada data pengaduan tersedia'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final attendance = reports[index];

                              return GestureDetector(
                                onTap: () {
                                  print('ditekan');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportDetailPage(
                                        latitude: attendance.latitude,
                                        longitude: attendance.longitude,
                                        imageUrl: attendance.image,
                                        kondisi: attendance.kondisi,
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
                                                        'Latitude : ${attendance.latitude}'),
                                                    Text(
                                                        'Longitude : ${attendance.longitude}'),
                                                    Text(
                                                        'Kondisi : ${attendance.kondisi}'),
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
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateReportPage()));
          },
          backgroundColor: primary,
          foregroundColor: white,
          child: const Icon(Icons.add)),
    );
  }
}
