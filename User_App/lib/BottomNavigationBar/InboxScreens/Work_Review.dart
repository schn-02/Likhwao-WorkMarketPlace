import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:likhwao/BottomNavigationBar/InboxScreens/WorkSummary.dart';
import 'package:likhwao/Model/WriterChatListModel.dart';
import 'package:likhwao/Model/WriterWorkModel.dart';

class WorkReview extends StatefulWidget {
  final List<Writerchatlistmodel> order;

  const WorkReview({
    super.key,
    required this.order,
  });

  @override
  State<WorkReview> createState() => _WorkReviewState();
}

class _WorkReviewState extends State<WorkReview> {
  Stream<QuerySnapshot>? reviewOrderStream;

  final Color bgColor = const Color(0xFF020B2D);
  final Color cardColor = const Color(0xFF07143D);
  final Color innerCardColor = const Color(0xFF101B4D);
  final Color orangeColor = const Color(0xffFF6A00);
  final Color purpleColor = const Color(0xFF8D5CFF);
  final Color lightPurpleColor = const Color(0xFFB58CFF);

  @override
  void initState() {
    super.initState();
    fetchLatestReviewWorkFromFirebase();
  }

  void fetchLatestReviewWorkFromFirebase() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final uid = user.uid;

    reviewOrderStream = FirebaseFirestore.instance
        .collection("orders")
        .where("userFirebaseUid", isEqualTo: uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        color: bgColor,
        child: StreamBuilder<QuerySnapshot>(
          stream: reviewOrderStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("USER REVIEW FIREBASE ERROR: ${snapshot.error}");

              return Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xffFF7A00),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _emptyWorkReview();
            }

            final reviewDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status']?.toString() ?? "";
              final latestSubmissionStatus =
                  data['latestSubmissionStatus']?.toString() ?? "";

              return status == "REVIEW" ||
                  status == "REQUEST_CHANGES" ||
                  latestSubmissionStatus == "ON_REVIEW" ||
                  latestSubmissionStatus == "CHANGES_REQUESTED";
            }).toList();

            if (reviewDocs.isEmpty) {
              return _emptyWorkReview();
            }

            reviewDocs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;

              final aTime = _getDateTimeFromAny(
                aData['latestSubmissionUploadedAt'],
              );

              final bTime = _getDateTimeFromAny(
                bData['latestSubmissionUploadedAt'],
              );

              return bTime.compareTo(aTime);
            });

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              itemCount: reviewDocs.length,
              itemBuilder: (context, index) {
                final data = reviewDocs[index].data() as Map<String, dynamic>;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    openWorkSummary(data);
                  },
                  child: sampleLayoutChatList(data),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void openWorkSummary(Map<String, dynamic> data) {
    final work = createWriterWorkModelFromFirebase(data);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Worksummary(work: work),
      ),
    );
  }

  Widget _emptyWorkReview() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: lightPurpleColor.withOpacity(0.35),
                ),
              ),
              child: Icon(
                Icons.rate_review_outlined,
                color: lightPurpleColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No work for review",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              "Writer uploads will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sampleLayoutChatList(Map<String, dynamic> data) {
    final String orderId = getValueFromData(
      data,
      ["orderId"],
      "N/A",
    );

    final String typeOfWork = getValueFromData(
      data,
      ["typeOfWork"],
      "Handwritten Work",
    );

    final String status = getValueFromData(
      data,
      ["latestSubmissionStatus", "status"],
      "ON_REVIEW",
    );

    final String version = getValueFromData(
      data,
      ["latestSubmissionVersion"],
      "1",
    );

    final String fileName = getValueFromData(
      data,
      ["latestSubmissionFileName"],
      "Uploaded work file",
    );

    final String deadline = formatDateFromAny(
      data['deadline'] ?? data['selectedDate'],
      "Not set",
    );

    final String lastUpdate = formatDateFromAny(
      data['latestSubmissionUploadedAt'],
      "Not available",
    );

    final Color statusColor = _getStatusColor(status);
    final bool isChangesRequested = _isChangesRequested(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isChangesRequested
              ? orangeColor.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isChangesRequested
                ? orangeColor.withOpacity(0.08)
                : Colors.black.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardTopLayout(
            orderId: orderId,
            typeOfWork: typeOfWork,
            version: version,
            status: status,
            statusColor: statusColor,
            isChangesRequested: isChangesRequested,
          ),

          const SizedBox(height: 11),

          fileInfoLayout(
            fileName: fileName,
            isChangesRequested: isChangesRequested,
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _infoBox(
                  icon: Icons.calendar_month_rounded,
                  title: "Deadline",
                  value: deadline,
                  color: const Color(0xffFFB000),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _infoBox(
                  icon: Icons.update_rounded,
                  title: "Updated",
                  value: lastUpdate,
                  color: const Color(0xff23C552),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _reviewProgress(status),

          if (isChangesRequested) ...[
            const SizedBox(height: 11),
            changesRequestedMessageCard(),
          ],

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _orangeButton(
                  text: "View Work",
                  icon: Icons.remove_red_eye_rounded,
                  onTap: () {
                    openWorkSummary(data);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineButton(
                  text: isChangesRequested ? "View Status" : "Open Review",
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () {
                    openWorkSummary(data);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cardTopLayout({
    required String orderId,
    required String typeOfWork,
    required String version,
    required String status,
    required Color statusColor,
    required bool isChangesRequested,
  }) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isChangesRequested
                  ? const [
                Color(0xffff7a00),
                Color(0xffff3d3d),
              ]
                  : const [
                Color(0xFF8D5CFF),
                Color(0xFF4B1AB8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: isChangesRequested
                    ? orangeColor.withOpacity(0.22)
                    : purpleColor.withOpacity(0.22),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            isChangesRequested
                ? Icons.edit_note_rounded
                : Icons.description_rounded,
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
                "Order #$orderId",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                "$typeOfWork • V$version",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        statusChip(
          status: status,
          statusColor: statusColor,
        ),
      ],
    );
  }

  Widget statusChip({
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor.withOpacity(0.42),
        ),
      ),
      child: Text(
        _cleanStatus(status),
        style: TextStyle(
          color: statusColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget fileInfoLayout({
    required String fileName,
    required bool isChangesRequested,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: isChangesRequested
                  ? orangeColor.withOpacity(0.16)
                  : lightPurpleColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: isChangesRequested ? orangeColor : lightPurpleColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  "Latest writer submission",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget changesRequestedMessageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: orangeColor.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: orangeColor.withOpacity(0.32),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: orangeColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Waiting for writer's next upload.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 31,
            width: 31,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewProgress(String status) {
    bool isChangesRequested = _isChangesRequested(status);
    bool isCompleted = _isCompleted(status);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          _progressStep(
            title: "Uploaded",
            isDone: true,
            isActive: false,
          ),
          _progressLine(true),
          _progressStep(
            title: "Review",
            isDone: isCompleted,
            isActive: !isCompleted && !isChangesRequested,
          ),
          _progressLine(isCompleted),
          _progressStep(
            title: isChangesRequested ? "Changes" : "Done",
            isDone: isCompleted,
            isActive: isChangesRequested,
          ),
        ],
      ),
    );
  }

  Widget _progressStep({
    required String title,
    required bool isDone,
    required bool isActive,
  }) {
    Color circleColor = const Color(0xFF18265C);
    IconData icon = Icons.circle_outlined;

    if (isDone) {
      circleColor = const Color(0xff23C552);
      icon = Icons.check_rounded;
    } else if (isActive) {
      circleColor = const Color(0xffFFB000);
      icon = Icons.circle;
    }

    return Column(
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isActive ? 10 : 17,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 10.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _progressLine(bool active) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
        height: 2.4,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xff23C552)
              : Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _orangeButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xffFF7A00),
              Color(0xffFF4D00),
            ],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: orangeColor.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.8,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: orangeColor.withOpacity(0.85),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.8,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              color: Colors.white,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final upperStatus = status.toUpperCase();

    if (upperStatus.contains("COMPLETED") ||
        upperStatus.contains("ACCEPTED")) {
      return const Color(0xff23C552);
    }

    if (upperStatus.contains("CHANGE")) {
      return orangeColor;
    }

    if (upperStatus.contains("REVIEW")) {
      return const Color(0xff2F80ED);
    }

    if (upperStatus.contains("PROGRESS")) {
      return const Color(0xffFFB000);
    }

    return lightPurpleColor;
  }

  bool _isChangesRequested(String status) {
    final upperStatus = status.toUpperCase();

    return upperStatus.contains("CHANGE") ||
        upperStatus.contains("REQUEST_CHANGES") ||
        upperStatus.contains("CHANGES_REQUESTED");
  }

  bool _isCompleted(String status) {
    final upperStatus = status.toUpperCase();

    return upperStatus.contains("COMPLETED") ||
        upperStatus.contains("ACCEPTED");
  }

  String _cleanStatus(String status) {
    if (status == "ON_REVIEW") {
      return "REVIEW";
    }

    if (status == "CHANGES_REQUESTED") {
      return "CHANGES";
    }

    if (status == "REQUEST_CHANGES") {
      return "CHANGES";
    }

    return status.replaceAll("_", " ").replaceAll("-", " ").toUpperCase();
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

  String formatDateFromAny(dynamic value, String fallback) {
    try {
      if (value == null) {
        return fallback;
      }

      if (value is Timestamp) {
        return DateFormat('dd MMM yyyy').format(value.toDate());
      }

      if (value is DateTime) {
        return DateFormat('dd MMM yyyy').format(value);
      }

      String text = value.toString();

      if (text.trim().isEmpty || text == "null") {
        return fallback;
      }

      DateTime? dateTime = DateTime.tryParse(text);

      if (dateTime == null) {
        return fallback;
      }

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return value?.toString() ?? fallback;
    }
  }

  DateTime _getDateTimeFromAny(dynamic value) {
    try {
      if (value == null) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      return DateTime.tryParse(value.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    } catch (e) {
      return DateTime.fromMillisecondsSinceEpoch(0);
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

  double parseDoubleValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  DateTime? parseDateValue(dynamic value) {
    try {
      if (value == null) {
        return null;
      }

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      String text = value.toString().trim();

      if (text.isEmpty || text == "null") {
        return null;
      }

      return DateTime.tryParse(text);
    } catch (e) {
      print("Date parse error: $e");
      return null;
    }
  }

  Writerworkmodel createWriterWorkModelFromFirebase(
      Map<String, dynamic> data,
      ) {
    final int orderId = parseIntValue(
      getValueFromData(
        data,
        ["orderId"],
        "0",
      ),
    );

    final int latestWriterWorkId = parseIntValue(
      getValueFromData(
        data,
        ["latestWriterWorkId", "writerWorkId"],
        "0",
      ),
    );

    final int latestFilePageCount = parseIntValue(
      getValueFromData(
        data,
        ["latestSubmissionPageCount"],
        "0",
      ),
    );

    final int userFilePageCount = parseIntValue(
      getValueFromData(
        data,
        ["filePageCount", "userFilePageCount"],
        "0",
      ),
    );

    final int totalOrderAmount = parseIntValue(
      getValueFromData(
        data,
        ["totalOrderAmount"],
        "0",
      ),
    );

    final int platformFeeAmount = parseIntValue(
      getValueFromData(
        data,
        ["platformFeeAmount"],
        "0",
      ),
    );

    final int deliveryChargesAmount = parseIntValue(
      getValueFromData(
        data,
        ["deliveryChargesAmount"],
        "0",
      ),
    );

    final int noteBookChargesAmount = parseIntValue(
      getValueFromData(
        data,
        ["noteBookChargesAmount"],
        "0",
      ),
    );

    final int userId = parseIntValue(
      getValueFromData(
        data,
        ["userId"],
        "0",
      ),
    );

    final String status = getValueFromData(
      data,
      ["status", "latestSubmissionStatus"],
      "REVIEW",
    );

    return Writerworkmodel(
      writerWorkId: latestWriterWorkId,
      UserOrderId: orderId,
      fileName: getValueFromData(
        data,
        ["latestSubmissionFileName"],
        "Uploaded work file",
      ),

      fileUrl: getValueFromData(
        data,
        ["latestSubmissionFilePath"],
        "",
      ),
      fileSize: parseIntValue(
        getValueFromData(
          data,
          ["latestSubmissionFileSize"],
          "0",
        ),
      ),
      filePageCount: latestFilePageCount,
      orderCompletedAtReview: parseDateValue(
        data["latestSubmissionUploadedAt"],
      ),
      selectedDate: parseDateValue(
        data["deadline"] ?? data["selectedDate"],
      ),
      orderCreatedAt: parseDateValue(
        data["createdAt"] ?? data["orderCreatedAt"],
      ),
      orderCompletedAt: parseDateValue(
        data["completedAt"] ?? data["orderCompletedAt"],
      ),
      orderStatus: data["orderStatus"]?.toString(),
      typeOfWork: getValueFromData(
        data,
        ["typeOfWork"],
        "Handwritten Work",
      ),
      writerAssignmentStatus: status,
      totalOrderAmount: totalOrderAmount,
      selectedDeadLineUrgency:
      data["selectedDeadLineUrgency"]?.toString() ??
          data["urgency"]?.toString(),
      userId: userId,
      writerFirebaseUid: data["writerFirebaseUid"]?.toString(),
      selectedInkColor:
      data["InkColor"]?.toString() ?? data["selectedInkColor"]?.toString(),
      selectedNotebook:
      data["NotebookType"]?.toString() ??
          data["selectedNotebook"]?.toString(),
      deliveryChargesAmount: deliveryChargesAmount,
      platformFeeAmount: platformFeeAmount,
      noteBookChargesAmount: noteBookChargesAmount,
      razorpayOrderId: data["razorpayOrderId"]?.toString(),
      paymentId: data["paymentId"]?.toString(),
      paymentBank: data["paymentBank"]?.toString(),
      paymentStatus: data["paymentStatus"]?.toString(),
      paymentMethod: data["paymentMethod"]?.toString(),
      refundId: data["refundId"]?.toString(),
      refundStatus: data["refundStatus"]?.toString(),
      userFileName: data["userFileName"]?.toString(),
      userFilePageCount: userFilePageCount,
      userFileSize: parseIntValue(
        getValueFromData(
          data,
          ["fileSize", "userFileSize"],
          "0",
        ),
      ),
      writerSuggestionText: data["latestSubmissionWriterNote"]?.toString(),
      userSuggestionText:
      data["WriterSuggestionText"]?.toString() ??
          data["writerSuggestionText"]?.toString(),
    );
  }
}