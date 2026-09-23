import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../ApiConfig/apiConfig.dart';
import '../../PdfPreviewScreenFromDB.dart';
import '../../Toast/ToastHelper.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({
    super.key,
    required this.orderData,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color purpleColor = const Color(0xFF7B3FF2);

  @override
  Widget build(BuildContext context) {
    final data = widget.orderData;

    final String orderId = getValue(data, ["orderId"], "N/A");
    final String userfileName = getValue(data, ["userFileName", "fileName"], "your file");
    final String uploadedfileName = getValue(data, ["latestSubmissionFileName"], "work");
    final String typeOfWork = getValue(data, ["typeOfWork"], "Handwritten Work");
    final String writerName = getValue(data, ["writerName"], "Not Assigned");
    final String status = getOrderStatus(data);
    final bool paymentPending = isPaymentPending(data);

    final String pages = getValue(
      data,
      ["userFilePageCount", "filePageCount"],
      "0",
    );

    final String deadline = formatDateFull(
      data["deadline"] ?? data["selectedDate"],
      "No deadline",
    );

    final String createdAt = formatDateFull(
      data["createdAtTimestamp"] ?? data["createdAt"] ?? data["orderCreatedAt"],
      "Not available",
    );

    final String amount = getValue(data, ["totalOrderAmount"], "0");

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        toolbarHeight: 56,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: innerCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          "ORDER DETAILS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topSummaryCard(
                orderId: orderId,
                title: typeOfWork,
                status: paymentPending ? "PAYMENT PENDING" : cleanStatus(status),
                statusColor: paymentPending ? orangeColor : getStatusColor(status),
                amount: amount,
                pages: pages,
                deadline: deadline,
              ),

              const SizedBox(height: 12),

              _expansionCard(
                title: "Order Progress",
                icon: Icons.timeline_rounded,
                initiallyExpanded: false,
                child: _progressCard(data),
              ),

              const SizedBox(height: 12),

              _expansionCard(
                title: "Work Details",
                icon: Icons.assignment_rounded,
                initiallyExpanded: false,
                child: _detailsCard(
                  children: [
                    _detailRow(Icons.description_rounded, "Type of Work", typeOfWork),
                    _detailRow(Icons.file_copy_rounded, "Total Pages", "$pages Pages"),
                    _detailRow(
                      Icons.language_rounded,
                      "Language",
                      getValue(
                        data,
                        ["selectedLanguage", "languageSelectedChips", "language"],
                        "Not selected",
                      ),
                    ),
                    _detailRow(
                      Icons.color_lens_rounded,
                      "Ink Color",
                      getValue(
                        data,
                        ["InkColor", "selectedInkColor", "inkColor"],
                        "Not selected",
                      ),
                    ),
                    _detailRow(
                      Icons.menu_book_rounded,
                      "Notebook Type",
                      getValue(
                        data,
                        ["NotebookType", "selectedNotebook", "notebookType"],
                        "Not selected",
                      ),
                    ),
                    _detailRow(
                      Icons.speed_rounded,
                      "Urgency",
                      getValue(
                        data,
                        ["selectedDeadLineUrgency", "urgency"],
                        "Not selected",
                      ),
                    ),
                    _detailRow(Icons.calendar_month_rounded, "Deadline", deadline),
                    _detailRow(Icons.access_time_rounded, "Created At", createdAt),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _sectionTitle("Writer Details"),
              const SizedBox(height: 8),
              _detailsCard(
                children: [
                  _detailRow(Icons.person_rounded, "Writer Name", writerName),
                  _detailRow(
                    Icons.verified_user_rounded,
                    "Assignment Status",
                    cleanStatus(status),
                  ),
                  _detailRow(
                    Icons.badge_rounded,
                    "Writer ID",
                    maskWriterId( getValue(data, ["writerFirebaseUid"], "Not assigned yet"))

                  ),
                ],
              ),

              const SizedBox(height: 12),

              _sectionTitle("Payment Summary"),
              const SizedBox(height: 8),
              _priceCard(data),

              const SizedBox(height: 12),

              _sectionTitle("File Details"),
              const SizedBox(height: 8),
              _detailsCard(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      print("File clicked");

                      final int orderIdInt = int.tryParse(orderId.toString()) ?? 0;

                      final String? signedUrl = await getUserFileSignedUrl(orderIdInt);

                      if (!mounted) return;

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
                            fileName: userfileName,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 31,
                            width: 31,
                            decoration: BoxDecoration(
                              color: innerCardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              color: orangeColor,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Your File",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),


                          Expanded(
                            flex: 2,
                            child: Text(
                              userfileName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF4DA3FF),
                                fontSize: 12.4,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF4DA3FF),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if(status =="COMPLETED")
                    InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      print("File clicked");

                      final int orderIdInt = int.tryParse(orderId.toString()) ?? 0;

                      final String? signedUrl = await getWriterFileSignedUrl(orderIdInt);

                      if (!mounted) return;

                      if (signedUrl == null || signedUrl.isEmpty) {
                        print("PDF URL NULL ");
                        ToastHelper.show("File url is null", context);
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Pdfpreviewscreenfromdb(
                            fileUrl: signedUrl,
                            fileName: uploadedfileName,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 31,
                            width: 31,
                            decoration: BoxDecoration(
                              color: innerCardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              color: orangeColor,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Uploaded Work",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),


                          Expanded(
                            flex: 2,
                            child: Text(
                              uploadedfileName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF4DA3FF),
                                fontSize: 12.4,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF4DA3FF),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _detailRow(
                    Icons.storage_rounded,
                    "File Size",
                    formatFileSize(
                      getValue(data, ["userFileSize", "fileSize"], "0"),
                    ),
                  ),
                  _detailRow(
                    Icons.tag_rounded,
                    "Order ID",
                    "#$orderId",
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _sectionTitle("Your Instructions"),
              const SizedBox(height: 8),
              _noteCard(
                getValue(
                  data,
                  [
                    "WriterSuggestionText",
                    "writerSuggestionText",
                    "userSuggestionText",
                    "instructions",
                  ],
                  "No extra instruction added.",
                ),
              ),

              const SizedBox(height: 16),

              _bottomActionButton(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expansionCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          collapsedIconColor: Colors.white.withOpacity(0.75),
          iconColor: orangeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          leading: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Icon(
              icon,
              color: orangeColor,
              size: 18,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            child,
          ],
        ),
      ),
    );
  }

  Widget _topSummaryCard({
    required String orderId,
    required String title,
    required String status,
    required Color statusColor,
    required String amount,
    required String pages,
    required String deadline,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B3FF2), Color(0xFF4B1AB8)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Order #$orderId",
                      style: const TextStyle(
                        color: Color(0xFFB58CFF),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.55)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniBox(
                  icon: Icons.currency_rupee_rounded,
                  title: "Amount",
                  value: "₹$amount",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  icon: Icons.description_outlined,
                  title: "Pages",
                  value: pages,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  icon: Icons.calendar_month_rounded,
                  title: "Deadline",
                  value: deadline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Icon(icon, color: orangeColor, size: 18),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.52),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _progressCard(Map<String, dynamic> data) {
    final int activeStep = getActiveStepFromData(data);

    final List<Map<String, dynamic>> steps = [
      {
        "title": "Request Created",
        "subtitle": "Your order has been created",
        "icon": Icons.edit_document,
      },
      {
        "title": "Writer Assignment",
        "subtitle": "Finding or assigning writer",
        "icon": Icons.person_search_rounded,
      },
      {
        "title": "Payment",
        "subtitle": "Payment confirmation",
        "icon": Icons.payment_rounded,
      },
      {
        "title": "Work Started",
        "subtitle": "Writer is working on your order",
        "icon": Icons.draw_rounded,
      },
      {
        "title": "Review",
        "subtitle": "Check uploaded work",
        "icon": Icons.rate_review_rounded,
      },
      {
        "title": "Completed",
        "subtitle": "Order completed successfully",
        "icon": Icons.verified_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: innerCardColor.withOpacity(0.45),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final bool completed = index + 1 < activeStep;
          final bool current = index + 1 == activeStep;

          final Color stepColor = completed
              ? const Color(0xff01B920)
              : current
              ? orangeColor
              : Colors.white.withOpacity(0.25);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 31,
                    width: 31,
                    decoration: BoxDecoration(
                      color: stepColor.withOpacity(0.17),
                      shape: BoxShape.circle,
                      border: Border.all(color: stepColor.withOpacity(0.8)),
                    ),
                    child: Icon(
                      completed ? Icons.check_rounded : steps[index]["icon"],
                      color: stepColor,
                      size: 17,
                    ),
                  ),
                  if (index != steps.length - 1)
                    Container(
                      height: 34,
                      width: 2,
                      color: completed
                          ? const Color(0xff01B920)
                          : Colors.white.withOpacity(0.11),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]["title"],
                        style: TextStyle(
                          color: completed || current
                              ? Colors.white
                              : Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        steps[index]["subtitle"],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.52),
                          fontSize: 11.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _detailsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: innerCardColor.withOpacity(0.45),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 31,
            width: 31,
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: orangeColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(Map<String, dynamic> data) {
    final int pagesAmount = parseIntValue(
      getValue(data, ["orderPageCountAmount"], "0"),
    );

    final int platformFee = parseIntValue(
      getValue(data, ["platformFeeAmount"], "0"),
    );

    final int notebookCharges = parseIntValue(
      getValue(data, ["noteBookChargesAmount"], "0"),
    );

    final int deliveryCharges = parseIntValue(
      getValue(data, ["deliveryChargesAmount"], "0"),
    );

    final int totalAmount = parseIntValue(
      getValue(data, ["totalOrderAmount"], "0"),
    );

    final int urgencyAmount =
    parseIntValue(getValue(data, ["urgencyAmount"] , "0"),);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _priceRow("Writing Charges", pagesAmount),
          _priceRow("Urgency Amount", urgencyAmount),
          _priceRow("Platform Fee", platformFee),
          _priceRow("Notebook Charges", notebookCharges),
          _priceRow("Delivery Charges", deliveryCharges),
          Divider(color: Colors.white.withOpacity(0.10), height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Total Amount",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "₹$totalAmount",
                style: TextStyle(
                  color: orangeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _paymentStatusBox(data),
        ],
      ),
    );
  }

  Widget _priceRow(String title, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: 12.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            "₹$amount",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentStatusBox(Map<String, dynamic> data) {
    final bool pending = isPaymentPending(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: pending
            ? orangeColor.withOpacity(0.12)
            : const Color(0xff01B920).withOpacity(0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: pending
              ? orangeColor.withOpacity(0.32)
              : const Color(0xff01B920).withOpacity(0.32),
        ),
      ),
      child: Row(
        children: [
          Icon(
            pending ? Icons.lock_clock_rounded : Icons.verified_rounded,
            color: pending ? orangeColor : const Color(0xff01B920),
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pending ? "Payment is pending" : "Payment completed",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        note,
        style: TextStyle(
          color: Colors.white.withOpacity(0.78),
          fontSize: 12.6,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bottomActionButton(Map<String, dynamic> data) {
    final String status = getOrderStatus(data);

    String text = "Track Order";
    IconData icon = Icons.track_changes_rounded;

    if (isPaymentPending(data)) {
      text = "Payment Required";
      icon = Icons.payment_rounded;
    } else if (status == "REVIEW") {
      text = "View Submitted Work";
      icon = Icons.remove_red_eye_rounded;
    } else if (status == "COMPLETED") {
      text = "Order Completed";
      icon = Icons.verified_rounded;
    }

    return Container(
      height: 46,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFF7A00), Color(0xffFF4D00)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: orangeColor.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  String getValue(
      Map<String, dynamic> data,
      List<String> keys,
      String defaultValue,
      ) {
    for (String key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key].toString().trim();

        if (value.isNotEmpty && value != "null") {
          return value;
        }
      }
    }

    return defaultValue;
  }

  String getOrderStatus(Map<String, dynamic> data) {
    return getValue(
      data,
      ["status", "writerAssignmentStatus"],
      "UNKNOWN",
    ).toUpperCase();
  }

  bool isPaymentPaid(Map<String, dynamic> data) {
    final paymentStatus = getValue(data, ["paymentStatus"], "").toUpperCase();
    final orderStatus = getValue(data, ["orderStatus"], "").toUpperCase();
    final paymentRequired = getValue(data, ["paymentRequired"], "").toLowerCase();

    if (paymentRequired == "false") {
      return true;
    }

    if (paymentStatus == "PAID" ||
        paymentStatus == "SUCCESS" ||
        paymentStatus == "CAPTURED") {
      return true;
    }

    if (orderStatus == "PAID" ||
        orderStatus == "SUCCESS" ||
        orderStatus == "CAPTURED") {
      return true;
    }

    return false;
  }

  bool isPaymentPending(Map<String, dynamic> data) {
    if (isPaymentPaid(data)) {
      return false;
    }

    final paymentStatus = getValue(data, ["paymentStatus"], "").toUpperCase();
    final orderStatus = getValue(data, ["orderStatus"], "").toUpperCase();
    final paymentRequired = getValue(data, ["paymentRequired"], "").toLowerCase();

    if (paymentRequired == "true") {
      return true;
    }

    if (paymentStatus == "PENDING" ||
        paymentStatus == "FAILED" ||
        paymentStatus == "NOT_PAID" ||
        paymentStatus == "UNPAID") {
      return true;
    }

    if (orderStatus == "PENDING" ||
        orderStatus == "FAILED" ||
        orderStatus == "NOT_PAID" ||
        orderStatus == "UNPAID") {
      return true;
    }

    if (paymentStatus.isEmpty && orderStatus.isEmpty && paymentRequired.isEmpty) {
      return true;
    }

    return true;
  }

  int getActiveStepFromData(Map<String, dynamic> data) {
    if (isPaymentPending(data)) {
      return 3;
    }

    final status = getOrderStatus(data);

    if (status == "FINDING_WRITER" ||
        status == "ACCEPTED" ||
        status == "IN_PROGRESS") {
      return 4;
    }

    if (status == "REVIEW" || status == "REQUEST_CHANGES") {
      return 5;
    }

    if (status == "COMPLETED") {
      return 6;
    }

    return 4;
  }

  String cleanStatus(String status) {
    final upperStatus = status.toUpperCase();

    if (upperStatus == "PAYMENT_PENDING" || upperStatus == "PAYMENT PENDING") {
      return "PENDING";
    }

    if (upperStatus == "UNDER_REVIEW" || upperStatus == "REVIEW") {
      return "REVIEW";
    }

    if (upperStatus == "IN_PROGRESS") {
      return "ACTIVE";
    }

    if (upperStatus == "FINDING_WRITER") {
      return "FINDING";
    }

    if (upperStatus == "REQUEST_CHANGES") {
      return "CHANGES";
    }

    if (upperStatus == "COMPLETED") {
      return "DONE";
    }

    if (upperStatus == "ACCEPTED") {
      return "ACCEPTED";
    }

    return upperStatus.replaceAll("_", " ");
  }

  Color getStatusColor(String status) {
    final upperStatus = status.toUpperCase();

    if (upperStatus == "IN_PROGRESS" || upperStatus == "ACCEPTED") {
      return const Color(0xff1DB954);
    }

    if (upperStatus == "REVIEW" || upperStatus == "UNDER_REVIEW") {
      return const Color(0xff2F80ED);
    }

    if (upperStatus == "REQUEST_CHANGES") {
      return const Color(0xffFFB000);
    }

    if (upperStatus == "COMPLETED") {
      return const Color(0xff01B920);
    }

    if (upperStatus == "FINDING_WRITER") {
      return const Color(0xFFB58CFF);
    }

    return Colors.white70;
  }

  String formatDateFull(dynamic value, String fallback) {
    try {
      if (value == null) {
        return fallback;
      }

      if (value is Timestamp) {
        return DateFormat("dd MMM yyyy").format(value.toDate());
      }

      if (value is DateTime) {
        return DateFormat("dd MMM yyyy").format(value);
      }

      final text = value.toString().trim();

      if (text.isEmpty || text == "null") {
        return fallback;
      }

      final dateTime = DateTime.tryParse(text);

      if (dateTime == null) {
        return text;
      }

      return DateFormat("dd MMM yyyy").format(dateTime);
    } catch (e) {
      return fallback;
    }
  }

  int parseIntValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  String formatFileSize(String value) {
    final int bytes = int.tryParse(value) ?? 0;

    if (bytes <= 0) {
      return "Not available";
    }

    if (bytes < 1024) {
      return "$bytes B";
    }

    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }

    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
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

  Future<String?> getWriterFileSignedUrl(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(
        "${apiConfig.baseUrl}/api/user_side/$orderId/writer-file-url",
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

  String maskWriterId(String value) {
    if (value.isEmpty || value == "Not assigned yet" || value == "null") {
      return "Not assigned yet";
    }

    if (value.length <= 6) {
      return "******";
    }

    return "${value.substring(0, 3)}******${value.substring(value.length - 3)}";
  }
}