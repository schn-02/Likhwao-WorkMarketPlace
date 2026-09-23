import 'dart:convert';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:adminlikhwao/BottomNavigationBar/MainBottomNavigationBar.dart';
import 'package:adminlikhwao/Model/AdminSaveDetailsRequest.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// import your main bottom navigation page
// import 'package:your_app/MainBottomNavigationBar.dart';

class Enterdetailsscreen extends StatefulWidget {
  const Enterdetailsscreen({super.key});

  @override
  State<Enterdetailsscreen> createState() => _EnterdetailsscreenState();
}

class _EnterdetailsscreenState extends State<Enterdetailsscreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage("User not logged in");
        return;
      }


      final token =
      await FirebaseAuth.instance.currentUser?.getIdToken();

      final requestModel = AdminSaveDetailsRequest(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      final response = await http.post(
        Uri.parse(
          "${apiConfig.baseUrl}/api/admin/auth/save-details",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestModel.toJson()),
      );

      if (response.statusCode == 200) {
        _showMessage("Admin details saved");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Mainbottomnavigationbar(),
          ),
        );
      } else {
        _showMessage(
          "Failed : ${response.statusCode}",
        );
      }
    } catch (e) {
      _showMessage("Something went wrong: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String email = FirebaseAuth.instance.currentUser?.email ?? "Admin Email";

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
                    _topIcon(),
                    const SizedBox(height: 28),
                    _detailsCard(email),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topIcon() {
    return Column(
      children: [
        Container(
          height: 86,
          width: 86,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: primary.withOpacity(0.35)),
          ),
          child: Icon(
            Icons.admin_panel_settings_outlined,
            color: primary,
            size: 45,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Admin Details",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Complete your admin profile",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _detailsCard(String email) {
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
            _emailBox(email),
            const SizedBox(height: 20),
            _inputField(
              controller: nameController,
              label: "Full Name",
              hint: "Enter Name",
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Name required";
                }
                if (value.trim().length < 3) {
                  return "Name too short";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: phoneController,
              label: "Phone Number",
              hint: "Enter Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Phone required";
                }
                if (value.trim().length < 10) {
                  return "Enter valid phone";
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _mainButton(),
          ],
        ),
      ),
    );
  }

  Widget _emailBox(String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              email,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

  Widget _mainButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _saveDetails,
        icon: isLoading
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.check_circle_outline),
        label: FittedBox(
          child: Text(
            isLoading ? "Saving..." : "Save & Continue",
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