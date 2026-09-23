import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:likhwao/Model/OrdersDetailsModel.dart';
import 'package:likhwao/Model/UserAddressModel.dart';
import 'package:likhwao/Provider/ChatListProvider.dart';
import 'package:likhwao/SplashScreens/PaymentSuccessSplash.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../ApiConfig/apiConfig.dart';
import '../../Model/CreateOrderResponse.dart';

class Homeordersummaryscreen extends StatefulWidget {
  final Ordersdetailsmodel ordersdetailsmodel;

  final Function(Ordersdetailsmodel) onNext;
  final VoidCallback onBack;

  const Homeordersummaryscreen({
    super.key,
    required this.ordersdetailsmodel,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Homeordersummaryscreen> createState() => _HomeordersummaryscreenState();
}

class _HomeordersummaryscreenState extends State<Homeordersummaryscreen> {
  late Razorpay razorpay;
  bool isLoading = false;
  bool isWriterFound = false;
  late var orderId = -1;
  StreamSubscription? orderListner;
  List<String> writerAvatars = [
    "assets/images/avatar1.png",
    "assets/images/avatar2.png",
    "assets/images/avatar3.png",
    "assets/images/avatar4.png",
    "assets/images/avatar5.png",
    "assets/images/avatar6.png",
    "assets/images/avatar1.png",
    "assets/images/avatar2.png",
    "assets/images/avatar3.png",
    "assets/images/avatar4.png",
    "assets/images/avatar5.png",
    "assets/images/avatar6.png",
    "assets/images/avatar1.png",
    "assets/images/avatar2.png",
    "assets/images/avatar3.png",
    "assets/images/avatar4.png",
    "assets/images/avatar5.png",
    "assets/images/avatar6.png",
    "assets/images/avatar1.png",
    "assets/images/avatar2.png",
    "assets/images/avatar3.png",
    "assets/images/avatar4.png",
    "assets/images/avatar5.png",
    "assets/images/avatar6.png",
    "assets/images/avatar1.png",
    "assets/images/avatar2.png",
    "assets/images/avatar3.png",
    "assets/images/avatar4.png",
    "assets/images/avatar5.png",
    "assets/images/avatar6.png",
  ];

  int currentIndex = 0;

  ScrollController scrollController = ScrollController();
  Timer? scrollTimer;

  void startVerticalScroll() {
    scrollTimer?.cancel();

    scrollTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
          scrollController.offset + 25, // speed control
        );

        // loop effect
        if (scrollController.offset >=
            scrollController.position.maxScrollExtent) {
          scrollController.jumpTo(0);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
    orderListner?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    orderSummary(),

                    Card(
                      child: Column(
                        children: [
                          Text(
                            "Payment Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),

                          paymentDetails(
                            "Page Charges",
                            "₹ ${(widget.ordersdetailsmodel.userFilePageCount ?? 0) * 5}",
                          ),

                          if (widget
                                  .ordersdetailsmodel
                                  .selectedDeadLineUrgency !=
                              "NORMAL")
                            paymentDetails(
                              "Urgency Charges",
                              "₹ ${widget.ordersdetailsmodel.urgencyAmount}",
                            ),

                          if ((widget
                                      .ordersdetailsmodel
                                      .noteBookChargesAmount ??
                                  0) >
                              0)
                            paymentDetails(
                              "Company Notebook Charges",
                              "₹ ${widget.ordersdetailsmodel.noteBookChargesAmount}",
                            ),

                          if ((widget
                                      .ordersdetailsmodel
                                      .deliveryChargesAmount ??
                                  0) >
                              0)
                            paymentDetails(
                              "Delivery Charges",
                              "₹ ${widget.ordersdetailsmodel.deliveryChargesAmount}",
                            ),

                          paymentDetails(
                            "Platform Fee",
                            "₹ ${widget.ordersdetailsmodel.platformFeeAmount}",
                          ),

                          Divider(color: Colors.black, indent: 10),

                          paymentDetails(
                            "Total Payable Amount",
                            "₹ ${widget.ordersdetailsmodel.totalOrderAmount ?? 0}",
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "Payments are 100% safe & encrypted",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff04243F),
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),

                    if (isWriterFound && !isLoading) writerDetailsCard(),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white54,
                // dim effect
                child: Center(child: findingWriterUI()),
              ),
            ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: findWriterButton(),
      ),
    );
  }

  Widget findingWriterUI() {
    if (isWriterFound == false) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Card(
          elevation: 10,
          shadowColor: Colors.yellow,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage(
                              "assets/images/user.png",
                            ),
                          ),
                          SizedBox(height: 5),

                          Text(
                            "You",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 20),

                      Text(
                        "VS",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(width: 20),

                      Column(
                        children: [
                          SizedBox(
                            height: 80,
                            width: 120,
                            child: ListView.builder(
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              itemCount: writerAvatars.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundImage: AssetImage(
                                      writerAvatars[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 5),

                          Text(
                            "Finding...",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      deleteOrder();
                      setState(() {
                        isWriterFound = true;
                        isLoading = false;
                      });
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget findWriterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isLoading
          ? null
          : () async {
              setState(() {
                isLoading = true;
              });

              try {
                if (!isWriterFound && isLoading) {
                  startVerticalScroll();
                  await saveOrderApi();
                } else if (widget.ordersdetailsmodel.writerAssignmentStatus ==
                    "ACCEPTED") {
                  onPayNowClicked();
                }

                listenerForWriter(
                  widget.ordersdetailsmodel.UserOrderId.toString(),
                );
              } catch (e) {
                setState(() {
                  isLoading = false;
                  isWriterFound = false;
                });
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.ordersdetailsmodel.writerAssignmentStatus == "ACCEPTED"
                ? "Proceed to secure payment"
                : widget.ordersdetailsmodel.writerAssignmentStatus ==
                      "CANCELLED"
                ? "Retry !"
                : "Find Writer ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6),

          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
        ],
      ),
    );
  }

  void listenerForWriter(String orderId) {
    orderListner = FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) {
            return;
          }
          final data = snapshot.data();
          if (data?['status'] == "ACCEPTED") {
            setState(() {
              isWriterFound = true;
              isLoading = false;

              widget.ordersdetailsmodel.writerId = data?['writerId'];
              widget.ordersdetailsmodel.writerName = data?['writerName'];
              widget.ordersdetailsmodel.writerAssignmentStatus =
                  data?['status'];
            });
          } else if (data?['status'] == "CANCELLED") {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  Widget orderSummary() {
    String? typeOfWork = widget.ordersdetailsmodel.typeOfWork.toString();
    String? fileName = widget.ordersdetailsmodel.userFileName.toString();
    String? pageCount = widget.ordersdetailsmodel.userFilePageCount.toString();
    String? inkColour = widget.ordersdetailsmodel.selectedInkColor.toString();
    DateTime? deadlineDate = widget.ordersdetailsmodel.selectedDate;
    String? deadlineText = deadlineDate != null
        ? DateFormat('dd MMMM yyyy').format(deadlineDate)
        : "Not selected";
    String? selectedNotebook = widget.ordersdetailsmodel.selectedNotebook
        .toString();
    String? deliveryOption = widget.ordersdetailsmodel.workToBeDone.toString();

    String? deliveryPickupOption =
        widget.ordersdetailsmodel.workToBeDone == "My_Notebook" ? "YES" : "NO";
    String? deliveryUrgency = widget.ordersdetailsmodel.selectedDeadLineUrgency
        .toString();

    List<Useraddressmodel>? pickupAddress =
        widget.ordersdetailsmodel.addressList;
    String? name = pickupAddress?[0].fullName.toString();
    String? number = pickupAddress?[0].mobileNumber.toString();

    return Card(
      color: Colors.white54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ExpansionTile(
        title: Text(
          "Order Summary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Type of Work :-  $typeOfWork"),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _row("Name ", name!),
          _row("Mobile number ", number!),
          _row("File Name ", fileName),
          _row("Urgency ", deliveryUrgency),
          _row("Page Count", pageCount),
          _row("Deadline", deadlineText),
          _row("Ink Colour", inkColour),
          _row("Selected Notebook ", selectedNotebook),
          _row("Delivery Option", deliveryOption),
          _row("Delivery Required", deliveryPickupOption),

          addressCard(pickupAddress!),
        ],
      ),
    );
  }

  Widget _row(String title, String? value, {bool isBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT TITLE
          Expanded(
            flex: 4,
            child: Text(title, style: const TextStyle(color: Colors.black54)),
          ),

          // RIGHT VALUE
          Expanded(
            flex: 6,
            child: Text(
              value ?? "-",
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addressCard(List<Useraddressmodel> pickupAddress) {
    return Card(
      elevation: 5,
      color: Colors.white54,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${pickupAddress[0].saveAs} Address",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            Text(
              "${pickupAddress[0].houseNo} , ${pickupAddress[0].locality},"
              "${pickupAddress[0].city} , ${pickupAddress[0].state} , ${pickupAddress[0].pincode}",
              style: TextStyle(fontSize: 12, color: Colors.black),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentDetails(String title, String value, {bool isBold = true}) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),

              // RIGHT VALUE
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<CreateOrderResponse> createPaymentOrderApi() async {
    final url = Uri.parse(
      "${apiConfig.baseUrl} /api/user_side/orders/createPayment?orderId=${widget.ordersdetailsmodel.UserOrderId}",
    );
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final token = await user.getIdToken();

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Successfully  data stored");

      var data = jsonDecode(response.body);

      return CreateOrderResponse.fromJson(data);
    } else {
      throw Exception("Order creation failed: ${response.body}");
    }
  }

  Future<void> saveOrderApi() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      final user = FirebaseAuth.instance.currentUser;
      
      print("user :- ${user}");

      if (user == null) {
        print("USER NULL");
        return;
      }

      widget.ordersdetailsmodel.userFirebaseUid = userUid;
      widget.ordersdetailsmodel.writerAssignmentStatus = "FINDING_WRITER";

      final token = await user.getIdToken(true);

      final body = jsonEncode(widget.ordersdetailsmodel.toJson());

      print("PAGE COUNT = ${widget.ordersdetailsmodel.userFilePageCount}");
      print("BODY = $body");

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/orders/create",
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("STATUS CODE = ${response.statusCode}");
      print("RESPONSE BODY = ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final orderId = data['orderId'];
        widget.ordersdetailsmodel.UserOrderId = orderId;

        final fileUrl = await uploadFile(orderId);

        if (fileUrl == null) {
          throw Exception("File upload failed");
        }

        widget.ordersdetailsmodel.userFileUrl = fileUrl;
      } else {
        throw Exception("Order creation failed: ${response.body}");
      }
    } catch (e) {
      print("SAVE ORDER ERROR = $e");
    }
  }
  Future<String?> uploadFile(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);
    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/user_side/orders/uploadFile/$orderId",
    );
    var request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = 'Bearer $token';

    if (widget.ordersdetailsmodel.selectedPdfFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          widget.ordersdetailsmodel.selectedPdfFile!.path,
        ),
      );
    } else {
      print("No file selected");
      return null;
    }

    var response = await request.send();
    final res = await response.stream.bytesToString();
    print("Upload response: $res");
    if (response.statusCode == 200) {
      final data = jsonDecode(res);
      return data['downloadUrl'];
    } else {
      print("File upload failed: $res");
      return null;
    }
  }

  void onPayNowClicked() async {
    try {
      CreateOrderResponse orderResponse = await createPaymentOrderApi();

      openCheckout(orderResponse.razorpayOrderId, orderResponse.amount);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong")));
      print("ERROR:-$e");
    }
  }

  Future<void> deleteOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/user_side/orders/delete?orderId=${widget.ordersdetailsmodel.UserOrderId}",
    );
    final response = await http.post(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      print("Successfully deleted");
    }
  }

  void openCheckout(String orderId, int amount) {
    var options = {
      'key': const String.fromEnvironment('RAZORPAY_KEY_ID'),
      'order_id': orderId, // 🔥 backend se aaya
      'amount': amount, // 🔥 backend calculated (paise)
      'currency': 'INR',
      'name': 'Likhwao',
      'description': 'Notebook Writing Order',
      'prefill': {'contact': '9784329023', 'email': 'robbinhood846@gmail.com'},
      'theme': {'color': '#3399cc'},
    };

    razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      isLoading = false;
    });
    try {
      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/orders/verifyPayment",
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      final token = await user.getIdToken();

      final apiResponse = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "razorpayPaymentId": response.paymentId,
          "razorpayOrderId": response.orderId,
          "razorpaySignature": response.signature,
        }),
      );

      print("Status code: ${apiResponse.statusCode}");
      print("Response body: ${apiResponse.body}");

      if (apiResponse.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Payment Verified ✅")));

        context.read<Chatlistprovider>().triggerRefresh();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PaymentSuccessSplash()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Payment verification failed ")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error during verification")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isLoading = false;
    });
    debugPrint("Payment Failed: ${response.message}");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Payment Failed")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isLoading = false;
    });
    debugPrint("External Wallet: ${response.walletName}");
  }

  Widget writerDetailsCard() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 20,
        shadowColor: Colors.yellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/user.png",
                      width: 50,
                      height: 50,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        widget.ordersdetailsmodel.writerName ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/star.png",
                          width: 10,
                          height: 10,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "4.7",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    Text(
                      "ORDER STATUS : ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Spacer(),

                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.green),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            widget.ordersdetailsmodel.writerAssignmentStatus ??
                                "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
