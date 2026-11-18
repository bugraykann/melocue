import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';

class LocationService {
  final LocalStorageService _storageService;

  LocationService(this._storageService);

  /// Requests permission and determines the user's country code.
  /// Falls back to 'US' (Global) if permission is denied or an error occurs.
  Future<String> determineUserCountry() async {
    if (_storageService.isCountryManual &&
        _storageService.countryCode != null) {
      return _storageService.countryCode!;
    }

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return default
      return _saveAndReturnDefault();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _saveAndReturnDefault();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _saveAndReturnDefault();
    }

    try {
      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Get placemarks from coordinates
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        String? isoCountryCode = placemarks.first.isoCountryCode;
        if (isoCountryCode != null && isoCountryCode.isNotEmpty) {
          final code = isoCountryCode.toUpperCase();
          await _storageService.saveCountryCode(code);
          return code;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Location error: $e');
      }
      // Ignore errors and fallback
    }

    if (kDebugMode) {
      print('Returning default US');
    }
    return _saveAndReturnDefault();
  }

  Future<String> _saveAndReturnDefault() async {
    // If we already have a saved country code, keep it, else save US
    String? current = _storageService.countryCode;
    if (current == null || current.isEmpty) {
      await _storageService.saveCountryCode('US');
      return 'US';
    }
    return current;
  }
}
