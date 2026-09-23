import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:adminlikhwao/Authentication/Login.dart';
import 'package:adminlikhwao/Authentication/Enterdetailsscreen.dart';
import 'package:adminlikhwao/Authentication/EmailVerificationScreen.dart';
import 'package:adminlikhwao/BottomNavigationBar/MainBottomNavigationBar.dart';
import 'package:adminlikhwao/Model/AdminDetailsResponse.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class Authcheckscreen extends StatefulWidget {
  const Authcheckscreen({super.key});

  @override
  State<Authcheckscreen> createState() => _AuthcheckscreenState();
}

class _AuthcheckscreenState extends State<Authcheckscreen> {
  bool isChecking = true;
  String checkingText = "Checking authentication...";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUser();
    });
  }

  Future<void> checkUser() async {
    try {
      setState(() {
        isChecking = true;
        checkingText = "Checking authentication...";
      });

      final User? currentUser = FirebaseAuth.instance.currentUser;

      debugPrint("CURRENT USER UID : ${currentUser?.uid}");
      debugPrint("CURRENT USER EMAIL : ${currentUser?.email}");
      debugPrint("CURRENT USER VERIFIED : ${currentUser?.emailVerified}");

      if (currentUser == null) {
        _goToLogin();
        return;
      }

      await currentUser.reload();

      final User? refreshedUser = FirebaseAuth.instance.currentUser;

      debugPrint("REFRESHED USER UID : ${refreshedUser?.uid}");
      debugPrint("REFRESHED USER EMAIL : ${refreshedUser?.email}");
      debugPrint("REFRESHED USER VERIFIED : ${refreshedUser?.emailVerified}");

      if (refreshedUser == null) {
        _goToLogin();
        return;
      }

      if (!refreshedUser.emailVerified) {
        _goToEmailVerification(refreshedUser.email ?? "");
        return;
      }

      setState(() {
        checkingText = "Checking admin profile...";
      });

      final String? token = await refreshedUser.getIdToken(true);



      final Uri url = Uri.parse("${apiConfig.baseUrl}/api/admin/auth/me");

      debugPrint("AUTH ME URL : $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("AUTH ME STATUS : ${response.statusCode}");
      debugPrint("AUTH ME BODY : ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          _goToEnterDetails();
          return;
        }

        final body = jsonDecode(response.body);



        final admin = AdminDetailsResponse.fromJson(body);

        if (admin.detailsCompleted) {
          _goToDashboard();
        } else {
          _goToEnterDetails();
        }

        return;
      }

      if (response.statusCode == 404) {
        debugPrint("ADMIN NOT FOUND IN DATABASE. GOING TO ENTER DETAILS.");
        _goToEnterDetails();
        return;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        _showErrorAndStay(
          "Backend unauthorized error ${response.statusCode}. Token/filter issue hai.",
        );
        return;
      }

      if (response.statusCode >= 500) {
        _showErrorAndStay(
          "Server error ${response.statusCode}. Backend check karo.",
        );
        return;
      }

      _showErrorAndStay(
        "Admin check failed: ${response.statusCode}",
      );
    } catch (e) {
      debugPrint("AUTH CHECK ERROR : $e");

      _showErrorAndStay(
        "Auth check failed. Backend/API issue ho sakta hai.",
      );
    }
  }

  void _showErrorAndStay(String message) {
    if (!mounted) return;

    setState(() {
      isChecking = false;
      checkingText = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _forceLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("FORCE LOGOUT ERROR : $e");
    }

    _goToLogin();
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Login(),
      ),
    );
  }

  void _goToEmailVerification(String email) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Emailverificationscreen(email: email),
      ),
    );
  }

  void _goToEnterDetails() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Enterdetailsscreen(),
      ),
    );
  }

  void _goToDashboard() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Mainbottomnavigationbar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF07111F);
    const Color primary = Color(0xFF4FA3FF);
    const Color textColor = Color(0xFFF3F7FF);
    const Color subText = Color(0xFF9FB0C7);
    const Color card = Color(0xFF0E1B2E);
    const Color border = Color(0xFF22344D);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: primary,
                  size: 50,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Likhwao Admin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                checkingText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: subText,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 35),

              if (isChecking)
                const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 3,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 34,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Authentication check failed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        checkingText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: subText,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: checkUser,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            "Retry",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: _forceLogout,
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            "Logout",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}