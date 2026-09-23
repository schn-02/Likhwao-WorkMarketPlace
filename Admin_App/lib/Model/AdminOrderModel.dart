import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrder {
  // OLD FIELDS - SAME AS YOUR EXISTING CODE
  final int orderId;
  final String docId;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String typeOfWork;
  final String selectedLanguage;
  final String urgency;
  final String userFileName;
  final int userFilePageCount;
  final int userFileSize;
  final String userFirebaseUid;
  final int userId;
  final String userName;
  final String writerFirebaseUid;
  final int writerId;
  final String writerName;
  final double totalOrderAmount;
  final double platformFeeAmount;
  final double urgencyAmount;
  final bool adminActionRequired;
  final bool hasDispute;
  final Timestamp? updatedAtTimestamp;

  // NEW EXTRA FIELDS - OPTIONAL, SO OLD CODE WILL NOT BREAK
  final String orderStatus;
  final String workToBeDone;
  final String deadline;
  final String inkColor;
  final String notebookType;
  final String deliveryPickupOption;
  final String orderTitle;
  final int filePageCount;
  final bool hasWriter;
  final bool hasWriterSubmission;
  final String latestSubmissionStatus;
  final int latestSubmissionVersion;
  final String latestWriterWorkId;
  final double orderPageCountAmount;
  final double noteBookChargesAmount;
  final double deliveryChargesAmount;
  final bool paymentRequired;
  final String writerSuggestionText;
  final Timestamp? createdAtTimestamp;
  final Timestamp? paidAtTimestamp;
  final Timestamp? statusUpdatedAtTimestamp;

  AdminOrder({
    required this.orderId,
    required this.docId,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.typeOfWork,
    required this.selectedLanguage,
    required this.urgency,
    required this.userFileName,
    required this.userFilePageCount,
    required this.userFileSize,
    required this.userFirebaseUid,
    required this.userId,
    required this.userName,
    required this.writerFirebaseUid,
    required this.writerId,
    required this.writerName,
    required this.totalOrderAmount,
    required this.platformFeeAmount,
    required this.urgencyAmount,
    required this.adminActionRequired,
    required this.hasDispute,
    required this.updatedAtTimestamp,

    // NEW OPTIONAL PARAMS
    this.orderStatus = "",
    this.workToBeDone = "",
    this.deadline = "",
    this.inkColor = "",
    this.notebookType = "",
    this.deliveryPickupOption = "",
    this.orderTitle = "",
    this.filePageCount = 0,
    this.hasWriter = false,
    this.hasWriterSubmission = false,
    this.latestSubmissionStatus = "",
    this.latestSubmissionVersion = 0,
    this.latestWriterWorkId = "",
    this.orderPageCountAmount = 0,
    this.noteBookChargesAmount = 0,
    this.deliveryChargesAmount = 0,
    this.paymentRequired = false,
    this.writerSuggestionText = "",
    this.createdAtTimestamp,
    this.paidAtTimestamp,
    this.statusUpdatedAtTimestamp,
  });

  factory AdminOrder.fromFirestore(String docId, Map<String, dynamic> json) {
    final int orderId = _toInt(json["orderId"] ?? docId);

    final String status = _toString(json["status"]).toUpperCase();
    final String paymentStatus = _toString(json["paymentStatus"]).toUpperCase();

    final String writerName = _toString(json["writerName"]);
    final String writerFirebaseUid = _toString(json["writerFirebaseUid"]);
    final int writerId = _toInt(json["writerId"]);

    final bool hasWriter = json["hasWriter"] == true ||
        writerName.trim().isNotEmpty ||
        writerFirebaseUid.trim().isNotEmpty ||
        writerId != 0;

    final int filePageCount = _toInt(
      json["filePageCount"] ?? json["userFilePageCount"],
    );

    return AdminOrder(
      // OLD REQUIRED FIELDS
      docId: docId,
      orderId: orderId,
      status: status,

      // IMPORTANT FIX: pehle tum json["status"] read kar rahe the
      statusLabel: _toString(json["statusLabel"]),

      paymentStatus: paymentStatus,
      typeOfWork: _toString(json["typeOfWork"], fallback: "Work"),
      selectedLanguage: _toString(json["selectedLanguage"], fallback: "N/A"),
      urgency: _toString(json["urgency"], fallback: "NORMAL").toUpperCase(),
      userFileName: _toString(json["userFileName"], fallback: "No file"),
      userFilePageCount: _toInt(json["userFilePageCount"]),
      userFileSize: _toInt(json["userFileSize"]),
      userFirebaseUid: _toString(json["userFirebaseUid"]),
      userId: _toInt(json["userId"]),
      userName: _getUserName(json),
      writerFirebaseUid: writerFirebaseUid,
      writerId: writerId,
      writerName: writerName,
      totalOrderAmount: _toDouble(json["totalOrderAmount"]),
      platformFeeAmount: _toDouble(json["platformFeeAmount"]),
      urgencyAmount: _toDouble(json["urgencyAmount"]),
      adminActionRequired: json["adminActionRequired"] == true,
      hasDispute: json["hasDispute"] == true,
      updatedAtTimestamp: _toTimestamp(json["updatedAtTimestamp"]),

      // NEW MERGED FIELDS
      orderStatus: _toString(json["orderStatus"]).toUpperCase(),
      workToBeDone: _toString(json["workToBeDone"], fallback: "PDF"),
      deadline: _toString(json["deadline"], fallback: "N/A"),
      inkColor: _toString(json["InkColor"], fallback: "N/A"),
      notebookType: _toString(json["NotebookType"], fallback: "N/A"),
      deliveryPickupOption: _toString(
        json["deliveryPickupOption"],
        fallback: "N/A",
      ),
      orderTitle: _toString(
        json["orderTitle"],
        fallback:
        "${_toString(json["typeOfWork"], fallback: "Order")} • $filePageCount Pages",
      ),
      filePageCount: filePageCount,
      hasWriter: hasWriter,
      hasWriterSubmission: json["hasWriterSubmission"] == true,
      latestSubmissionStatus: _toString(json["latestSubmissionStatus"]),
      latestSubmissionVersion: _toInt(json["latestSubmissionVersion"]),
      latestWriterWorkId: _toString(json["latestWriterWorkId"]),
      orderPageCountAmount: _toDouble(json["orderPageCountAmount"]),
      noteBookChargesAmount: _toDouble(json["noteBookChargesAmount"]),
      deliveryChargesAmount: _toDouble(json["deliveryChargesAmount"]),
      paymentRequired: json["paymentRequired"] == true,
      writerSuggestionText: _toString(json["WriterSuggestionText"]),
      createdAtTimestamp: _toTimestamp(json["createdAtTimestamp"]),
      paidAtTimestamp: _toTimestamp(json["paidAtTimestamp"]),
      statusUpdatedAtTimestamp: _toTimestamp(json["statusUpdatedAtTimestamp"]),
    );
  }

  // Optional helper if you directly pass QueryDocumentSnapshot
  factory AdminOrder.fromQueryDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    return AdminOrder.fromFirestore(doc.id, doc.data());
  }

  // Optional helper if you directly pass DocumentSnapshot
  factory AdminOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AdminOrder.fromFirestore(doc.id, doc.data() ?? {});
  }

  // OLD GETTER - IMPROVED BUT SAME NAME
  String get displayStatus {
    if (status == "ACCEPTED") return "Accepted";
    if (status == "IN_PROGRESS") return "In Progress";
    if (status == "REVIEW") return "Under Review";
    if (status == "DISPUTE") return "Dispute";
    if (status == "REQUEST_CHANGES") return "Request Changes";
    if (status == "COMPLETED") return "Completed";
    if (status == "REJECTED") return "Rejected";
    if (status == "FINDING_WRITER") return "Finding Writer";
    if (status == "PENDING") return "Pending";

    if (!hasWriter) return "Finding Writer";

    if (statusLabel.trim().isNotEmpty) {
      return statusLabel.trim();
    }

    return status.isEmpty ? "Unknown" : status.replaceAll("_", " ");
  }

  // NEW GETTERS FOR ORDERS PAGE
  String get orderCode {
    return "#ORD${orderId.toString().padLeft(5, "0")}";
  }

  String get amountText {
    return "₹${totalOrderAmount.toStringAsFixed(0)}";
  }

  String get pagesText {
    final int pages = filePageCount != 0 ? filePageCount : userFilePageCount;
    return "$pages Pages";
  }

  String get writerInfo {
    if (!hasWriter) return "No Writer Assigned";

    if (writerName.trim().isNotEmpty) {
      return "Writer: $writerName";
    }

    return "Writer: Assigned";
  }

  String get userDisplayName {
    if (userName.trim().isNotEmpty) return userName;

    if (userId != 0) {
      return "#USERID$userId";
    }

    return "Unknown User";
  }

  bool get isPaid {
    return paymentStatus == "PAID";
  }

  bool get isFindingWriter {
    return status == "FINDING_WRITER" ||
        status == "PENDING" ||
        hasWriter == false;
  }

  bool get isInProgress {
    return status == "ACCEPTED" || status == "IN_PROGRESS";
  }

  bool get isReviewOrDispute {
    return status == "REVIEW" ||
        status == "DISPUTE" ||
        status == "REQUEST_CHANGES" ||
        latestSubmissionStatus.toUpperCase() == "REVIEW" ||
        adminActionRequired ||
        hasDispute;
  }

  bool get isCompleted {
    return status == "COMPLETED";
  }

  Color get statusColor {
    if (status == "COMPLETED") return Colors.greenAccent;

    if (status == "REVIEW" ||
        status == "DISPUTE" ||
        status == "REQUEST_CHANGES" ||
        hasDispute ||
        adminActionRequired) {
      return Colors.redAccent;
    }

    if (status == "ACCEPTED" || status == "IN_PROGRESS") {
      return Colors.blueAccent;
    }

    if (status == "REJECTED") return Colors.redAccent;

    return Colors.orange;
  }

  bool matchesSearch(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) return true;

    return orderCode.toLowerCase().contains(q) ||
        orderId.toString().contains(q) ||
        docId.toLowerCase().contains(q) ||
        userDisplayName.toLowerCase().contains(q) ||
        userId.toString().contains(q) ||
        userFirebaseUid.toLowerCase().contains(q) ||
        writerName.toLowerCase().contains(q) ||
        writerId.toString().contains(q) ||
        writerFirebaseUid.toLowerCase().contains(q) ||
        typeOfWork.toLowerCase().contains(q) ||
        workToBeDone.toLowerCase().contains(q) ||
        selectedLanguage.toLowerCase().contains(q) ||
        urgency.toLowerCase().contains(q) ||
        displayStatus.toLowerCase().contains(q) ||
        status.toLowerCase().contains(q) ||
        paymentStatus.toLowerCase().contains(q) ||
        amountText.toLowerCase().contains(q) ||
        deadline.toLowerCase().contains(q) ||
        userFileName.toLowerCase().contains(q) ||
        inkColor.toLowerCase().contains(q) ||
        notebookType.toLowerCase().contains(q) ||
        deliveryPickupOption.toLowerCase().contains(q);
  }

  static String _getUserName(Map<String, dynamic> json) {
    final String name = _toString(json["userName"]);
    if (name.isNotEmpty) return name;

    final int userId = _toInt(json["userId"]);
    if (userId != 0) return "#USERID$userId";

    return "User";
  }

  static String _toString(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;

    final String result = value.toString().trim();

    if (result.isEmpty || result.toLowerCase() == "null") {
      return fallback;
    }

    return result;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? fallback;
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? fallback;
  }

  static Timestamp? _toTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    return null;
  }
}