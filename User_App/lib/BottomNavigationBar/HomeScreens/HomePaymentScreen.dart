import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Homepaymentscreen extends StatefulWidget {
  final bool isActive;

  const Homepaymentscreen({
    super.key,
    required this.isActive,
  });

  @override
  State<Homepaymentscreen> createState() => _HomepaymentscreenState();
}

class _HomepaymentscreenState extends State<Homepaymentscreen> {
  static const int maxSeconds = 600; // 10 minutes
  int secondsRemaining = maxSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) startTimer();
  }

  @override
  void didUpdateWidget(covariant Homepaymentscreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == true && oldWidget.isActive == false) {
      startTimer();
    } else if (widget.isActive == false && oldWidget.isActive == true) {
      stopTimer();
    }
  }

  void startTimer() {
    stopTimer();
    secondsRemaining = maxSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (secondsRemaining > 0) {
            secondsRemaining--;
          } else {
            t.cancel();
            Navigator.pushReplacementNamed(context, "/home");
          }
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double progress = 1 - (secondsRemaining / maxSeconds);
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    String timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return SafeArea(
      // Background color as per your theme
      child: Container(
        width: double.infinity,
        color: Colors.black,
        padding: EdgeInsets.all(10),
        child: Column(
        children: [
          // 1. Animation Timer ke UPAR


          const SizedBox(height: 20),

          // 2. Timer Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade900),
                ),
              ),
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "minutes left",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 3. Finding Driver Text (Circle ke BAHAR aur NICHE)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Finding Writer...",
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis
                ),
                maxLines: 2,
              ),


            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Don’t worry! If a writer is not assigned within the given time, you will receive a 100% full refund.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      )
    );
  }
}