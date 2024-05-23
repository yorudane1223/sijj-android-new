import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class CoordinateTab extends StatefulWidget {
  const CoordinateTab({super.key});

  @override
  State createState() => _CoordinateTabState();
}

class _CoordinateTabState extends State<CoordinateTab> {
  Position? _position;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  _openCamera();
                },
                child: const Text('Ambil Gambar dan Koordinat'),
              ),
              const SizedBox(height: 16),
              _position != null
                  ? Text(
                      'Lokasi Sekarang: ${_position!.latitude}, ${_position!.longitude}')
                  : const Text('Tidak ada data lokasi'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });

      await _getCurrentLocation();
    } else {
      print('Gambar tidak dipilih');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      print('posisi saat ini = $position');
      setState(() {
        _position = position;
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
}
