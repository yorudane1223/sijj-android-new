// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/pages/my_profile_page.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class CropImage extends StatefulWidget {
  const CropImage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<CropImage> {
  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: white,
        title: Text(
          'Edit Foto Profil',
          style: poppins,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
              child: Text(
                'title',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Theme.of(context).highlightColor),
              ),
            ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_croppedFile != null || _pickedFile != null) {
      return _imageCard();
    } else {
      return _uploaderCard();
    }
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                child: _image(),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(File(path)),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  cropCondition();
                },
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                )),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  _clear();
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
            const SizedBox(
              width: 30,
            ),
            if (_croppedFile == null)
              ElevatedButton(
                  onPressed: () {
                    _cropImage();
                  },
                  child: Icon(
                    Icons.crop,
                    color: primary,
                  ))
          ],
        )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: kIsWeb ? 380.0 : 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: primary,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: primary,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text('Silahkan pilih gambar',
                              style: poppins.copyWith(color: primary))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: primary),
                  child: Text(
                    'unggah',
                    style: poppins,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Atur ukuran gambar',
              toolbarColor: primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Atur ukuran gambar',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }

  // crop condition
  Future<void> cropCondition() async {
    if (_croppedFile != null) {
      updateProfileUserImage(_croppedFile);
    } else {
      updateProfileUserImage(_pickedFile);
    }
  }

  // send request update to api
  Future<void> updateProfileUserImage(imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('loginToken');

      if (loginToken == null) {
        QuickAlert.show(
          confirmBtnColor: primary,
          barrierDismissible: false,
          context: context,
          type: QuickAlertType.error,
          text: 'token login tidak ada!',
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(updateProfileUserImageApiUrl),
      );
      request.headers['authorization'] = 'Bearer $loginToken';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        QuickAlert.show(
          confirmBtnColor: primary,
          barrierDismissible: false,
          onConfirmBtnTap: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyProfilePage()))
          },
          context: context,
          type: QuickAlertType.success,
          text: responseData['message'],
        );
      } else {
        QuickAlert.show(
          confirmBtnColor: primary,
          barrierDismissible: false,
          context: context,
          type: QuickAlertType.warning,
          text: responseData['message'],
        );
      }
    } catch (e) {
      QuickAlert.show(
        confirmBtnColor: primary,
        context: context,
        barrierDismissible: false,
        type: QuickAlertType.error,
        text: '$e',
      );
    }
  }
}
