
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceIdHelper {
  static Future<String> getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfoPlugin.androidInfo;

      final String androidId = androidInfo.id;
      final String brand = androidInfo.brand;
      final String model = androidInfo.model;
      final String manufacturer = androidInfo.manufacturer;

      final String rawDeviceKey =
          "$androidId-$brand-$model-$manufacturer";

      final String hashedDeviceId =
      sha256.convert(utf8.encode(rawDeviceKey)).toString();

      return hashedDeviceId;
    }

    return "";
  }
}