import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/ReviewScreen/submissionHistoryScreen.dart';
import 'package:likho/ChatsScreen/ChatDetailScreen.dart';
import 'package:likho/Model/UserChatListModel.dart';
import 'package:likho/PdfPreviewScreenFromDB.dart';
import 'package:likho/Toast/ToastHelper.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class viewSubmissionScreen extends StatefulWidget {
  final int orderId;

  const viewSubmissionScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<viewSubmissionScreen> createState() => _viewSubmissionScreenState();
}

class _viewSubmissionScreenState extends State<viewSubmissionScreen> {
  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  bool isDownloading = false;
  bool isOpeningPdf = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: getOrderDataFromFirebase(),
          builder: (context, orderSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: purpleColor,
                ),
              );
            }

            if (orderSnapshot.hasError) {
              return errorLayout("Something went wrong while loading order");
            }

            if (!orderSnapshot.hasData || !orderSnapshot.data!.exists) {
              return errorLayout("Order not found");
            }

            final orderData =
            orderSnapshot.data!.data() as Map<String, dynamic>;

            return StreamBuilder<QuerySnapshot>(
              stream: getLatestSubmissionDataFromFirebase(),
              builder: (context, submissionSnapshot) {
                if (submissionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: purpleColor,
                    ),
                  );
                }

                if (submissionSnapshot.hasError) {
                  print("SUBMISSION ERROR: ${submissionSnapshot.error}");

                  return errorLayout(
                    "Something went wrong while loading submission\n${submissionSnapshot.error}",
                  );
                }

                if (!submissionSnapshot.hasData ||
                    submissionSnapshot.data!.docs.isEmpty) {
                  return noSubmissionLayout(orderData);
                }

                final latestSubmission =
                submissionSnapshot.data!.docs.first.data()
                as Map<String, dynamic>;

                return Column(
                  children: [
                    topHeader(orderData, latestSubmission),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                        child: Column(
                          children: [
                            submissionOverviewCard(
                              orderData,
                              latestSubmission,
                            ),
                            uploadedWorkCard(
                              orderData,
                              latestSubmission,
                            ),
                            submissionNotesCard(
                              latestSubmission,
                            ),
                          ],
                        ),
                      ),
                    ),
                    submissionHistoryFixedButton(),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        stream: getOrderDataFromFirebase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const SizedBox.shrink();
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;

          return bottomActionBar(orderData);
        },
      ),
    );
  }

  Stream<DocumentSnapshot> getOrderDataFromFirebase() {
    return FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId.toString())
        .snapshots();
  }

  Stream<QuerySnapshot> getLatestSubmissionDataFromFirebase() {
    return FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId.toString())
        .collection("writerSubmission")
        .where("isLatest", isEqualTo: true)
        .limit(1)
        .snapshots();
  }

  Widget topHeader(
      Map<String, dynamic> orderData,
      Map<String, dynamic> latestSubmission,
      ) {
    String orderId = getValueFromData(
      orderData,
      ["orderId"],
      widget.orderId.toString(),
    );

    String version = getValueFromData(
      latestSubmission,
      ["version"],
      "1",
    );

    String totalOrderAmount = getValueFromData(
      orderData,
      ["totalOrderAmount"],
      "0",
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 13),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
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
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "View Submission",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Order #$orderId • Latest Version V$version",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              print("Earning clicked");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F8EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "₹$totalOrderAmount",
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

  Widget submissionOverviewCard(
      Map<String, dynamic> orderData,
      Map<String, dynamic> latestSubmission,
      ) {
    String submissionStatus = getValueFromData(
      latestSubmission,
      ["submissionStatus", "status"],
      "ON_REVIEW",
    );

    String uploadedAt = getFormattedDateTimeFromData(
      latestSubmission,
      ["uploadedAtTimestamp", "uploadedAt", "completedAt"],
      "Not Available",
    );

    String version = getValueFromData(
      latestSubmission,
      ["version"],
      "1",
    );

    String filePageCount = getValueFromData(
      latestSubmission,
      ["filePageCount"],
      getValueFromData(orderData, ["filePageCount"], "0"),
    );

    return sectionCard(
      title: "SUBMISSION OVERVIEW",
      icon: Icons.assignment_rounded,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.orange.withOpacity(0.14),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                print("Submission status clicked");
              },
              child: Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE7BD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      color: Colors.orange.shade800,
                      size: 19,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getReadableStatus(submissionStatus),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          "Submitted • Waiting for user review",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.55),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "100%",
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: LinearProgressIndicator(
                value: 1.0,
                minHeight: 5.5,
                backgroundColor: const Color(0xFFFFE7BD),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange.shade700,
                ),
              ),
            ),

            const SizedBox(height: 11),

            Divider(
              height: 1,
              color: Colors.orange.withOpacity(0.14),
            ),

            const SizedBox(height: 10),

            overviewInfoBoxCompact(
              Icons.calendar_month_rounded,
              "Submitted",
              uploadedAt,
              fullWidth: true,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: overviewInfoBoxCompact(
                    Icons.sell_rounded,
                    "Version",
                    "V$version",
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: overviewInfoBoxCompact(
                    Icons.description_rounded,
                    "Pages",
                    filePageCount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget overviewInfoBox(
      IconData icon,
      String title,
      String value,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        print("$title clicked");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            Container(
              height: 31,
              width: 31,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: purpleColor,
                size: 17,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.50),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
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

  Widget uploadedWorkCard(
      Map<String, dynamic> orderData,
      Map<String, dynamic> latestSubmission,
      ) {
    String fileName = getValueFromData(
      latestSubmission,
      ["fileName"],
      "Uploaded work file",
    );

    String fileType = getValueFromData(
      latestSubmission,
      ["fileType"],
      "PDF",
    );

    String filePageCount = getValueFromData(
      latestSubmission,
      ["filePageCount"],
      getValueFromData(orderData, ["filePageCount"], "0"),
    );

    String fileSize = getValueFromData(
      latestSubmission,
      ["fileSize"],
      "N/A",
    );

    return sectionCard(
      title: "UPLOADED WORK",
      icon: Icons.upload_file_rounded,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: purpleColor.withOpacity(0.14),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () {
                    print("File icon clicked");
                  },
                  child: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: purpleColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        fileType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$fileType • $filePageCount Page • ${formatFileSize(fileSize)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.50),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 43,
                    child: OutlinedButton(
                      onPressed: isOpeningPdf
                          ? null
                          : () async {
                        print("Open full file clicked");

                        setState(() {
                          isOpeningPdf = true;
                        });

                        try {
                          final signedUrl =
                          await getWriterFileSignedUrl(widget.orderId);

                          if (!mounted) return;

                          if (signedUrl == null || signedUrl.isEmpty) {
                            ToastHelper.show("File url is null", context);
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Pdfpreviewscreenfromdb(
                                    fileUrl: signedUrl,
                                    fileName: fileName,
                                  ),
                            ),
                          );
                        } catch (e) {
                          print("Open PDF Error: $e");
                          ToastHelper.show("Unable to open PDF", context);
                        } finally {
                          if (mounted) {
                            setState(() {
                              isOpeningPdf = false;
                            });
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: purpleColor,
                        disabledForegroundColor: purpleColor.withOpacity(0.45),
                        side: BorderSide(
                          color: purpleColor.withOpacity(0.55),
                          width: 1.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: isOpeningPdf
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 17,
                            width: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: purpleColor,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            "Opening...",
                            style: TextStyle(
                              color: purpleColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 17,
                            color: purpleColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Open PDF",
                            style: TextStyle(
                              color: purpleColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SizedBox(
                    height: 43,
                    child: ElevatedButton(
                      onPressed: isDownloading
                          ? null
                          : () async {
                        print("Download clicked");

                        setState(() {
                          isDownloading = true;
                        });

                        try {
                          final signedUrl =
                          await getWriterFileSignedUrl(widget.orderId);

                          if (!mounted) return;

                          if (signedUrl == null || signedUrl.isEmpty) {
                            ToastHelper.show("File url is null", context);
                            return;
                          }

                          await downloadPdfFromSignedUrl(
                            signedUrl: signedUrl,
                            fileName: fileName,
                          );
                        } catch (e) {
                          print("Download Button Error: $e");
                          ToastHelper.show("Download failed", context);
                        } finally {
                          if (mounted) {
                            setState(() {
                              isDownloading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: purpleColor,
                        disabledBackgroundColor: purpleColor.withOpacity(0.60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: isDownloading
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 17,
                            width: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Saving...",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Download",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget submissionNotesCard(
      Map<String, dynamic> latestSubmission,
      ) {
    String writerNote = getValueFromData(
      latestSubmission,
      ["writerNote", "latestSubmissionWriterNote"],
      "Work uploaded successfully and sent to user for review.",
    );

    return sectionCard(
      title: "SUBMISSION NOTES",
      icon: Icons.notes_rounded,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          print("Submission notes clicked");
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.withOpacity(0.13),
            ),
          ),
          child: Text(
            writerNote,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12.5,
              height: 1.30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget submissionHistoryFixedButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          print("View Submission History clicked");
          Navigator.push(context, MaterialPageRoute(builder: (context)=>submissionHistoryScreen(orderId:widget.orderId,)));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: purpleColor.withOpacity(0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.055),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE8FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: purpleColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "View Submission History",
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
                      "Old versions and user feedback",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.50),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: primaryColor.withOpacity(0.45),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomActionBar(Map<String, dynamic> orderData) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 47,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final Userchatlistmodel chatOrder = Userchatlistmodel(
                      orderId:widget.orderId,
                      userName: getValueFromData(
                        orderData,
                        ["userName", "customerName", "name"],
                        "User",
                      ),
                      userFirebaseUid: getValueFromData(
                        orderData,
                        ["userFirebaseUid", "userId"],
                        "",
                      ),
                      orderStatus: getValueFromData(
                        orderData,
                        ["writerAssignmentStatus"],
                        "IN_PROGRESS",
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatdetailscreen(
                          order: chatOrder,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    "Open Chat",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: purpleColor,
                    side: BorderSide(
                      color: purpleColor.withOpacity(0.55),
                      width: 1.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 47,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print("Waiting for review clicked");
                  },
                  icon: Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.orange.shade800,
                    size: 17,
                  ),
                  label: const Text(
                    "On Review",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFFFF2D9),
                    foregroundColor: Colors.orange.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
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

  Widget noSubmissionLayout(Map<String, dynamic> orderData) {
    return Column(
      children: [
        topHeader(orderData, const {
          "version": "1",
        }),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 82,
                    width: 82,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE8FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.upload_file_outlined,
                      color: purpleColor,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "No submission found",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    "Latest writer submission is not available for this order.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.55),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget errorLayout(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w900,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              print("$title clicked");
            },
            child: Row(
              children: [
                Container(
                  height: 31,
                  width: 31,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: purpleColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }

  String getValueFromData(
      Map<String, dynamic> data,
      List<String> keys,
      String defaultValue,
      ) {
    for (String key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        String value = data[key].toString().trim();

        if (value.isNotEmpty && value != "null") {
          return value;
        }
      }
    }

    return defaultValue;
  }

  String getReadableStatus(String status) {
    if (status == "ON_REVIEW" || status == "REVIEW") {
      return "On Review";
    }

    if (status == "CHANGES_REQUESTED") {
      return "Changes Requested";
    }

    if (status == "COMPLETED" || status == "ACCEPTED") {
      return "Completed";
    }

    return status;
  }

  String formatDateTime(String value) {
    try {
      DateTime dateTime = DateTime.parse(value);

      String day = dateTime.day.toString().padLeft(2, "0");
      String month = monthName(dateTime.month.toString().padLeft(2, "0"));
      String hour = dateTime.hour.toString().padLeft(2, "0");
      String minute = dateTime.minute.toString().padLeft(2, "0");

      return "$day $month\n$hour:$minute";
    } catch (e) {
      return value;
    }
  }

  String monthName(String month) {
    switch (month) {
      case "01":
        return "Jan";
      case "02":
        return "Feb";
      case "03":
        return "Mar";
      case "04":
        return "Apr";
      case "05":
        return "May";
      case "06":
        return "Jun";
      case "07":
        return "Jul";
      case "08":
        return "Aug";
      case "09":
        return "Sep";
      case "10":
        return "Oct";
      case "11":
        return "Nov";
      case "12":
        return "Dec";
      default:
        return month;
    }
  }

  String formatFileSize(String fileSize) {
    try {
      double size = double.parse(fileSize);

      if (size < 1024) {
        return "${size.toStringAsFixed(0)} B";
      }

      if (size < 1024 * 1024) {
        return "${(size / 1024).toStringAsFixed(1)} KB";
      }

      return "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
    } catch (e) {
      return fileSize;
    }
  }

  Future<String?> getWriterFileSignedUrl(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);

    final url = "${apiConfig.baseUrl}/api/user_side/$orderId/writer-file-url";

    print("SIGNED URL API: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("SIGNED URL STATUS: ${response.statusCode}");
    print("SIGNED URL BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["url"];
    }

    ToastHelper.show("File URL error: ${response.statusCode}", context);
    return null;
  }

  Future<void> downloadPdfFromSignedUrl({
    required String signedUrl,
    required String fileName,
  }) async {
    try {
      ToastHelper.show("Download started", context);

      String cleanFileName = fileName.trim();

      if (cleanFileName.isEmpty || cleanFileName == "Uploaded work file") {
        cleanFileName = "writer_submission_${widget.orderId}.pdf";
      }

      cleanFileName = cleanFileName.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        "_",
      );

      if (!cleanFileName.toLowerCase().endsWith(".pdf")) {
        cleanFileName = "$cleanFileName.pdf";
      }

      final response = await http.get(Uri.parse(signedUrl));

      print("DOWNLOAD HTTP STATUS: ${response.statusCode}");
      print("DOWNLOAD BYTES: ${response.bodyBytes.length}");

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception("Download failed");
      }

      if (Platform.isAndroid) {
        final tempDir = await getTemporaryDirectory();

        final tempFile = File("${tempDir.path}/$cleanFileName");

        await tempFile.writeAsBytes(
          response.bodyBytes,
          flush: true,
        );

        print("TEMP FILE PATH: ${tempFile.path}");
        print("TEMP FILE EXISTS: ${await tempFile.exists()}");
        print("TEMP FILE SIZE: ${await tempFile.length()}");

        final mediaStore = MediaStore();

        final saveInfo = await mediaStore.saveFile(
          tempFilePath: tempFile.path,
          dirType: DirType.download,
          dirName: DirName.download,
        );

        print("MEDIA STORE SAVE INFO: $saveInfo");

        await MediaScanner.loadMedia(path: tempFile.path);

        ToastHelper.show("PDF saved in Downloads", context);
      } else if (Platform.isIOS) {
        ToastHelper.show("iOS download handling pending", context);
      } else {
        ToastHelper.show("Unsupported platform", context);
      }
    } catch (e) {
      print("Download Error: $e");
      ToastHelper.show("Download failed", context);
    }
  }

  String getFormattedDateTimeFromData(
      Map<String, dynamic> data,
      List<String> keys,
      String defaultValue,
      ) {
    for (String key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        dynamic value = data[key];

        try {
          DateTime? dateTime;

          if (value is Timestamp) {
            dateTime = value.toDate();
          } else if (value is DateTime) {
            dateTime = value;
          } else {
            String text = value.toString().trim();

            if (text.isEmpty || text == "null") {
              continue;
            }

            dateTime = DateTime.tryParse(text);
          }

          if (dateTime != null) {
            return DateFormat("dd MMM yyyy, hh:mm a").format(dateTime);
          }
        } catch (e) {
          print("Date time format error: $e");
        }
      }
    }

    return defaultValue;
  }

  Widget overviewInfoBoxCompact(
      IconData icon,
      String title,
      String value, {
        bool fullWidth = false,
      }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orange.shade800,
            size: 16,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.52),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  softWrap: true,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}