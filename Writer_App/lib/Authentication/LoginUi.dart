import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'CheckFirebaseWritterExisting.dart';


class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<LoginUi> createState() => _LoginState();
}

class _LoginState extends State<LoginUi> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible =true;

  bool isContinueClicked = false;
  final fToast = FToast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableKeyboard = screenHeight - keyboardHeight;
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.redAccent]),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableKeyboard),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      logoAndName(),

                      SizedBox(height: 60),
                      enterEmail_Password(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // number enters karne ke liye UI
  Widget enterEmail_Password() {
    final w =  MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child:Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red, width: 1),
      ),
      shadowColor: Colors.black,

      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blueAccent, Colors.yellow]),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.03,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                   TextField(
                      controller: emailController,
                     keyboardType: TextInputType.emailAddress,

                     style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize:16,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white10,
                            width: 4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w*0.02),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        hintText: "Enter you Email ID",
                        hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                     SizedBox(height: 10,),
                     TextField(
                      controller: passwordController,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),

                      obscureText: _isPasswordVisible,
                       keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white10,
                            width: 4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w*0.02),
                          borderSide: BorderSide(color: Colors.orange),
                        ),

                        suffixIcon: IconButton(onPressed: (){
                          setState(() {

                            _isPasswordVisible =!_isPasswordVisible;
                          });
                        },
                            icon: Icon(_isPasswordVisible ?Icons.visibility_off :Icons.visibility,
                              color: Colors.black,
                              size: 22,
                            )

                        ),


                        hintText: "Enter your password",
                        hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),

                  ),

              continueAndGoogleButton(),
            ],
          ),
        ),
      ),
      )
    );
  }


  // logo and some stuff UI

  Widget logoAndName() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.12,
            child: Image.asset(
              "assets/images/letterl.png",
              fit: BoxFit.contain,
            ),
          ),

          Text(
            "Likhwao nhi Likho",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          Text(
            "Log in or sign up",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // continue button and google button

  Widget continueAndGoogleButton() {
    final h = MediaQuery.of(context).size.width*0.08;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.height*0.01,
        vertical: MediaQuery.of(context).size.height*0.03,
      ),

      child: Column(
        children: [
          SizedBox(
            height: h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {


                Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>Checkfirebaseuserexisting(
                      email :emailController.text,
                      password:passwordController.text
                    )));

              }
              ,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(h*0.20),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize:MediaQuery.of(context).size.width*0.045,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: 10),

          Text(
            "OR",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/google.png",
                    width: h*0.8,
                    height: h*0.7,
                  ),

                  SizedBox(width:10),

                  Flexible(child: Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width*0.045,
                        overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
