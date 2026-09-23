import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Otp_Ui extends StatefulWidget {
  const Otp_Ui({super.key});

  @override
  State<Otp_Ui> createState() => _LoginBackendState();
}

class _LoginBackendState extends State<Otp_Ui> {
  final List<TextEditingController> _controller = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNode = List.generate(6, (index) => FocusNode());
  late final screenHeight = MediaQuery.of(context).size.height;
  late final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  late  final availableKeyboard = screenHeight - keyboardHeight;

  final fToast = FToast();


  bool isTimeCompleted = false;
  bool isVerifyClicked = false;
  int seconds =30;
  Timer ? timer;
  late final args = ModalRoute.of(context)!.settings.arguments as Map;
   late String countryCode = args["countryCode"];
   late String phoneNumber = args["phoneNumber"];
  late final w = MediaQuery.of(context).size.width;


   String get otpCode{
     return _controller.map((c) => c.text).join();
   }




  @override
  void initState() {
    super.initState();
    startTimer();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.width*0.08;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.red),
        ),
        title: Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.black,
            fontSize: w*0.05,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),

      body:SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
         gradient: LinearGradient(colors: [Colors.white24, Colors.white24]),
        ),
          child: SafeArea(
            child:SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableKeyboard),
                  child: Column(
                    children: [
                      Divider(color: Colors.black),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.12,
                        child:Image.asset(
                          "assets/images/verification.png",
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "OTP verification code sent to",
                        style: TextStyle(
                          fontSize: w*0.04,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign:TextAlign.center,
                      ),

                      InkWell(
                        onTap: ()
                        {
                          Navigator.pushReplacementNamed(context, "/");
                          Navigator.pop(context);
                        },child: Text(
                        "${countryCode} ${phoneNumber} ",
                        style: TextStyle(
                          fontSize: w*0.04,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,

                        ),
                        textAlign:TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        softWrap: true,

                      ),
                      ),



                      SizedBox(height: 10),

                      Text(
                        "Enter your OTP here",
                        style: TextStyle(
                          fontSize: w*0.04,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) => _otpBox(index)),
                      ),

                      SizedBox(height: 20,),
                      SizedBox(
                        width: double.infinity,
                        height:MediaQuery.of(context).size.height*0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            fToast.showToast(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.blue,
                                ),
                                child: const Text(
                                  "Verify OTP Call",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                                gravity: ToastGravity.BOTTOM,
                                toastDuration: const Duration(seconds: 2),
                              );

                            setState(() {
                              isVerifyClicked = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child:VerifyLoader()
                              ),

                              if(!isVerifyClicked)
                              Image.asset(
                                "assets/images/next.png",
                                width: h*0.9,
                                height: h*0.9,
                              ),

                              SizedBox(width:10),



                            ],
                          ),
                        ),
                      ),



                      SizedBox(height: 20),

                      Text(
                        "Didn't receive any code ?",
                        style: TextStyle(
                          fontSize:w*0.03,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      InkWell(onTap: () {
                        setState(() {
                          isTimeCompleted = false;
                          seconds =30;
                        });
                        startTimer();
                      }, child: resendWidget()),
                    ],
                  ),

                ),
              ),

            ),
          ),
        )

    );
  }

  Widget resendWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isTimeCompleted)
          Text(
            "Resend new code",
            style: TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),

           if(!isTimeCompleted)
             Text("00:${seconds.toString().padLeft(2,'0')}",
               style: TextStyle(fontSize: 20 ,
                   fontWeight: FontWeight.bold,
                 color:  Colors.red
               ),
             ),
      ],
    );
  }

  void startTimer()
  {

    timer = Timer.periodic(Duration(seconds:1),(t)
        {
          if(seconds ==0)
            {
              t.cancel();
              setState(() {
                isTimeCompleted =true;

              });
            }
          else{
            setState(() {
              seconds--;
            });
          }


        });
    setState(() {
      //for ui refersh  immediately
    });
  }

  Widget _otpBox(int index) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4), // small spacing
        child: TextField(
          controller: _controller[index],
          focusNode: _focusNode[index],
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.07, // responsive
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          decoration: InputDecoration(
            counterText: "",
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).requestFocus(_focusNode[index + 1]);
            }
            if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(_focusNode[index - 1]);
            }
          },
        ),
      ),
    );
  }

  Widget VerifyLoader()
  {
    return Stack(

      children: [
        if(!isVerifyClicked)
          Text(
            "Verify",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize:
              MediaQuery.of(context).size.width*0.045,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
          ),

        if(isVerifyClicked)
          SizedBox(
            width: w*0.06,
            height: w*0.06,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.black,
            ),
          )
      ],
    );
  }


}
