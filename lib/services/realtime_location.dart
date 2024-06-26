import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/models/location_model.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class LocationService {
  StreamSubscription<Position>? positionStream;

  Future<void> startTracking(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showPermissionDeniedMessage(context);
    } else if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedForeverMessage(context);
    } else {
      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        ),
      ).listen((Position position) {
        _sendLocationToApi(context, position);
        Provider.of<LocationModel>(context, listen: false)
            .setLocation(position.latitude, position.longitude);
      });
    }
  }

  void stopTracking() {
    positionStream?.cancel();
  }

  Future<void> _sendLocationToApi(
      BuildContext context, Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('loginToken');

    if (loginToken == null) {
      print('Login token is null');
      return;
    }

    print('${position.latitude}, ${position.longitude} : realtime_location');

    try {
      final response = await http.post(
        Uri.parse(realtimeLocationStore),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $loginToken'},
        body: {
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        print('Location sent successfully');
      } else {
        print('Failed to send location. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending location: $e'),
        ),
      );
    }
  }

  void _showPermissionDeniedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permission Denied',
            style: poppins,
          ),
          content: Text(
            'Location access is needed for this app. Please enable location access in the app settings.',
            style: poppins,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Retry',
                style: poppins,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                startTracking(context);
              },
            ),
            TextButton(
              child: Text(
                'Settings',
                style: poppins,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permission Denied Forever',
            style: poppins,
          ),
          content: Text(
            'Location access is permanently denied. Please enable location access in the app settings.',
            style: poppins,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Settings',
                style: poppins,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
