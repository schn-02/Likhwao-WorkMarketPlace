import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeAddressScreen.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeOrderSummaryScreen.dart';
import 'package:likhwao/Model/OrdersDetailsModel.dart';
import 'package:likhwao/Model/UserAddressModel.dart';

import '../../ApiConfig/apiConfig.dart';

class Homescreen4Indexstack extends StatefulWidget {
   final Ordersdetailsmodel order;
  const Homescreen4Indexstack({super.key , required this.order});

  @override
  State<Homescreen4Indexstack> createState() => _Homescreen4IndexstackState();
}

class _Homescreen4IndexstackState extends State<Homescreen4Indexstack> {
  int currentStep = 0;
  bool isLoading =true;
  bool isAddressSaved = false;

  Useraddressmodel? saveAddress;

  @override
  void initState() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    // TODO: implement initState
    super.initState();
    if(userId==null)
      {
        return;
      }
    fetchSavedAddress(userId);

  }




  @override
  Widget build(BuildContext context) {
    Ordersdetailsmodel finalData =widget.order;


    print("DATEE :- ${widget.order.selectedDate}");
    if(isLoading)
      {
        return Scaffold(
          body: Center(child: CircularProgressIndicator(),)
        );
      }
    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Order Summary & Payment",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        backgroundColor: Color(0xFF0B164A),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/HomeScreen3",
                  (route) => false,
            );
          },
          icon: Icon(Icons.arrow_back_outlined, color: Colors.white, size: 20),
        ),
      ),
      body: Card(
          color: Color(0xFF0B164A),
        child: Padding(padding: EdgeInsets.all(10),

           child: Column(
             children: [
               checkoutStepper(currentStep),
               SizedBox(height: 20,),

               Expanded(
                 child:
                 IndexedStack(
                   index: currentStep.clamp(0,isAddressSaved?0:1),
                   children: isAddressSaved
                       ? [
                     // 👉 ONLY Order Summary
                     Homeordersummaryscreen(
                       ordersdetailsmodel: widget.order,
                       onNext: (_) {},
                       onBack: () {},
                     ),
                   ]:

                   [
                     // 👉 Address + Order Summary
                     Homeaddressscreen(
                       ordersdetailsmodel: widget.order,
                       onNext: (updatedModel) {
                         setState(() {
                           finalData= updatedModel;
                           currentStep = 1;
                         });
                       },
                     ),

                     Homeordersummaryscreen(
                       ordersdetailsmodel: widget.order,
                       onNext: (_) {},
                       onBack: () {
                         setState(() => currentStep = 0);
                       },
                     ),
                   ],
                 )
               )
             ],
           )
          )
        ),

    );
  }


  Widget checkoutStepper(int currentStep)
  {
    Widget stepCircle(int step , bool isActive , bool isCompleted)
    {

      return CircleAvatar(
       radius: 14,
        backgroundColor: isCompleted||isActive ? Colors.black :Colors.grey.shade100,
        child: isCompleted ?Icon(Icons.check , size: 16, color: Colors.white) :
        Text(step.toString() , style: TextStyle(
          color: Colors.white , fontSize: 12
        ),)
        ,
      );
    }


    Widget stepLine(bool isCompleted) {
      return Expanded(
        child: Container(
          height: 2,
          color: isCompleted ? Colors.black : Colors.grey.shade400,
        ),
      );
    }


    return Column(

      children: [
        Row(
          children: [
            stepCircle(1, currentStep==0, currentStep>0),
            stepLine(currentStep>0),
            stepCircle(2, currentStep==1, currentStep>1),
            stepLine(currentStep>1),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("ADDRESS" , style:
            TextStyle(color: Colors.white, fontSize: 12,
                fontWeight:FontWeight.bold),overflow: TextOverflow.ellipsis,maxLines:1,),

            Text("ORDER SUMMARY", style:
            TextStyle(color: Colors.white, fontSize: 12,
                fontWeight:FontWeight.bold),overflow: TextOverflow.ellipsis,maxLines:1,),

          ],
        ),
      ],
    );

  }

  Future<void> fetchSavedAddress(String uid) async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.get(
        Uri.parse("${apiConfig.baseUrl}/api/user_side/checkAddress?uid=$uid"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // parse single address object
        Useraddressmodel fetchedAddress = Useraddressmodel.fromJson(data);

        // assign to Ordersdetailsmodel.addressList
        widget.order.addressList = [fetchedAddress]; // wrap in list

        saveAddress = fetchedAddress;
        isAddressSaved = true;
        currentStep = 1;

      } else {
        isAddressSaved = false;
        currentStep = 0;
      }
    } catch (e) {
      isAddressSaved = false;
      currentStep = 0;
    }

    setState(() {
      isLoading = false;
    });
  }



}

