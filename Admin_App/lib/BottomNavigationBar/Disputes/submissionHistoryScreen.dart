import 'dart:convert';
import 'dart:io';

import 'package:adminlikhwao/ApiConfig/apiConfig.dart';
import 'package:adminlikhwao/PdfPreviewScreenFromDB.dart';
import 'package:adminlikhwao/Toast/ToastHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class submissionHistoryScreen extends StatefulWidget {
  final int orderId;

  const submissionHistoryScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<submissionHistoryScreen> createState() =>
      _submissionHistoryScreenState();
}

class _submissionHistoryScreenState extends State<submissionHistoryScreen> {
  final Color primaryColor = const Color(0xFF0B164A);
  final Color purpleColor = const Color(0xFF4F2EDB);
  final Color bgColor = const Color(0xFFF7F6FF);

  String? openingFilePath;
  String? downloadingFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            topHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getSubmissionHistoryFromFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: purpleColor,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    print("SUBMISSION HISTORY ERROR: ${snapshot.error}");
                    return errorLayout(
                      "Something went wrong while loading submission history",
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return noHistoryLayout();
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final bool isLast = index == docs.length - 1;

                      return submissionTimelineCard(
                        data: data,
                        isLast: isLast,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> getSubmissionHistoryFromFirebase() {
    return FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId.toString())
        .collection("writerSubmission")
        .orderBy("version", descending: true)
        .snapshots();
  }

  Widget topHeader() {
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
                  "Submission History",
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
                  "Order #${widget.orderId} • All uploaded versions",
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
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  Widget submissionTimelineCard({
    required Map<String, dynamic> data,
    required bool isLast,
  }) {
    String version = getValueFromData(data, ["version"], "1");

    String submissionStatus = getValueFromData(
      data,
      ["submissionStatus", "status"],
      "ON_REVIEW",
    );

    String fileName = getValueFromData(
      data,
      ["fileName"],
      "Uploaded work file",
    );

    String fileType = getValueFromData(
      data,
      ["fileType"],
      "PDF",
    );

    String fileSize = getValueFromData(
      data,
      ["fileSize"],
      "N/A",
    );

    String filePageCount = getValueFromData(
      data,
      ["filePageCount"],
      "0",
    );


    String uploadedAt = getFormattedDateTimeFromData(
      data,
      ["uploadedAtTimestamp", "uploadedAt", "completedAt"],
      "Not Available",
    );

    String writerNote = getValueFromData(
      data,
      ["writerNote"],
      "No writer note added.",
    );

    String changeRequestText = getValueFromData(
      data,
      ["changeRequestText"],
      "",
    );

    bool isLatest = getValueFromData(
      data,
      ["isLatest"],
      "false",
    ).toLowerCase() ==
        "true";

    Color statusBgColor = getStatusBgColor(submissionStatus);
    Color statusTextColor = getStatusTextColor(submissionStatus);
    IconData statusIcon = getStatusIcon(submissionStatus);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        timelineIndicator(
          statusBgColor,
          statusTextColor,
          statusIcon,
          isLast,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(13),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topVersionRow(
                  version: version,
                  isLatest: isLatest,
                  submissionStatus: submissionStatus,
                  statusBgColor: statusBgColor,
                  statusTextColor: statusTextColor,
                  statusIcon: statusIcon,
                ),
                const SizedBox(height: 12),
                fileInfoCard(
                  fileName: fileName,
                  fileType: fileType,
                  filePageCount: filePageCount,
                  fileSize: fileSize,
                ),
                const SizedBox(height: 11),
                infoRow(
                  icon: Icons.schedule_rounded,
                  title: "Uploaded",
                  value: formatDateTime(uploadedAt),
                ),
                const SizedBox(height: 9),
                infoRow(
                  icon: Icons.notes_rounded,
                  title: "Writer Note",
                  value: writerNote,
                ),
                if (changeRequestText.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  changeRequestCard(changeRequestText),
                ],
                const SizedBox(height: 13),
                actionButtons(data),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget timelineIndicator(
      Color bgColor,
      Color iconColor,
      IconData icon,
      bool isLast,
      ) {
    return Column(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 155,
            color: purpleColor.withOpacity(0.16),
          ),
      ],
    );
  }

  Widget topVersionRow({
    required String version,
    required bool isLatest,
    required String submissionStatus,
    required Color statusBgColor,
    required Color statusTextColor,
    required IconData statusIcon,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "Version V$version",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (isLatest) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Latest",
                    style: TextStyle(
                      color: purpleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        statusChip(
          statusBgColor,
          statusTextColor,
          statusIcon,
          getReadableStatus(submissionStatus),
        ),
      ],
    );
  }

  Widget statusChip(
      Color bgColor,
      Color textColor,
      IconData icon,
      String title,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: () {
        print("$title clicked");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fileInfoCard({
    required String fileName,
    required String fileType,
    required String filePageCount,
    required String fileSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: purpleColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: purpleColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                fileType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$fileType • $filePageCount Page • ${formatFileSize(fileSize)}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.50),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        print("$title clicked");
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor.withOpacity(0.55),
            size: 18,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor.withOpacity(0.50),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget changeRequestCard(String changeRequestText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_note_rounded,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              changeRequestText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
                height: 1.30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButtons(Map<String, dynamic> data) {
    String filePath = data['filePath']?.toString() ?? "";
    String fileName = data['fileName']?.toString() ?? "writer_submission.pdf";

    bool isOpeningThisFile = openingFilePath == filePath;
    bool isDownloadingThisFile = downloadingFilePath == filePath;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: isOpeningThisFile || isDownloadingThisFile
                  ? null
                  : () async {
                print("Open version file clicked");
                print("FILE PATH: $filePath");

                if (filePath.trim().isEmpty) {
                  ToastHelper.show("File path missing", context);
                  return;
                }

                setState(() {
                  openingFilePath = filePath;
                });

                try {
                  final signedUrl = await getWriterFileSignedUrlByPath(
                    orderId: widget.orderId,
                    filePath: filePath,
                  );

                  if (!mounted) return;

                  if (signedUrl == null || signedUrl.isEmpty) {
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
                } catch (e) {
                  print("Open history PDF error: $e");
                  ToastHelper.show("Unable to open PDF", context);
                } finally {
                  if (mounted) {
                    setState(() {
                      openingFilePath = null;
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
              child: isOpeningThisFile
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
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
                      fontSize: 12,
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
                      fontSize: 12,
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
            height: 42,
            child: ElevatedButton(
              onPressed: isDownloadingThisFile || isOpeningThisFile
                  ? null
                  : () async {
                print("Download version file clicked");
                print("FILE PATH: $filePath");

                if (filePath.trim().isEmpty) {
                  ToastHelper.show("File path missing", context);
                  return;
                }

                setState(() {
                  downloadingFilePath = filePath;
                });

                try {
                  final signedUrl = await getWriterFileSignedUrlByPath(
                    orderId: widget.orderId,
                    filePath: filePath,
                  );

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
                  print("Download history PDF error: $e");
                  ToastHelper.show("Download failed", context);
                } finally {
                  if (mounted) {
                    setState(() {
                      downloadingFilePath = null;
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
              child: isDownloadingThisFile
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 7),
                  Text(
                    "Saving...",
                    style: TextStyle(
                      fontSize: 12,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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

  Widget noHistoryLayout() {
    return Center(
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
                Icons.history_rounded,
                color: purpleColor,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "No submission history",
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "All uploaded versions will appear here after writer submissions.",
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

  Color getStatusBgColor(String status) {
    if (status == "ON_REVIEW" || status == "REVIEW") {
      return const Color(0xFFFFF2D9);
    }

    if (status == "CHANGES_REQUESTED") {
      return const Color(0xFFFFE9EC);
    }

    if (status == "COMPLETED" || status == "ACCEPTED") {
      return const Color(0xFFE9F8EF);
    }

    return const Color(0xFFEDE8FF);
  }

  Color getStatusTextColor(String status) {
    if (status == "ON_REVIEW" || status == "REVIEW") {
      return Colors.orange.shade700;
    }

    if (status == "CHANGES_REQUESTED") {
      return Colors.red.shade600;
    }

    if (status == "COMPLETED" || status == "ACCEPTED") {
      return Colors.green.shade700;
    }

    return purpleColor;
  }

  IconData getStatusIcon(String status) {
    if (status == "ON_REVIEW" || status == "REVIEW") {
      return Icons.hourglass_top_rounded;
    }

    if (status == "CHANGES_REQUESTED") {
      return Icons.edit_note_rounded;
    }

    if (status == "COMPLETED" || status == "ACCEPTED") {
      return Icons.check_circle_outline_rounded;
    }

    return Icons.upload_file_rounded;
  }

  String formatDateTime(String value) {
    try {
      DateTime dateTime = DateTime.parse(value);

      String day = dateTime.day.toString().padLeft(2, "0");
      String month = monthName(dateTime.month.toString().padLeft(2, "0"));

      int hour = dateTime.hour;
      int minute = dateTime.minute;

      String amPm = hour >= 12 ? "PM" : "AM";
      int displayHour = hour % 12;

      if (displayHour == 0) {
        displayHour = 12;
      }

      String minuteText = minute.toString().padLeft(2, "0");

      return "$day $month, $displayHour:$minuteText $amPm";
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

  String getCleanPdfFileName({
    required String fileName,
    required String signedUrl,
  }) {
    String cleanFileName = fileName.trim();

    if (cleanFileName.isEmpty ||
        cleanFileName.toLowerCase() == "null" ||
        cleanFileName == "Uploaded work file") {
      try {
        final uri = Uri.parse(signedUrl);

        if (uri.pathSegments.isNotEmpty) {
          cleanFileName = Uri.decodeComponent(uri.pathSegments.last);
        }
      } catch (e) {
        print("File name parse error: $e");
      }
    }

    if (cleanFileName.isEmpty || cleanFileName.toLowerCase() == "null") {
      cleanFileName =
      "writer_submission_${DateTime.now().millisecondsSinceEpoch}.pdf";
    }

    cleanFileName = cleanFileName.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      "_",
    );

    if (!cleanFileName.toLowerCase().endsWith(".pdf")) {
      cleanFileName = "$cleanFileName.pdf";
    }

    return cleanFileName;
  }

  Future<String?> getWriterFileSignedUrlByPath({
    required int orderId,
    required String filePath,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("ADMIN NOT LOGGED IN");
        return null;
      }

      final token = await user.getIdToken(true);

      if (token == null || token.isEmpty) {
        print("TOKEN NOT FOUND");
        return null;
      }

      final encodedPath = Uri.encodeComponent(filePath.trim());

      final url =
          "${apiConfig.baseUrl}/api/admin/files/$orderId/file-url-by-path?filePath=$encodedPath";

      print("ADMIN SIGNED URL BY PATH API: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("ADMIN SIGNED URL BY PATH STATUS: ${response.statusCode}");
      print("ADMIN SIGNED URL BY PATH BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["url"] != null) {
          return data["url"].toString();
        }
      }

      return null;
    } catch (e) {
      print("ADMIN SIGNED URL BY PATH ERROR: $e");
      return null;
    }
  }

  Future<void> downloadPdfFromSignedUrl({
    required String signedUrl,
    required String fileName,
  }) async {
    try {
      ToastHelper.show("Download started", context);

      String cleanFileName = getCleanPdfFileName(
        fileName: fileName,
        signedUrl: signedUrl,
      );

      final response = await http.get(Uri.parse(signedUrl));

      print("DOWNLOAD HTTP STATUS: ${response.statusCode}");
      print("DOWNLOAD BYTES: ${response.bodyBytes.length}");

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception("Download failed");
      }

      if (Platform.isAndroid) {
        await MediaStore.ensureInitialized();
        MediaStore.appFolder = "Likho";

        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdk = androidInfo.version.sdkInt;

        if (sdk <= 28) {
          final permission = await Permission.storage.request();

          if (!permission.isGranted) {
            ToastHelper.show("Storage permission denied", context);
            return;
          }
        }

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

        try {
          await MediaScanner.loadMedia(path: tempFile.path);
        } catch (e) {
          print("Media scanner error: $e");
        }

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
}