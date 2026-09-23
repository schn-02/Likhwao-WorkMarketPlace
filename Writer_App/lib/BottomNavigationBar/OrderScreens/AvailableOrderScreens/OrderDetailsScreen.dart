import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/OrdersScreen.dart';
import 'package:likho/Model/OrdersDetailsModel.dart';
import 'package:likho/PdfPreviewScreenFromDB.dart';
import 'package:likho/Toast/ToastHelper.dart';

class OrderDetailsScreen extends StatefulWidget {
  // final Ordersdetailsmodel order;
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  bool isActionLoading = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ordersdetailsmodel>(
      future: fetchAvailableOrderById(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: CircularProgressIndicator(
                color: purpleColor,
              ),
            ),
          );
        }

        if (snapshot.hasError) {

          print("ERROR :-- ${snapshot.error}");
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Text(
                  "Error while loading order details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }

        final order = snapshot.data!;


        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                topOrderDetailsHeader(order),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
                    child: Column(
                      children: [
                        UserDetailsCard(order),
                        orderSummaryDetails(order),
                        writerSuggestionText(order),
                        attacments(order),
                        timeInfo(order),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: bottomActionBar(order),
        );
      },
    );
  }

  Widget topOrderDetailsHeader(Ordersdetailsmodel order) {

    print("DATA ORDER  ::_  ${order.userFilePageCount}");

    String title = order.typeOfWork ?? "Order Details";
    String earning =
        "₹${((order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0)).toString()}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalizeText(title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Order #${order.UserOrderId ?? widget.orderId} • Available",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  ToastHelper.show("Earning details", context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F8EF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    earning,
                    style: Colors.green.shade700 == null
                        ? const TextStyle()
                        : TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomActionBar(Ordersdetailsmodel order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: isActionLoading
                      ? null
                      : () {
                    showRejectConfirmDialog(order);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                  ),
                  label: const Text("Reject"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(
                      color: Colors.red.shade300,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isActionLoading
                      ? null
                      : () {
                    showAcceptConfirmDialog(order);
                  },
                  icon: isActionLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(isActionLoading ? "Please wait" : "Accept Order"),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: purpleColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAcceptConfirmDialog(Ordersdetailsmodel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            "Accept this order?",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "After accepting, this order will move to your in-progress section.",
            style: TextStyle(
              color: primaryColor.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                String? uid = FirebaseAuth.instance.currentUser?.uid;

                Ordersdetailsmodel od = Ordersdetailsmodel(
                  writerAssignmentStatus: "ACCEPT",
                  UserOrderId: order.UserOrderId,
                  writerFirebaseUid: uid,
                );

                acceptOrReject(od);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                "Accept",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showRejectConfirmDialog(Ordersdetailsmodel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            "Reject this order?",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "This order will stay available for other writers.",
            style: TextStyle(
              color: primaryColor.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                String? uid = FirebaseAuth.instance.currentUser?.uid;

                Ordersdetailsmodel od = Ordersdetailsmodel(
                  writerAssignmentStatus: "REJECT",
                  UserOrderId: order.UserOrderId,
                  writerFirebaseUid: uid,
                );

                acceptOrReject(od);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                "Reject",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget UserDetailsCard(Ordersdetailsmodel order) {
    return sectionCard(
      title: "USER DETAILS",
      icon: Icons.person_rounded,
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  ToastHelper.show("User profile click", context);
                },
                child: Container(
                  height: 58,
                  width: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: purpleColor,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  children: [
                    buildUserDetailsRow(
                      Icons.badge_outlined,
                      "Name",
                      order.fullName,
                    ),
                    const SizedBox(height: 10),
                    buildUserDetailsRow(
                      Icons.phone_rounded,
                      "Phone",
                      maskedPhoneNumber(order.mobileNumber.toString()),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          clickableInfoBox(
            icon: Icons.location_on_outlined,
            title: "Address",
            value: order.deliveryAddress ?? "Null",
            onTap: () {
              ToastHelper.show("Address clicked", context);
            },
          ),
        ],
      ),
    );
  }

  String maskedPhoneNumber(String phone) {
    if (phone.length <= 4) {
      return phone;
    }

    String start = phone.substring(0, 2);
    String end = phone.substring(phone.length - 2);
    String masked = "*" * (phone.length - 4);

    return "$start$masked$end";
  }

  Widget buildUserDetailsRow(
      IconData icon,
      String label,
      String? value,
      ) {

    print("LLALA ::-   ${value}");
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ToastHelper.show("$label clicked", context);
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryColor.withOpacity(0.6),
            size: 19,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: TextStyle(
                color: primaryColor.withOpacity(0.55),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget orderSummaryDetails(Ordersdetailsmodel order) {
    String formatDate = order.selectedDate != null
        ? DateFormat("dd MMM yyyy").format(order.selectedDate!)
        : "null";

    return sectionCard(
      title: "ORDER SUMMARY",
      icon: Icons.assignment_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  Icons.work_outline_rounded,
                  "Work Type",
                  order.typeOfWork,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  Icons.currency_rupee_rounded,
                  "Earning",
                  "₹${((order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0)).toString()}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  Icons.language_rounded,
                  "Language",
                  order.languageSelectedChips,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  Icons.water_drop_outlined,
                  "Ink Color",
                  order.selectedInkColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  Icons.description_outlined,
                  "Page Count",
                  order.userFilePageCount != null
                      ? order.userFilePageCount.toString()
                      : "-1",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  Icons.calendar_month_rounded,
                  "Deadline",
                  formatDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOrderSummaryDetailsRow(
      IconData icon,
      String label,
      String? value,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        ToastHelper.show("$label clicked", context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: purpleColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? "null",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget attacments(Ordersdetailsmodel order) {
    return sectionCard(
      title: "ATTACHMENTS",
      icon: Icons.attach_file_rounded,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await openPdfFile(order);
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE9EC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.red.shade600,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.userFileName ?? "user_file.pdf",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "PDF Attachment",
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () async {
                  await openPdfFile(order);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: purpleColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "View",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
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
    );
  }

  Future<void> openPdfFile(Ordersdetailsmodel order) async {
    final signedUrl = await getUserFileSignedUrl(order.UserOrderId!);
    final fileName = order.userFileName.toString();

    if (signedUrl == null || signedUrl.isEmpty) {
      print("PDF URL NULL hai");
      ToastHelper.show("File url is null", context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Pdfpreviewscreenfromdb(
          fileUrl: signedUrl,
          fileName: fileName,
        ),
      ),
    );
  }

  Widget timeInfo(Ordersdetailsmodel order) {
    DateTime now = DateTime.now();
    DateTime? selectedDate = DateTime.tryParse(order.selectedDate?.toString() ?? "");

    String remainingTime = "";

    String formattedDate = order.orderCreatedAt != null
        ? DateFormat("hh:mm a, dd MMM yyyy").format(order.orderCreatedAt!)
        : "null";

    if (selectedDate != null) {
      Duration diff = selectedDate.difference(now);

      if (diff.isNegative) {
        remainingTime = "Expired";
      } else {
        int days = diff.inDays;
        int hours = diff.inHours % 24;

        remainingTime = "$days days $hours hours left";
      }
    } else {
      remainingTime = "Invalid Date";
    }

    return sectionCard(
      title: "TIME INFORMATION",
      icon: Icons.schedule_rounded,
      child: Column(
        children: [
          buildTimeInfoDetailsRow(
            Icons.event_available_rounded,
            "Order Placed",
            formattedDate,
          ),
          const SizedBox(height: 12),
          buildTimeInfoDetailsRow(
            Icons.timer_outlined,
            "Remaining",
            remainingTime,
          ),
        ],
      ),
    );
  }

  Widget buildTimeInfoDetailsRow(
      IconData icon,
      String label,
      String? value,
      ) {
    bool isExpired = (value ?? "").toLowerCase().contains("expired");

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        ToastHelper.show("$label clicked", context);
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.13),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isExpired ? Colors.red.shade600 : purpleColor,
              size: 21,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.58),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value ?? "null",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isExpired ? Colors.red.shade600 : primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget writerSuggestionText(Ordersdetailsmodel order) {
    return sectionCard(
      title: "WORK SUGGESTION",
      icon: Icons.edit_note_rounded,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ToastHelper.show("Suggestion clicked", context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.13),
            ),
          ),
          child: Text(
            order.writerSuggestionText?.toString().trim().isNotEmpty == true
                ? order.writerSuggestionText.toString()
                : "No extra suggestion added by user.",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: primaryColor.withOpacity(0.82),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.065),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              ToastHelper.show(title, context);
            },
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: purpleColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  Widget clickableInfoBox({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.withOpacity(0.13),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: purpleColor,
              size: 21,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                title,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.58),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> acceptOrReject(Ordersdetailsmodel od) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ToastHelper.show("User not logged in", context);
      return;
    }

    setState(() {
      isActionLoading = true;
    });

    final token = await user.getIdToken(true);

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/orders/writerAssignmentStatus",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(od.toJson()),
      );

      if (response.statusCode == 200) {
        print("RESPONSEEEE :-  ${response.body}");
        ToastHelper.show("Order updated successfully", context);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Ordersscreen(),
          ),
        );

        print("Order Accepted / Rejected");
      } else {
        ToastHelper.show("Failed: ${response.statusCode}", context);
        print("Error Order Canceled due to ${response.statusCode}");
      }
    } catch (e) {
      ToastHelper.show("Something went wrong", context);
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  Future<Ordersdetailsmodel> fetchAvailableOrderById() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final FirebaseIdToken = await user.getIdToken(true);

    var url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/orders/findById?orderId=${widget.orderId}",
    );


    print("CHAT TOKEN EMPTY: ${FirebaseIdToken == null || FirebaseIdToken.isEmpty}");
    print("CHAT TOKEN START: ${FirebaseIdToken?.substring(0, 20)}");
    print("CHAT URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $FirebaseIdToken",
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        print("Successfully data get  :- ${data}!!");
        return Ordersdetailsmodel.fromJson(data);
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed: $e");
    }
  }

  Future<String?> getUserFileSignedUrl(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(
        "${apiConfig.baseUrl}/api/writer_side/orders/$orderId/user-file-url",
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);


      return data["url"];
    }

    print("Signed URL error: ${response.statusCode} ${response.body}");
    return null;
  }

  String capitalizeText(String text) {
    if (text.trim().isEmpty) {
      return text;
    }

    return text
        .split(" ")
        .map((word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(" ");
  }
}