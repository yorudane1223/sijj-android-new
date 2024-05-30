import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/pages/auth/login_page.dart';
import 'package:sijj_provinsi_banten/pages/create_report.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:http/http.dart' as http;
import 'package:sijj_provinsi_banten/themes/fonts.dart';

Future<ReportModel> fetchReport(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginToken = prefs.getString('loginToken');

  if (loginToken == null) {
    navigateToLogin(context, prefs);
    return Future.error('Token not found');
  }

  try {
    final response = await http.get(
      Uri.parse(myReportApiUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'},
    );

    if (response.statusCode == 200) {
      return ReportModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 401) {
      print('Token has expired!');
      navigateToLogin(context, prefs);
      return Future.error('Token expired');
    } else {
      throw Exception('Failed to load report');
    }
  } catch (e) {
    navigateToLogin(context, prefs);
    throw Exception('Failed to load report');
  }
}

void navigateToLogin(BuildContext context, SharedPreferences prefs) {
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

class ReportModel {
  final bool success;
  final String message;
  final List<Report> data;

  ReportModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReportModel.fromRawJson(String str) =>
      ReportModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        success: json["success"],
        message: json["message"],
        data: List<Report>.from(json["data"].map((x) => Report.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Report {
  final int id;
  final int penilikId;
  final String image;
  final String kondisi;
  final String latitude;
  final String longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.penilikId,
    required this.image,
    required this.kondisi,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromRawJson(String str) => Report.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        penilikId: json["penilik_id"],
        image: json["image"],
        kondisi: json["kondisi"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "penilik_id": penilikId,
        "image": image,
        "kondisi": kondisi,
        "latitude": latitude,
        "longitude": longitude,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class ReportTab extends StatefulWidget {
  const ReportTab({super.key});

  @override
  State createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportTab> {
  bool updatePasswordIsLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<Report> reports = [];
  bool isLoading = false;

  final passwordController = TextEditingController();
  final confrmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getReport();
  }

  Future<void> getReport() async {
    setState(() {
      isLoading = true;
    });
    try {
      final reportModel = await fetchReport(context);
      setState(() {
        reports = reportModel.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // label
              Text(
                'Daftar Pengaduan',
                style:
                    poppins.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : reports.isEmpty
                      ? Center(child: Text('Tidak ada data pengaduan'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return ReportCard(report: report);
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
              builder: (context) => const CreateReportPage(),
            ),
          );
        },
        backgroundColor: primary,
        foregroundColor: white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    report.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/images/bg-batik.jpeg',
                          fit: BoxFit.cover);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text('Latitude: ${report.latitude}', style: poppins),
            Text('Longitude: ${report.longitude}', style: poppins),
            Text('Kondisi: ${report.kondisi}', style: poppins),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
