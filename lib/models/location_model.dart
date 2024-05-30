import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationModel with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  StreamSubscription<Position>? _positionStream;

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void setLocation(double lat, double long) {
    _latitude = lat;
    _longitude = long;
    notifyListeners();
  }

  Future<void> startLocationUpdates() async {
    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      notifyListeners();
    });
  }

  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
