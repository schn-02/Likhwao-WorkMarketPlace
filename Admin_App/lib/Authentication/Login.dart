import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:adminlikhwao/Authentication/EmailVerificationScreen.dart';
import 'package:adminlikhwao/Authentication/Enterdetailsscreen.dart';
import 'package:adminlikhwao/BottomNavigationBar/MainBottomNavigationBar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginOrRegisterAdmin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      UserCredential userCredential;

      try {
        // First try to create account.
        // New email hoga to yahi success hoga.
        userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await userCredential.user?.sendEmailVerification();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Emailverificationscreen(email: email),
          ),
        );
        return;
      } on FirebaseAuthException catch (createError) {
        debugPrint("CREATE ADMIN ERROR CODE : ${createError.code}");
        debugPrint("CREATE ADMIN ERROR MSG : ${createError.message}");

        if (createError.code == "email-already-in-use") {
          // Existing account hoga to login karo.
          userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else if (createError.code == "invalid-email") {
          _showMessage("Invalid email address");
          return;
        } else if (createError.code == "weak-password") {
          _showMessage("Password weak hai. Minimum 6 characters use karo.");
          return;
        } else if (createError.code == "network-request-failed") {
          _showMessage("Internet connection check karo");
          return;
        } else {
          _showMessage(createError.message ?? "Account create nahi ho paaya");
          return;
        }
      }

      final User? user = userCredential.user;

      if (user == null) {
        _showMessage("User not found");
        return;
      }

      await user.reload();

      final User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        _showMessage("User session expired");
        return;
      }

      if (!refreshedUser.emailVerified) {
        await refreshedUser.sendEmailVerification();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Emailverificationscreen(
              email: refreshedUser.email ?? email,
            ),
          ),
        );
        return;
      }

      await _checkAdminStatusAndNavigate(refreshedUser);
    } on FirebaseAuthException catch (loginError) {
      debugPrint("LOGIN ADMIN ERROR CODE : ${loginError.code}");
      debugPrint("LOGIN ADMIN ERROR MSG : ${loginError.message}");

      if (loginError.code == "wrong-password" ||
          loginError.code == "invalid-credential") {
        _showMessage("Password galat hai ya account isi password se nahi bana.");
      } else if (loginError.code == "invalid-email") {
        _showMessage("Invalid email address");
      } else if (loginError.code == "user-disabled") {
        _showMessage("This account is disabled");
      } else if (loginError.code == "network-request-failed") {
        _showMessage("Internet connection check karo");
      } else {
        _showMessage(loginError.message ?? "Login failed");
      }
    } catch (e) {
      debugPrint("LOGIN OR REGISTER ERROR : $e");
      _showMessage("Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _checkAdminStatusAndNavigate(User user) async {
    try {
      final String? token = await user.getIdToken(true);

      if (token == null) {
        _showMessage("Token not found");
        return;
      }

      final response = await http.get(
        Uri.parse("${apiConfig.baseUrl}/api/admin/auth/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("ADMIN ME STATUS : ${response.statusCode}");
      debugPrint("ADMIN ME BODY : ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final bool detailsCompleted =
            body["detailsCompleted"] == true ||
                body["details_completed"] == true;

        if (detailsCompleted) {
          _goToDashboard();
        } else {
          _goToEnterDetails();
        }

        return;
      }

      if (response.statusCode == 404) {
        _goToEnterDetails();
        return;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        _showMessage("Unauthorized admin");
        return;
      }

      _showMessage("Admin check failed: ${response.statusCode}");
    } catch (e) {
      debugPrint("ADMIN STATUS CHECK ERROR : $e");
      _showMessage("Unable to check admin status");
    }
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _logoSection(),
                    const SizedBox(height: 32),
                    _mainCard(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _logoSection() {
    return Column(
      children: [
        Container(
          height: 82,
          width: 82,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primary.withOpacity(0.35)),
          ),
          child: Icon(
            Icons.admin_panel_settings_outlined,
            color: primary,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        Text(
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
          "Manage orders, disputes and users",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _mainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Login / Register"),
            const SizedBox(height: 8),
            _subtitle(
              "Account will create if there is new Admin , else redirecting to the home",
            ),
            const SizedBox(height: 22),
            _inputField(
              controller: emailController,
              label: "Admin Email",
              hint: "example@gmail.com",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email required";
                }
                if (!value.contains("@") || !value.contains(".")) {
                  return "Enter valid email";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _passwordField(),
            const SizedBox(height: 22),
            _mainButton(
              title: "Continue",
              icon: Icons.arrow_forward,
              onTap: loginOrRegisterAdmin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      style: TextStyle(color: textColor),
      cursorColor: primary,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Minimum 6 characters",
        hintStyle: TextStyle(color: subText.withOpacity(0.7)),
        labelStyle: TextStyle(color: subText),
        prefixIcon: Icon(Icons.lock_outline, color: subText),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: subText,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: card2,
        errorMaxLines: 2,
        errorStyle: const TextStyle(fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Password required";
        }
        if (value.trim().length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }

  Widget _title(String value) {
    return Text(
      value,
      style: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _subtitle(String value) {
    return Text(
      value,
      style: TextStyle(
        color: subText,
        fontSize: 13,
        height: 1.4,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: textColor),
      cursorColor: primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: subText.withOpacity(0.7)),
        labelStyle: TextStyle(color: subText),
        prefixIcon: Icon(icon, color: subText),
        filled: true,
        fillColor: card2,
        errorMaxLines: 2,
        errorStyle: const TextStyle(fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _mainButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(icon, size: 20),
        label: FittedBox(
          child: Text(
            isLoading ? "Please wait..." : title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withOpacity(0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}