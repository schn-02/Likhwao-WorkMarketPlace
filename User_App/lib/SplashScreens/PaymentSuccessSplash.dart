import 'package:flutter/material.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomePaymentScreen.dart';
import 'package:likhwao/BottomNavigationBar/OrderScreen/OrdersScreen.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessSplash extends StatefulWidget {
  const PaymentSuccessSplash({super.key});

  @override
  State<PaymentSuccessSplash> createState() => _PaymentSuccessSplashState();
}

class _PaymentSuccessSplashState extends State<PaymentSuccessSplash> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>Ordersscreen())
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // back button disable
      child: Scaffold(
        body: Stack(

          children: [

            // 🔥 Full background blast animation
            Positioned.fill(
              child: Lottie.asset(
                'assets/animation/blast.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Lottie.asset(
                      'assets/animation/success.json',
                      repeat: false,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Payment Successful",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Your order has been placed successfully",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
