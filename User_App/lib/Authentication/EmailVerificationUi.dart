import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:likhwao/Toast/ToastHelper.dart';

import 'AuthCheck.dart';

class EmailverificationUi extends StatefulWidget {
  final String email;

  const EmailverificationUi({
    super.key,
    required this.email,
  });

  @override
  State<EmailverificationUi> createState() => _EmailverificationUiState();
}

class _EmailverificationUiState extends State<EmailverificationUi> {

  Timer? _timer;
  final int _timeoutSeconds = 90;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _startEmailCheckTimer();
  }

  void _startEmailCheckTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      _elapsed += 3;

      final user = FirebaseAuth.instance.currentUser;

      if(user ==null)
        {
          _timer?.cancel();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthCheck()),
                (route) => false,
          );
          return;
        }

      await user.reload();

      bool verified = user.emailVerified;

      if (verified) {
        ToastHelper.show("Email verified! Redirecting...", context);
        _timer?.cancel();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthCheck()),
                (route) => false,
          );
        });

      } else if (_elapsed >= _timeoutSeconds) {
        // Timeout → redirect to login
        ToastHelper.show("Email not verified, please try again.", context);
        Navigator.pushReplacementNamed(context, "/login");
        _timer?.cancel();

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height * 0.12,
            child: Image.asset(
              "assets/images/gmail.png",
              fit: BoxFit.contain,
            ),
          ),
          Text(
            "We have sent a verification link  to your email",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),

          InkWell(
            onTap: ()
            {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("${widget.email}" ,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,

          ),
          ),



          SizedBox(height: 8),
          Text(
            "Please check your inbox or spam folder too . You will be redirected automatically after verification.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}




