import 'dart:async';
import 'package:adminlikhwao/Authentication/EnterDetailsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import your enter details screen here
// import 'package:your_app/enter_admin_details.dart';

class Emailverificationscreen extends StatefulWidget {
  final String email;

  const Emailverificationscreen({
    super.key,
    required this.email,
  });

  @override
  State<Emailverificationscreen> createState() =>
      _EmailverificationscreenState();
}

class _EmailverificationscreenState extends State<Emailverificationscreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Timer? timer;
  bool isLoading = false;
  bool isResending = false;

  final Color bg = const Color(0xFF07111F);
  final Color card = const Color(0xFF0E1B2E);
  final Color card2 = const Color(0xFF13243A);
  final Color primary = const Color(0xFF4FA3FF);
  final Color textColor = const Color(0xFFF3F7FF);
  final Color subText = const Color(0xFF9FB0C7);
  final Color border = const Color(0xFF22344D);

  @override
  void initState() {
    super.initState();
    // _sendVerificationEmail();
    _startCheckingVerification();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final User? user = auth.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showMessage("Verification email sent");
      }
    } catch (e) {
      _showMessage("Email send failed: $e");
    }
  }

  void _startCheckingVerification() {
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkEmailVerified(autoCheck: true);
    });
  }

  Future<void> _checkEmailVerified({bool autoCheck = false}) async {
    try {
      if (!autoCheck && mounted) {
        setState(() => isLoading = true);
      }

      await auth.currentUser?.reload();
      final User? user = auth.currentUser;

      if (user != null && user.emailVerified) {
        timer?.cancel();

        if (!mounted) return;

        _showMessage("Email verified successfully");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Enterdetailsscreen(),
          ),
        );
      }
    } catch (e) {
      if (!autoCheck) {
        _showMessage("Verification check failed");
      }
    } finally {
      if (!autoCheck && mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  Future<void> _resendEmail() async {
    setState(() => isResending = true);

    await _sendVerificationEmail();

    if (mounted) {
      setState(() => isResending = false);
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
                    _verificationCard(),
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
            Icons.mark_email_read_outlined,
            color: primary,
            size: 45,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Verify Your Email",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Check your inbox and verify your admin email",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _verificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verification link sent to",
            style: TextStyle(
              color: subText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
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
                    widget.email,
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
          ),

          const SizedBox(height: 20),

          Text(
            "After clicking the verification link in your email, this screen will automatically continue.",
            style: TextStyle(
              color: subText,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _checkEmailVerified(),
              icon: isLoading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.refresh),
              label: Text(
                isLoading ? "Checking..." : "I Have Verified",
                style: const TextStyle(fontWeight: FontWeight.bold),
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
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: isResending ? null : _resendEmail,
              icon: Icon(Icons.send_outlined, color: subText, size: 18),
              label: Text(
                isResending ? "Sending..." : "Resend Email",
                style: TextStyle(
                  color: subText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "Auto checking every 3 seconds",
              style: TextStyle(
                color: subText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}