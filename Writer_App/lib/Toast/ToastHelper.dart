import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void show(String message , BuildContext context) {
    final fToast = FToast();
    fToast.init(context);


    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.blue,
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
