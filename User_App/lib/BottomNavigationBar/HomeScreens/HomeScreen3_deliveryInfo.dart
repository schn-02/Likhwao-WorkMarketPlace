
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen4_IndexStack.dart';
import 'package:likhwao/Model/OrdersDetailsModel.dart';

import '../../Toast/ToastHelper.dart';

class Homescreen3Deliveryinfo extends StatefulWidget {
  final Ordersdetailsmodel order;
  const Homescreen3Deliveryinfo({super.key , required this.order});

  @override
  State<Homescreen3Deliveryinfo> createState() =>
      _Homescreen3DeliveryinfoState();
}

class _Homescreen3DeliveryinfoState extends State<Homescreen3Deliveryinfo> {
  final DateTime nowCurrentTime = DateTime.now();


  String? workToBeDone = "PDF";
  String? deliveryPickupOption ;
  String? selectedDeadLineUrgency;
  List<String> deadLineUrgencyList = [
    "Normal(2-3 days)",
    "Fast(48 hours)",
    "Urgent(24 hours)",
  ];
  DateTime ? selectedDate;
  late final size = MediaQuery.of(context).size;

  // late final orderdetailsmodel = ModalRoute.of(context)?.settings.arguments as Ordersdetailsmodel;



  Future<void> _selectDate(BuildContext context) async {
    final DateTime minDate =  nowCurrentTime.add(Duration(days: 3));
    final DateTime maxDate = nowCurrentTime.add(Duration(days: 30));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:minDate,
      firstDate: minDate,
      lastDate: maxDate
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    DateTime nextTwoDays = nowCurrentTime.add(Duration(days: 2));
    DateTime nextSameDays = nowCurrentTime.add(Duration(days: 1));
    String formattedDateNextTwoDays = DateFormat('dd MMM yyyy').format(nextTwoDays);
    String formattedDateSameDays = DateFormat('dd MMM yyyy').format(nextSameDays);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Delivery & Timeline",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Color(0xFF0B164A),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/HomeScreen2",
              (route) => false,
            );
          },
          icon: Icon(Icons.arrow_back_outlined, color: Colors.white, size: 20),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            borderOnForeground: true,
            color: Color(0xFF0B164A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(12),
            ),
            elevation: 20,
            shadowColor: Colors.deepOrange,

            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Tell us when you need it",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Card(
                      elevation: 15,
                      shadowColor: Colors.deepOrange.withOpacity(0.8),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "How do you want your work to be done ?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),

                          Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(unselectedWidgetColor: Colors.black),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text(
                                    "PDF Only(Digital)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  value: "PDF",
                                  groupValue: workToBeDone,
                                  activeColor: Colors.deepOrange,
                                  // Select hone par color
                                  onChanged: (value) {
                                    setState(() {
                                      workToBeDone = value;
                                    });
                                  },
                                ),

                                RadioListTile<String>(
                                  title: const Text(
                                    "Use My Notebook (Pickup required)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    maxLines: 2,
                                  ),
                                  value: "My_Notebook",
                                  groupValue: workToBeDone,
                                  activeColor: Colors.deepOrange,
                                  onChanged: (value) {
                                    setState(() {
                                      workToBeDone = value;
                                    });
                                  },
                                ),

                                RadioListTile<String>(
                                  title: const Text(
                                    "Company will provide new notebook (Extra charges may apply)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    maxLines: 3,
                                  ),
                                  value: "Company_Notebook",
                                  groupValue: workToBeDone,
                                  activeColor: Colors.deepOrange,
                                  onChanged: (value) {
                                    setState(() {
                                      workToBeDone = value;
                                    });
                                  },
                                ),


                                SizedBox(height: 10,),
                                const Text(
                                  "When do you need it?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 15),
                                // Wrap ko use karke chips ko manage kiya
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: deadLineUrgencyList.map((option) {
                                    bool isSelected =
                                        selectedDeadLineUrgency == option;
                                    return ChoiceChip(
                                      label: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 100,
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
                                          selectedDeadLineUrgency = selected
                                              ? option
                                              : null;
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),


                  
                  if(selectedDeadLineUrgency =="Normal(2-3 days)")
                    DatePickerWidget()
                  
                  else if(selectedDeadLineUrgency=="Fast(48 hours)")
                    Text("Expected Delivery : $formattedDateNextTwoDays \n Extra charges may apply" , style: TextStyle(
                      color: Colors.green , fontSize: 15, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis
                    ),
                    maxLines: 1, textAlign: TextAlign.center,)

                  else if(selectedDeadLineUrgency=="Urgent(24 hours)")
                  Text("Expected Delivery : $formattedDateSameDays \n Extra charges may apply" , style: TextStyle(
                  color: Colors.green , fontSize: 15, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis
                  ),
                  maxLines: 1, textAlign: TextAlign.center,),


                  SizedBox(height: 10),

                  if(workToBeDone=="My_Notebook")
                    Padding(
                    padding: EdgeInsets.all(5),
                    child: Card(
                      elevation: 15,
                      shadowColor: Colors.deepOrange.withOpacity(0.8),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Do you want notebook pickup?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),

                          Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(unselectedWidgetColor: Colors.black),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text(
                                    "Yes, the writer will need to pick up the materials (additional charges may apply).",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    maxLines: 5,
                                  ),
                                  value: "Required_Delivery",
                                  groupValue: deliveryPickupOption,
                                  activeColor: Colors.deepOrange,
                                  // Select hone par color
                                  onChanged: (value) {
                                    setState(() {
                                      deliveryPickupOption = value;
                                    });
                                  },
                                ),

                                RadioListTile<String>(
                                  title: const Text(
                                    "No,I’ll deliver myself",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    maxLines: 2,
                                  ),
                                  value: "Self_Delivery",
                                  groupValue: deliveryPickupOption,
                                  activeColor: Colors.deepOrange,
                                  onChanged: (value) {
                                    setState(() {
                                      deliveryPickupOption = value;
                                    });
                                  },
                                ),


                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),






                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),child:
      ContinueButton()
        ,
      ),
    );
  }



  Widget _buildStyledCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(padding: const EdgeInsets.all(15), child: child),
      ),
    );
  }


  Widget ContinueButton()
  {



    return InkWell(onTap: (){

      DateTime nextTwoDays = nowCurrentTime.add(Duration(days: 2));
      DateTime nextSameDays = nowCurrentTime.add(Duration(days: 1));


      widget.order.deliveryPickupOption = deliveryPickupOption ?? "NA";
      widget.order.workToBeDone = workToBeDone;
      if(selectedDeadLineUrgency=="Fast(48 hours)")
        {
          widget.order.selectedDeadLineUrgency ="FAST";
          widget.order.selectedDate =nextTwoDays;
        }
      else if(selectedDeadLineUrgency=="Urgent(24 hours)")
        {
          widget.order.selectedDeadLineUrgency ="URGENT";
          widget.order.selectedDate =nextSameDays;
        }
      else{
        widget.order.selectedDeadLineUrgency ="NORMAL";
        widget.order.selectedDate =selectedDate;
      }


      if(isFormValid())
      {

        widget.order.noteBookChargesAmount =widget.order.workToBeDone =="Company_Notebook" ?60 :0;
        int pageBaseAmount = (widget.order.userFilePageCount ?? 0) * 5;

        int urgencyCharge = 0;
        int urgencyMultiplier = 1;

        if (widget.order.selectedDeadLineUrgency =="FAST") {
          urgencyMultiplier = 2;
        } else if (widget.order.selectedDeadLineUrgency =="URGENT") {
          urgencyMultiplier = 3;
        }

        if (urgencyMultiplier > 1) {
          urgencyCharge = pageBaseAmount * (urgencyMultiplier - 1);
        }

        widget.order.orderPageCountAmount = pageBaseAmount;
        widget.order.urgencyAmount = urgencyCharge;



        if(widget.order.workToBeDone =="PDF" ||
            widget.order.deliveryPickupOption =="Self_Delivery")
          {
            widget.order.deliveryChargesAmount = 0;
          }
        else{
          widget.order.deliveryChargesAmount =100;
        }





        widget.order.platformFeeAmount =10;


        widget.order.totalOrderAmount =
            pageBaseAmount +
                urgencyCharge +
                (widget.order.deliveryChargesAmount ?? 0) +
                (widget.order.platformFeeAmount ?? 0) +
                (widget.order.noteBookChargesAmount ?? 0);
        ;

        final userUid = FirebaseAuth.instance.currentUser?.uid;
        if(userUid==null)
          {
            return;
          }




        ToastHelper.show("Redirecting..", context);

        Navigator.push(context, MaterialPageRoute(builder: (context)=>
        Homescreen4Indexstack(order:widget.order)));
          return;


      }
      else{
        ToastHelper.show("Please Fill all details", context);
        return;
      }

    },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(

            color: isFormValid() ? Colors.deepOrange :Color(0xffefac7c), // Button background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Wrap content horizontally
            children: [
              const Text(
                "CONTINUE",
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
  bool isFormValid() {

    // 1. Urgency check
    if (selectedDeadLineUrgency == null) {

      return false;
    }

    // 2. Normal case → date required
    if (selectedDeadLineUrgency =="NORMAL") {
      if (selectedDate == null) {
        return false;
      }
    }

    // 3. Notebook case → pickup option required
    if (workToBeDone == "My_Notebook") {
      if (deliveryPickupOption == null) {

        return false;
      }
    }

    return true;
  }






  Widget DatePickerWidget() {
    return _buildStyledCard(
      child: Column(
        children: [
          const Text("Select preferred delivery date",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis),maxLines: 1,),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepOrange),
                borderRadius: BorderRadius.circular(10),
                color: Colors.deepOrange.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? "Choose Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.calendar_month, color: Colors.deepOrange),
                ],
              ),
            ),
          ),
        ],
      ),
    );


}
}


