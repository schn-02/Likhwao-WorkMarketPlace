import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/AvailableOrderScreens/OrderDetailsScreen.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/InProgressOrderScreens/WorkUploadScreen.dart';
import 'package:likho/Model/OrdersDetailsModel.dart';

import 'package:likho/PdfPreviewScreenFromDB.dart';
import 'package:likho/Toast/ToastHelper.dart';
import 'package:slide_to_act/slide_to_act.dart';

class Orderworkingscreen extends StatefulWidget {
  final int orderId;
  const Orderworkingscreen({super.key, required this.orderId});

  @override
  State<Orderworkingscreen> createState() => _OrderworkingscreenState();
}

class _OrderworkingscreenState extends State<Orderworkingscreen> {
  late Future<Ordersdetailsmodel> orderFuture;
  bool isUpdatingStatus = false;
  int? updatingOrderId;
  String? updatedStatus;

  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  @override
  void initState() {
    super.initState();
    orderFuture = getInProgressDataByOrderId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ordersdetailsmodel>(
      future: orderFuture,
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
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w900,
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
                workingTopBar(order),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                    child: Column(
                      children: [
                        workingStatusCard(order),
                        quickActionCard(order),
                        UserDetailsCard(order),
                        orderSummaryDetails(order),
                        attacments(order),
                        timeInfo(order),
                        writerSuggestionText(order),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
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
              child: SizedBox(
                height: 58,
                child: buildSlideAction(order, context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget workingTopBar(Ordersdetailsmodel order) {
    String earning =
        "₹${(order.totalOrderAmount ?? 0) - (order.platformFeeAmount ?? 0)}";

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
      child: Row(
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
                  capitalizeText(order.typeOfWork.toString()),
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
                  "Order #${order.UserOrderId ?? widget.orderId} • ${order.writerAssignmentStatus ?? "ACTIVE"}",
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
              ToastHelper.show("Earning details clicked", context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F8EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                earning,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget workingStatusCard(Ordersdetailsmodel order) {
    String status = order.writerAssignmentStatus ?? "ACCEPTED";

    double progressValue = 0.15;
    String progressText = "Accepted • Ready to start";
    String statusTitle = "Accepted";
    Color statusColor = Colors.green.shade700;
    Color statusBg = const Color(0xFFE9F8EF);
    IconData statusIcon = Icons.check_circle_outline_rounded;

    if (status == "IN_PROGRESS") {
      progressValue = 0.45;
      progressText = "Work started • Continue writing";
      statusTitle = "In Progress";
      statusColor = Colors.blue.shade700;
      statusBg = const Color(0xFFEAF3FF);
      statusIcon = Icons.play_circle_outline_rounded;
    } else if (status == "REVIEW") {
      progressValue = 1.0;
      progressText = "Submitted • Waiting for user review";
      statusTitle = "On Review";
      statusColor = Colors.orange.shade800;
      statusBg = const Color(0xFFFFF2D9);
      statusIcon = Icons.hourglass_top_rounded;
    }

    return sectionCard(
      title: "WORK STATUS",
      icon: Icons.timeline_rounded,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          ToastHelper.show("Work status clicked", context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.withOpacity(0.13),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: statusBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusTitle,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progressText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.58),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${(progressValue * 100).toInt()}%",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE6E1FF),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status == "REVIEW" ? Colors.orange.shade700 : purpleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickActionCard(Ordersdetailsmodel order) {
    return sectionCard(
      title: "QUICK ACTIONS",
      icon: Icons.flash_on_rounded,
      child: Row(
        children: [
          Expanded(
            child: quickActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              title: "Chat",
              subtitle: "Open chat",
              onTap: () {
                ToastHelper.show("Chat feature will open here", context);
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: quickActionButton(
              icon: Icons.picture_as_pdf_rounded,
              title: "PDF",
              subtitle: "View file",
              onTap: () async {
                await openPdfFile(order);
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: quickActionButton(
              icon: Icons.upload_file_rounded,
              title: "Upload",
              subtitle: "Submit work",

              onTap: () async {
              if (order.writerAssignmentStatus == "IN_PROGRESS") {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return Workuploadscreen(orders: order);
                  },
                );

                if (result == "goToReviewTab") {
                  if (!context.mounted) return;

                  Navigator.pop(context, "goToReviewTab");
                }
              } else {
                ToastHelper.show("Start work first", context);
              }
            },
            ),
          ),
        ],
      ),
    );
  }

  Widget quickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.grey.withOpacity(0.13),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: purpleColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor.withOpacity(0.48),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
                  ToastHelper.show("User profile clicked", context);
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
                    buildUserDetailsRow("Name", order.fullName),
                    const SizedBox(height: 10),


                    buildUserDetailsRow("Phone", maskedNumber(order.mobileNumber.toString())),
                    const SizedBox(height: 10),
                    buildUserDetailsRow("Email", maskEmail(order.userEmail)),
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

   String maskedNumber(String number)
  {

     String start = number.substring(0,2);

     String end = number.substring(number.length-3 , number.length-1);
     String mask = "*" * (number.length-4);

     return "$start$mask$end";
  }

  String maskEmail(String? email) {
    if (email == null || !email.contains('@')) {
      return 'Hidden Email';
    }

    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];

    if (name.isEmpty) {
      return 'Hidden Email';
    }

    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }

    return '${name.substring(0, 2)}***@$domain';
  }

  Widget buildUserDetailsRow(String label, String? value) {
    IconData icon = Icons.info_outline_rounded;

    if (label.toLowerCase().contains("name")) {
      icon = Icons.badge_outlined;
    } else if (label.toLowerCase().contains("phone")) {
      icon = Icons.phone_rounded;
    } else if (label.toLowerCase().contains("email")) {
      icon = Icons.email_outlined;
    }

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
                  "Work Type",
                  order.typeOfWork,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildOrderSummaryDetailsRow(
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
                  "Language ",
                  order.languageSelectedChips,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildOrderSummaryDetailsRow(
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
                  "Page Count",
                  order.userFilePageCount != null
                      ? order.userFilePageCount.toString()
                      : "-1",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildOrderSummaryDetailsRow(
                  "DeadLine",
                  formatDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOrderSummaryDetailsRow(String label, String? value) {
    IconData icon = Icons.info_outline_rounded;

    if (label.toLowerCase().contains("work")) {
      icon = Icons.work_outline_rounded;
    } else if (label.toLowerCase().contains("earning")) {
      icon = Icons.currency_rupee_rounded;
    } else if (label.toLowerCase().contains("language")) {
      icon = Icons.language_rounded;
    } else if (label.toLowerCase().contains("ink")) {
      icon = Icons.water_drop_outlined;
    } else if (label.toLowerCase().contains("page")) {
      icon = Icons.description_outlined;
    } else if (label.toLowerCase().contains("deadline")) {
      icon = Icons.calendar_month_rounded;
    }

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
                    label.trim(),
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

              Container(
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
    DateTime? selectedDate =
    DateTime.tryParse(order.selectedDate?.toString() ?? "");
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
          buildTimeInfoDetailsRow("Order Placed", formattedDate),
          const SizedBox(height: 12),
          buildTimeInfoDetailsRow("Remaining ", remainingTime),
        ],
      ),
    );
  }

  Widget buildTimeInfoDetailsRow(String label, String? value) {
    bool isExpired = (value ?? "").toLowerCase().contains("expired");

    IconData icon = Icons.timer_outlined;

    if (label.toLowerCase().contains("placed")) {
      icon = Icons.event_available_rounded;
    }

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

  Widget buildSlideAction(Ordersdetailsmodel order, BuildContext context) {
    int? orderId = order.UserOrderId;

    if (isUpdatingStatus && updatingOrderId == orderId) {
      return Center(
        child: CircularProgressIndicator(
          color: purpleColor,
        ),
      );
    }

    if (order.writerAssignmentStatus == "IN_PROGRESS") {
      return SlideAction(
        text: "  SWIPE TO COMPLETE  ",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
        outerColor: purpleColor,
        innerColor: Colors.white54,
        onSubmit: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (bottomSheetContext) {
              return Workuploadscreen(orders: order);
            },
          );

          print("Bottom sheet result from slide: $result");

          if (result == "goToReviewTab") {
            if (!mounted) return;

            Navigator.pop(context, "goToReviewTab");
          }
        },
      );
    }
    else if (order.writerAssignmentStatus == "REVIEW") {
      return InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () {
          ToastHelper.show("Work is under review", context);
        },
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2D9),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(
            "ON REVIEW",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.orange.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return SlideAction(
      outerColor: Colors.green.shade600,
      innerColor: Colors.white54,
      onSubmit: () async {
        try {
          setState(() {
            isUpdatingStatus = true;
            updatingOrderId = orderId;
          });

          Ordersdetailsmodel od = Ordersdetailsmodel(
            writerAssignmentStatus: "IN_PROGRESS",
            UserOrderId: order.UserOrderId,
          );

          await changeStatus(od, order);

          setState(() {
            orderFuture = getInProgressDataByOrderId();
          });

          final updatedOrder = await orderFuture;

          if (!mounted) return;

          if (updatedOrder.writerAssignmentStatus == "IN_PROGRESS") {
            setState(() {
              isUpdatingStatus = false;
              updatingOrderId = null;
            });
          }
        } catch (e) {
          if (!mounted) return;

          setState(() {
            isUpdatingStatus = false;
            updatingOrderId = null;
          });

          ToastHelper.show("Failed to update status", context);
        }
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          "  SWIPE TO START   ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
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

  Future<void> changeStatus(Ordersdetailsmodel od, Ordersdetailsmodel order) async {
    print("changeStatusToInProgressFromAccept");

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final token = await user.getIdToken(true);

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/orders/writerAssignmentStatus",
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(od.toJson()),
    );

    if (response.statusCode == 200) {
      print("Status changed successfully !! ");
      if (!mounted) {
        return;
      }
    }
  }

  Future<Ordersdetailsmodel> getInProgressDataByOrderId() async {
    try {
      print("In Progress Data");

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final token = await user.getIdToken(true);

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/writer_side/orders/findById?orderId=${widget.orderId}",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print("Successfully data get ");
        var data = jsonDecode(response.body);
        print("DATA ${data}");

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