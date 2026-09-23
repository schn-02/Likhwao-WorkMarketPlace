import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:likhwao/ApiConfig/apiConfig.dart';
import 'package:likhwao/DeviceIdHelper/DeviceIdHelper.dart';
import 'package:likhwao/Model/AuthModel.dart';
import 'package:likhwao/Toast/ToastHelper.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Authbackend extends StatefulWidget {
  final String name;
  final String countryCode;
  final String countryName;
  final String phoneNumber;

  const Authbackend({
    super.key,
    required this.name,
    required this.countryCode,
    required this.countryName,
    required this.phoneNumber,
  });

  @override
  State<Authbackend> createState() => _AuthbackendState();
}

class _AuthbackendState extends State<Authbackend> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initSecureData();
    });
  }

  static Future<String> getAppSignature() async {
    final info = await PackageInfo.fromPlatform();
    final raw = "${info.packageName}:${info.version}";
    return sha256.convert(utf8.encode(raw)).toString();
  }

  Future<void> initSecureData() async {
    try {
      debugPrint("XX:- Entering init method....");

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        ToastHelper.show("Please login again", context);
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      await user.reload();

      final User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        if (!mounted) return;

        ToastHelper.show("Please login again", context);
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      final String firebaseUid = refreshedUser.uid;
      final String email = refreshedUser.email ?? "";
      final String? firebaseIdToken = await refreshedUser.getIdToken(true);
      final bool emailVerified = refreshedUser.emailVerified;

      if (!emailVerified) {
        if (!mounted) return;

        ToastHelper.show("Please verify your email first", context);
        Navigator.pushReplacementNamed(context, "/emailVerification");
        return;
      }

      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      final String deviceId = await DeviceIdHelper.getDeviceId();

      final String deviceModel = androidInfo.model;
      final String androidId = androidInfo.id;
      final String brand = androidInfo.brand;
      final String manufacturer = androidInfo.manufacturer;

      final bool emulator = !androidInfo.isPhysicalDevice;

      final String firebaseInstallationId =
      await FirebaseInstallations.instance.getId();

      final String appHash = await getAppSignature();

      final AuthModel authModel = AuthModel(
        firebaseUid: firebaseUid,
        email: email,
        name: widget.name.trim(),
        firebaseIdToken: firebaseIdToken!,

        deviceId: deviceId,
        deviceModel: deviceModel,
        androidId: androidId,
        firebaseInstallationId: firebaseInstallationId,
        brand: brand,
        manufacturer: manufacturer,

        countryCode: widget.countryCode,
        countryName: widget.countryName,
        phoneNumber: widget.phoneNumber.trim(),

        rooted: false,
        emulator: emulator,
        appHash: appHash,

        emailVerified: emailVerified,
        detailsCompleted: true,
      );

      debugPrint("XX:- AuthModel: $authModel");

      await sendToBackend(
        authModel: authModel,
        firebaseIdToken: firebaseIdToken,
      );
    } catch (e) {
      debugPrint("XX:- initSecureData error: $e");

      if (!mounted) return;

      ToastHelper.show("Something went wrong", context);
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future<void> sendToBackend({
    required AuthModel authModel,
    required String firebaseIdToken,
  }) async {
    debugPrint("XX:- Enter Send to backend method");

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/user_side/auth/SaveUserDetails",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $firebaseIdToken",
        },
        body: jsonEncode(authModel.toJson()),
      );

      debugPrint("XX:- Response Status: ${response.statusCode}");
      debugPrint("XX:- Response Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        ToastHelper.show("Profile completed successfully", context);
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      String message = "Login rejected";

      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        message = data["message"] ?? message;
      } catch (_) {}

      ToastHelper.show(message, context);

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      debugPrint("XX:- Server error: $e");

      if (!mounted) return;

      ToastHelper.show("Server error. Please try again.", context);
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}