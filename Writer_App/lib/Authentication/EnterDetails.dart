import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Toast/ToastHelper.dart';
import 'AuthBackend.dart';

class EnterDetails extends StatefulWidget {
  const EnterDetails({super.key});

  @override
  State<EnterDetails> createState() => _enterDetailsState();
}

class _enterDetailsState extends State<EnterDetails> {
  String countryCode = "+91";
  String countryName = "India";
  final pickerController = FlCountryCodePicker();
  TextEditingController numberController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableKeyboard = screenHeight - keyboardHeight;
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF02017D), Colors.blue]),
          ),
          child: SafeArea(
            child:SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableKeyboard),
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
                        "ENTER YOURS DETAILS",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        "Your mobile number will use for your email recovery",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),

                     enterNumber(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

    );
  }


  Widget enterNumber() {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.red, width: 1),
        ),
        shadowColor: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Color(0xFF02017D)]),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.03,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row: Country code + Number
              Row(
                children: [
                  Flexible(flex: 2, child: countryCodePicker()),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 5,
                    child: TextField(
                      controller: numberController,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.04,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white10, width: 3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange, width: 3),
                        ),
                        hintText: "Enter your Mobile Number",
                        hintStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12), // spacing

              // Name TextField under the row
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.04,
                ),
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white10, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  hintText: "Enter your Name",
                  hintStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),


              // Continue button
              continueButton(),
            ],
          ),
        ),
      ),
    );
  }

  // country code pick karne ke liye

  Widget countryCodePicker() {
    final h = MediaQuery.of(context).size.height * 0.056;
    final minW = MediaQuery.of(context).size.width * 0.20;
    return GestureDetector(
      onTap: () async {
        final picker = await pickerController.showPicker(context: context);

        if (picker != null) {
          setState(() {
            countryCode = picker.dialCode.toString();
            countryName = picker.name.toString();
          });
        }
      },

      child: Container(
        constraints: BoxConstraints(minWidth: minW),
        height: h,
        padding: EdgeInsets.symmetric(horizontal: h * 0.3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h * 0.25),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              countryCode,
              style: TextStyle(fontSize: h * 0.25, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: h * 0.1),
            Image.asset("assets/images/dropdown.png", height: h * 0.35),
          ],
        ),
      ),
    );
  }


  Widget continueButton() {
    final h = MediaQuery.of(context).size.width*0.13;
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

                ToastHelper.show("Redirecting.." , context);


                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Authbackend(
                  name :nameController.text,
                  countryCode : countryCode,
                  countryName : countryName,
                  phoneNumber : numberController.text,

                )));


              }
              ,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(h*0.20),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize:MediaQuery.of(context).size.width*0.045,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: 10),


        ],
      ),
    );
  }

}
