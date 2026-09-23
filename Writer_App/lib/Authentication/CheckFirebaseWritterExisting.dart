import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/ApiConfig/apiConfig.dart';

import '../DeviceIdHelper/DeviceIdHelper.dart';
import '../Toast/ToastHelper.dart';
import 'AuthCheck.dart';

class Checkfirebaseuserexisting extends StatefulWidget {
  final String email;
  final String password;

  const Checkfirebaseuserexisting({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<Checkfirebaseuserexisting> createState() =>
      _CheckfirebaseuserexistingState();
}

class _CheckfirebaseuserexistingState extends State<Checkfirebaseuserexisting> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createOrLoginWriter();
    });
  }

  Future<void> _createOrLoginWriter() async {
    if (_isProcessing) return;

    _isProcessing = true;

    final String email = widget.email.trim();
    final String password = widget.password.trim();

    try {
      final bool allowed = await canCreateAccount();

      if (!mounted) return;

      if (!allowed) {
        ToastHelper.show(
          "This device is already linked with another writer account",
          context,
        );
        navigateToLoginWithDelay();
        return;
      }

      try {
        final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final User? user = userCredential.user;

        if (user == null) {
          if (!mounted) return;

          ToastHelper.show("Account creation failed", context);
          navigateToLoginWithDelay();
          return;
        }

        await user.sendEmailVerification();

        if (!mounted) return;

        ToastHelper.show(
          "Verification email sent to $email",
          context,
        );

        navigateToAuthCheck();
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code == "email-already-in-use") {
          debugPrint("Writer email already exists, trying login...");

          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (!mounted) return;

          ToastHelper.show("Login successful", context);
          navigateToAuthCheck();
          return;
        }

        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Writer Firebase Auth Error Code: ${e.code}");
      debugPrint("Writer Firebase Auth Error Message: ${e.message}");

      if (!mounted) return;

      if (e.code == "wrong-password" || e.code == "invalid-credential") {
        ToastHelper.show("Wrong password. Please try again.", context);
      } else if (e.code == "user-not-found") {
        ToastHelper.show("Account not found. Please create account.", context);
      } else if (e.code == "weak-password") {
        ToastHelper.show("Password is too weak", context);
      } else if (e.code == "invalid-email") {
        ToastHelper.show("Invalid email address", context);
      } else if (e.code == "network-request-failed") {
        ToastHelper.show("Please check your internet connection", context);
      } else {
        ToastHelper.show("Something went wrong: ${e.code}", context);
      }

      navigateToLoginWithDelay();
    } catch (e) {
      debugPrint("Writer Server/Unexpected Error: $e");

      if (!mounted) return;

      ToastHelper.show("Server error. Please try again.", context);
      navigateToLoginWithDelay();
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> canCreateAccount() async {
    final String deviceId = await DeviceIdHelper.getDeviceId();

    if (deviceId.trim().isEmpty) {
      debugPrint("Writer Device ID is empty");
      return false;
    }

    final uri = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/auth/public/canCreateAccount",
    ).replace(
      queryParameters: {
        "deviceId": deviceId,
        "email": widget.email.trim(),
      },
    );

    debugPrint("Writer canCreateAccount URL: $uri");

    final res = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
    );

    debugPrint("Writer canCreateAccount Status: ${res.statusCode}");
    debugPrint("Writer canCreateAccount Body: ${res.body}");

    if (res.statusCode != 200) {
      return false;
    }

    final Map<String, dynamic> data = jsonDecode(res.body);

    return data["allowed"] == true;
  }

  void navigateToLoginWithDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  void navigateToAuthCheck() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthCheck()),
            (route) => false,
      );
    });
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