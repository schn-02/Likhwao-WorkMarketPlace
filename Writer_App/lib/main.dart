import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/Authentication/AuthCheck.dart';
import 'package:likho/Authentication/EmailVerificationUi.dart';
import 'package:likho/Authentication/EnterDetails.dart';
import 'package:likho/Authentication/LoginUi.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/AvailableOrderScreens/OrderDetailsScreen.dart';
import 'package:media_store_plus/media_store_plus.dart';

import 'BottomNavigationBar/MainBottomNavigationBar.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();




    await MediaStore.ensureInitialized();



    MediaStore.appFolder = "Likho";

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:navigatorKey,
      initialRoute: '/',
      routes: {
        '/' :(context) =>AuthCheck(),
        '/login': (context) => LoginUi(),
        '/enterDetails' :(context) =>EnterDetails(),
        '/home' :(context) => Mainbottomnavigationbar(),
        '/emailVerification' :(context) => EmailverificationUi(email: ''),
      },
      debugShowCheckedModeBanner: false ,
    );
  }}
