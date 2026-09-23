import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likhwao/Model/UserAddressModel.dart';

import '../../Model/OrdersDetailsModel.dart';
import '../../Toast/ToastHelper.dart';

class Homeaddressscreen extends StatefulWidget {
  final Ordersdetailsmodel ordersdetailsmodel;
  final Function(Ordersdetailsmodel) onNext;
  const Homeaddressscreen({super.key, required this.onNext, required this.ordersdetailsmodel});

  @override
  State<Homeaddressscreen> createState() => _HomeaddressscreenState();
}

class _HomeaddressscreenState extends State<Homeaddressscreen> {

   String ? selectedSaveAddressAs;


  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressHouseNoController = TextEditingController();
  final TextEditingController localityTownnController = TextEditingController();
  final TextEditingController cityDistrictController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  List<String> saveAddressAsList =[
    "Home" ,"Work" ,"Other"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Contact Details",
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w900
              ),),

            SizedBox(height: 10,),

            TextField(
              controller: fullNameController,
              decoration: InputDecoration(

                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange, width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: "Full Name*",
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  )
              ),
              style: TextStyle(color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),

            SizedBox(height: 10,),

            TextField(
              controller: mobileNumberController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange, width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: "Mobile Number*",
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  )
              ),
              style: TextStyle(color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),

            SizedBox(height: 20,),


            Text("Address", style: TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w900
            ),),


            SizedBox(height: 10,),

            TextField(
              controller: pincodeController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange, width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: "Pincode*",
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  )
              ),
              style: TextStyle(color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),

            SizedBox(height: 20,),

            TextField(
              controller: addressHouseNoController,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange, width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: "Address(House No. ,Building Street Area)*",
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  )
              ),
              style: TextStyle(color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),


            SizedBox(height: 10,),

            TextField(
              controller: localityTownnController,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange, width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: "Locality / Town*",
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  )
              ),
              style: TextStyle(color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),

            SizedBox(height: 10,),


            Row(
              children: [

                Expanded(child:
                TextField(
                  controller: cityDistrictController,

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.deepOrange, width: 2)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12)
                      ),
                      hintText: "City / District*",
                      hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  style: TextStyle(color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900),
                ),
                ),

                SizedBox(width: 10,),

                Expanded(child:

                TextField(
                  controller: stateController,

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.deepOrange, width: 2)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12)
                      ),
                      hintText: "State *",
                      hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  style: TextStyle(color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900),
                ),
                )
              ],
            ),


            SizedBox(height: 20,),


            Text("Save Address As", style: TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w900
            ),),

            SizedBox(height: 10,),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: saveAddressAsList.map((option) {
                    bool isSelected =
                        selectedSaveAddressAs == option;
                    return ChoiceChip(
                      label: Container(
                        constraints: const BoxConstraints(
                          minWidth: 60,
                        ),
                        // Minimum width for chips
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedSaveAddressAs = (selected
                              ? option
                              : null)!;
                        });
                      },
                      selectedColor: Colors.deepOrange,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),

            SizedBox(height: 20,),

             Text("We’ll contact you only if needed" ,style: TextStyle(

               fontSize: 14,
               fontWeight: FontWeight.w900,
               color: Colors.white,
               overflow: TextOverflow.ellipsis
             ),
               maxLines: 2,
               textAlign: TextAlign.center,
             ),

            SizedBox(height: 10,),


            ContinueButton()






          ],
        )
    );
  }


  Widget ContinueButton()
  {
    bool isFormValid = fullNameController.text.isNotEmpty&&
        mobileNumberController.text.isNotEmpty
        && pincodeController.text.isNotEmpty&& addressHouseNoController.text.isNotEmpty
        && localityTownnController.text.isNotEmpty && cityDistrictController.text.isNotEmpty&&
        stateController.text.isNotEmpty&& selectedSaveAddressAs !=null;

    return InkWell(onTap: (){

      print("USERDETAILSMODEL :- ${widget.ordersdetailsmodel.typeOfWork}");

      if(isFormValid)
      {
        Useraddressmodel useraddress = Useraddressmodel(
            fullName: fullNameController.text, mobileNumber: mobileNumberController.text,
            pincode: pincodeController.text, houseNo: addressHouseNoController.text,
            locality: localityTownnController.text, city: cityDistrictController.text,
            state: stateController.text, saveAs: selectedSaveAddressAs,




        );
        widget.ordersdetailsmodel.addressList =[useraddress];
        widget.ordersdetailsmodel.userName =fullNameController.text.toString();
        widget.ordersdetailsmodel.userNumber =mobileNumberController.text.toString();
        print("USERDETAILSMODEL After :-  ${widget.ordersdetailsmodel.addressList}");

        widget.onNext(widget.ordersdetailsmodel);

      }
      else{
        ToastHelper.show("Please Fill all details", context);
        return;
      }

    },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(

            color: isFormValid ? Colors.deepOrange :Color(0xffefac7c), // Button background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Wrap content horizontally
            children: [
              const Text(
                "Continue",
                style: TextStyle(color: Color(0xffFFFFFF),
                    fontSize: 16.0 , fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 8.0), // Spacing between text and image
              // Use Image.asset or Image.network for your image
              Image.asset(
                'assets/images/arrowright.png', // Replace with your image path
                width: 24.0,
                height: 24.0,
                color: Colors.white, // Optional: color the image if it's a generic icon
              ),
            ],
          ),
        )
    );
  }
}
