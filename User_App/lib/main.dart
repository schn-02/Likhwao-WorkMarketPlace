import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:likhwao/Authentication/AuthCheck.dart';
import 'package:likhwao/Authentication/EmailVerificationUi.dart';
import 'package:likhwao/Authentication/EnterDetails.dart';
import 'package:likhwao/Authentication/otp_Ui.dart';
import 'package:likhwao/Authentication/LoginUi.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen2_Info.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen3_deliveryInfo.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen4_IndexStack.dart';
import 'package:likhwao/BottomNavigationBar/MainBottomNavigationBar.dart';
import 'package:likhwao/Provider/ChatListProvider.dart';
import 'package:likhwao/firebase_options.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();


void main() async {



  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(

    MultiProvider(providers:[

      
      ChangeNotifierProvider(create: (_)=> Chatlistprovider(),),

    ],
      child:  const MyApp()
    )
  );



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
        '/Otp_ui' :(context) =>Otp_Ui(),
        '/enterDetails' :(context) =>EnterDetails(),
        '/home' :(context) => Mainbottomnavigationbar(),
        '/emailVerification' :(context) => EmailverificationUi(email: ''),
        '/HomeScreen2' :(context) => Homescreen2Info(),
      },
      debugShowCheckedModeBanner: false ,
    );

}





}
