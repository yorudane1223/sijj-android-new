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
import 'package:sijj_provinsi_banten/models/road_model.dart';
import 'package:sijj_provinsi_banten/pages/report_page.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';
import 'package:geolocator/geolocator.dart';

Future<RoadModel> getRoads() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginToken = prefs.getString('loginToken');

  final response = await http.get(
    Uri.parse(myRoads),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'},
  );

  final responseJson = jsonDecode(response.body);

  if (response.statusCode == 200) {
    if (responseJson['success'] && responseJson['data'] != null) {
      return RoadModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Tidak ada data jalan ditemukan');
    }
  } else {
    throw Exception('Failed to load roads');
  }
}

Future<void> createReport(
    String latitude,
    String longitude,
    String condition,
    String road,
    String information,
    File image,
    BuildContext context,
    VoidCallback onSuccess) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginToken = prefs.getString('loginToken');

  var request = http.MultipartRequest('POST', Uri.parse(createReportApiUrl));
  request.headers[HttpHeaders.authorizationHeader] = 'Bearer $loginToken';
  request.headers['Accept'] = 'application/json';

  request.fields['latitude'] = longitude;
  request.fields['longitude'] = latitude;
  request.fields['kondisi'] = condition;
  request.fields['ruas_jalan_id'] = road;
  request.fields['keterangan'] = information;
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ReportPage(
                      imageUrl: '',
                      latitude: '',
                      longitude: '',
                    )));
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
  bool roadsLoading = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController conditionController = TextEditingController();
  final TextEditingController informationController = TextEditingController();

  File? _image;
  String? _latitude;
  String? _longitude;

  final ImagePicker _picker = ImagePicker();
  String? _selectedCondition;
  String? _selectedRoadId;

  List<Road> _roads = [];
  final List<String> _conditions = [
    'baik',
    'sedang',
    'rusak',
    'ringan',
    'rusak berat'
  ];

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
      _selectedCondition = null;
      _selectedRoadId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRoads();
  }

  Future<void> _fetchRoads() async {
    try {
      final roadModel = await getRoads();
      setState(() {
        _roads = roadModel.data;
        roadsLoading = false;
      });
    } catch (error) {
      print('error di catch $error');
      setState(() {
        roadsLoading = false;
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
                                          'Tidak ada gambar yang diambil, ketuk untuk mengambil gambar',
                                          style: TextStyle(
                                            fontSize: 10,
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
                            'Ketuk gambar untuk mengulangi pengambilan gambar',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )
                        : const SizedBox(height: 15),
                    const SizedBox(height: 15),
                    roadsLoading
                        ? Center(
                            child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              Text(
                                'Data ruas jalan sedang di muat',
                                style: poppins.copyWith(fontSize: 11),
                              )
                            ],
                          ))
                        : DropdownButtonFormField<String>(
                            value: _selectedRoadId,
                            items: _roads.map((Road road) {
                              return DropdownMenuItem<String>(
                                value: road.id.toString(),
                                child: Text('${road.nama} (${road.id})',
                                    style: poppins.copyWith(fontSize: 14)),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Ruas Jalan',
                              hintText: 'Pilih Ruas Jalan',
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRoadId = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ruas jalan tidak boleh kosong!';
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      items: _conditions.map((String condition) {
                        return DropdownMenuItem<String>(
                          value: condition,
                          child: Text(condition,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal)),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Kondisi Ruas Jalan',
                          hintText: 'Pilih Kondisi Ruas Jalan',
                          hintStyle: TextStyle(fontWeight: FontWeight.normal)),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCondition = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kondisi ruas jalan tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: informationController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Keterangan',
                        labelStyle: TextStyle(fontFamily: 'Poppins'),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Keterangan tidak boleh kosong!';
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
                  : imageLoading
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
                                _selectedCondition!,
                                _selectedRoadId!,
                                informationController.text,
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
