import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likhwao/ApiConfig/apiConfig.dart';
import 'package:likhwao/DeviceIdHelper/DeviceIdHelper.dart';
import 'package:likhwao/Toast/ToastHelper.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("User is null");

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (!refreshedUser.emailVerified) {
        debugPrint("Email not verified");

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/emailVerification');
        return;
      }

      final token = await refreshedUser.getIdToken(true);

      final deviceId = await DeviceIdHelper.getDeviceId();

      debugPrint("Device Id: $deviceId");

      if (deviceId == null || deviceId.trim().isEmpty) {
        if (!mounted) return;
        ToastHelper.show("Unable to verify this device", context);
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      await checkUser(
        deviceId: deviceId,
        jwtToken: token!,
        firebaseUid: refreshedUser.uid,
      );
    } catch (e) {
      debugPrint("Auth check error: $e");

      if (!mounted) return;
      ToastHelper.show("Something went wrong", context);
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future<void> checkUser({
    required String deviceId,
    required String jwtToken,
    required String firebaseUid,
  }) async {
    try {
      debugPrint("Checking user from backend...");

      final uri = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/auth/checkUser",
      ).replace(
        queryParameters: {
          "deviceId": deviceId,
          "firebaseUid": firebaseUid,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json",
        },
      );

      debugPrint("Check user status: ${response.statusCode}");
      debugPrint("Check user body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode != 200) {
        ToastHelper.show("Server error, try again", context);
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final bool userExists = data["userExists"] == true;
      final bool deviceLockedByOtherAccount =
          data["deviceLockedByOtherAccount"] == true;
      final bool detailsCompleted = data["detailsCompleted"] == true;
      final bool blocked = data["blocked"] == true;

      if (blocked) {
        ToastHelper.show("Your account has been blocked", context);
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      if (deviceLockedByOtherAccount) {
        ToastHelper.show(
          "This device is already linked with another account",
          context,
        );

        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      if (!userExists) {
        Navigator.pushReplacementNamed(context, "/enterDetails");
        return;
      }

      if (userExists && !detailsCompleted) {
        Navigator.pushReplacementNamed(context, "/enterDetails");
        return;
      }

      if (userExists && detailsCompleted) {
        Navigator.pushReplacementNamed(context, "/home");
        return;
      }

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      debugPrint("Check user API error: $e");

      if (!mounted) return;
      ToastHelper.show("Something went wrong", context);
      await FirebaseAuth.instance.signOut();
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