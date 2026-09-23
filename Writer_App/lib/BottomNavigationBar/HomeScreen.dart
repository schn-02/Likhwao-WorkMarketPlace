
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {


  @override
  Widget build(BuildContext context) {
    late final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: Color(0xffF5F7FA),
      appBar: AppBar(
        title: Text(
          "HOME",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xFF0B164A),

        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.home, color: Colors.black),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.all(2),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color(0xFF0B164A),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.01),

                    Lottie.asset(
                      "assets/animation/homeAnimation.json",
                      height: size.height * 0.15,
                      alignment: Alignment.center,
                      animate: true,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),

                    Text(
                      "Get Your Handwritten Assignment Done", style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ), textAlign: TextAlign.center, softWrap: true, maxLines: 2
                      ,),

                    const SizedBox(height: 10),


                    ContinueButton(),


                    const SizedBox(height: 10),


                    const SizedBox(height: 10),
                    // ... (baaki code same rahega)

                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Pehla Step: Check Image + Dot

                            SizedBox(
                              width: 65,
                              child:
                              Column(
                                children: [
                                  Image.asset(
                                      "assets/images/check.png", height: 32),
                                  const SizedBox(height: 8),
                                  trackingName("Verify"),
                                ],
                              ),
                            ),
                            // Line 1
                            trackingLine(),

                            // Doosra Step: Secure Image + Dot
                            SizedBox(
                              width: 65,
                              child:
                              Column(
                                children: [
                                  Image.asset(
                                      "assets/images/secure.png", height: 32),
                                  const SizedBox(height: 8),
                                  trackingName("Secure"),
                                ],
                              ),
                            ),

                            // Line 2
                            trackingLine(),

                            // Teesra Step: Delivery Image + Dot
                            SizedBox(
                              width: 65,
                              child:
                              Column(
                                children: [
                                  Image.asset("assets/images/deliveryman.png",
                                      height: 32),
                                  const SizedBox(height: 8),
                                  trackingName("Delivery"),
                                ],
                              ),
                            )
                          ],
                        )
                    ),


                    SizedBox(height: 10,),


                    SizedBox(height: 10,),

                    TrustSaftey(),


                    SizedBox(height: 10,),


                    HowItWorks(),

                    SizedBox(height: 10),


                    SizedBox(height: 10),


                  ],
                ),
              ),
            )
        ),
      ),
    );
  }

  Widget trackingName(String name) {
    return Text("$name", style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white,
        overflow: TextOverflow.ellipsis

    ), textAlign: TextAlign.center,
      maxLines: 2,
    );
  }

  Widget trackingLine() {
    return Expanded(

      child: Container(
        margin: EdgeInsets.only(top: 15, left: 4, right: 4),
        height: 2.5,
        color: Colors.green,
      ),
    );
  }


  Widget HowItWorks() {
    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10)),
        shadowColor: Colors.yellow,

        child: Padding(
          padding: EdgeInsetsGeometry.all(10),


          child: Column(


            children: [


              Text("HOW IT WORKS", style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff01F702),
                  overflow: TextOverflow.ellipsis

              ), textAlign: TextAlign.center,
                maxLines: 2,),
              Row(
                children: [
                  Image.asset("assets/images/number1.png", height: 25),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Text("Submit your requirement", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis

                  ), textAlign: TextAlign.start,
                    maxLines: 2,),
                  )
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Image.asset("assets/images/number2.png", height: 25),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Text("Writer accepts your request", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis

                  ), textAlign: TextAlign.start,
                    maxLines: 2,),
                  )
                ],
              ),
              SizedBox(height: 10,),

              Row(
                children: [
                  Image.asset("assets/images/number3.png", height: 25),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Text("Notebook delivered to you", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis

                  ), textAlign: TextAlign.start,
                    maxLines: 2,),
                  )
                ],
              )
            ],
          ),
        )
    );
  }

  Widget TrustSaftey() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10)),
      shadowColor: Colors.yellow,
      color: Colors.white,

      child: Padding(
          padding: EdgeInsetsGeometry.all(6),

          child: Column(
            children: [

              Text("TRUST & SAFETY ", style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff01F702),
                  overflow: TextOverflow.ellipsis

              ), textAlign: TextAlign.center,
                maxLines: 2,),
              Row(
                children: [
                  Image.asset("assets/images/lock.png", height: 25),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Text("Escrow payment protection", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis

                  ), textAlign: TextAlign.start,
                    maxLines: 2,),
                  )
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Image.asset("assets/images/verified.png", height: 25),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Text("Verified handwriting experts", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis

                  ), textAlign: TextAlign.start,
                    maxLines: 2,),
                  )
                ],
              ),
              SizedBox(height: 10,),

              Row(
                children: [
                  Image.asset("assets/images/cashOnDelivery.png", height: 25),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Text("Same-day pickup available", style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis

                  ), textAlign: TextAlign.start,
                    maxLines: 2,),
                  )
                ],
              )
            ],
          )
      ),
    );
  }

  Widget ContinueButton() {
    return InkWell(onTap: () {
      Navigator.pushNamed(context, "/HomeScreen2");
    },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Color(0xffFF6A00), // Button background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Wrap content horizontally
            children: [
              const Text(
                "Create Request",
                style: TextStyle(color: Color(0xffFFFFFF),
                    fontSize: 16.0, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 8.0), // Spacing between text and image
              // Use Image.asset or Image.network for your image
              Image.asset(
                'assets/images/arrowright.png', // Replace with your image path
                width: 24.0,
                height: 24.0,
                color: Colors
                    .white, // Optional: color the image if it's a generic icon
              ),
            ],
          ),
        )
    );
  }


}