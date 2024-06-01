import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/pages/report.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';
import 'package:geolocator/geolocator.dart';

Future<void> createReport(String latitude, String longitude, String condition,
    File image, BuildContext context, VoidCallback onSuccess) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginToken = prefs.getString('loginToken');

  var request = http.MultipartRequest('POST', Uri.parse(createReportApiUrl));
  request.headers[HttpHeaders.authorizationHeader] = 'Bearer $loginToken';
  request.headers['Accept'] = 'application/json';

  request.fields['latitude'] = longitude;
  request.fields['longitude'] = latitude;
  request.fields['kondisi'] = condition;
  request.files.add(await http.MultipartFile.fromPath('image', image.path));

  final response = await request.send();
  final responseJson = await response.stream.bytesToString();
  final responseBody = jsonDecode(responseJson);

  if (response.statusCode == 200) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      barrierDismissible: false,
      text: responseBody['message'],
      confirmBtnColor: primary,
      onConfirmBtnTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ReportPage()));
      },
    );
    onSuccess();
  } else {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: responseBody['message'],
      confirmBtnColor: primary,
    );
  }
}

class CreateReportTab extends StatefulWidget {
  const CreateReportTab({super.key});

  @override
  State createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportTab> {
  bool createReportLoading = false;
  bool imageLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController conditionController = TextEditingController();
  File? _image;
  String? _latitude;
  String? _longitude;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    setState(() {
      imageLoading = true;
    });

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final position = await _determinePosition();
      setState(() {
        _image = File(pickedFile.path);
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        imageLoading = false;
      });
    } else {
      setState(() {
        imageLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _resetForm() {
    setState(() {
      conditionController.clear();
      _image = null;
      _latitude = null;
      _longitude = null;
    });
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
              const Text(
                'Buat Pengaduan Ruas Jalan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imageLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _image == null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 70),
                                      child: Center(
                                        child: Text(
                                          'Tidak ada gambar yang di ambil',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _pickImage,
                              child: Center(
                                child: _image == null && !imageLoading
                                    ? SvgPicture.asset(
                                        'assets/icons/camera.svg',
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[600],
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _image != null
                        ? const Text(
                            'Tap gambar untuk mengulangi pengambilan gambar',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )
                        : const SizedBox(height: 15),
                    const SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: conditionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Kondisi Ruas Jalan',
                        hintText: 'Masukkan kondisi ruas jalan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kondisi ruas jalan tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              createReportLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_image == null) {
                          QuickAlert.show(
                            barrierDismissible: false,
                            context: context,
                            confirmBtnColor: primary,
                            type: QuickAlertType.warning,
                            text:
                                'Anda harus mengambil gambar terlebih dahulu!',
                          );
                          return;
                        }
                        if (_latitude == null || _longitude == null) {
                          QuickAlert.show(
                            barrierDismissible: false,
                            context: context,
                            confirmBtnColor: primary,
                            type: QuickAlertType.warning,
                            text:
                                'Tidak dapat mengambil lokasi, pastikan GPS Anda aktif!',
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            createReportLoading = true;
                          });
                          await createReport(
                            _latitude!,
                            _longitude!,
                            conditionController.text,
                            _image!,
                            context,
                            _resetForm,
                          );
                          setState(() {
                            createReportLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: primary,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: primary,
                ),
                child: Text(
                  'Kembali',
                  style: poppins.copyWith(fontSize: 17, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
