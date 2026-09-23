import 'dart:core';

class Writerworkmodel {


  final int? UserOrderId;
  final int? writerWorkId;

  // File info
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final int? filePageCount;

  // Order details
  final String? typeOfWork;
  final String? writerSuggestionText;
  final String? selectedDeadLineUrgency;
  final DateTime? selectedDate;

  // Address
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;

  // Amount
  final int? orderPageCountAmount;
  final int? urgencyAmount;
  final int? totalOrderAmount;

  // Status
  final String? orderStatus;
  final int? writerId;
  final String? cancellationReason;

  final DateTime? orderCreatedAt;
  final DateTime? orderCompletedAt;
  final DateTime? orderCompletedAtReview;

  final String? writerAssignmentStatus;

  final int? userId;
  final String? writerFirebaseUid;
  final String? selectedInkColor;
  final String? selectedNotebook;


  final int? deliveryChargesAmount;
  final int? platformFeeAmount;
  final int?  noteBookChargesAmount;


  //Payment
  final String? razorpayOrderId;
  final String? paymentId;
  final String? paymentStatus;

  final String? paymentMethod;   // UPI / CARD
  final String ?paymentBank;

//Refund
  final String ?refundStatus;   // UPI / CARD
  final String ?refundId;

  final String ?userFileUrl;
  final String ?userFileName;

  final int?  userFileSize;
  final int ?userFilePageCount;

  final String? userSuggestionText;

  final String? UserRequestChangeDescription;


  Writerworkmodel({
  this.UserOrderId,
  this.writerWorkId,
  this.fileName,
  this.fileUrl,
  this.fileSize,
  this.filePageCount,
  this.typeOfWork,
  this.writerSuggestionText,
  this.selectedDeadLineUrgency,
  this.selectedDate,
  this.deliveryAddress,
  this.latitude,
  this.longitude,
  this.orderPageCountAmount,
  this.urgencyAmount,
  this.totalOrderAmount,
  this.orderStatus,
  this.writerId,
  this.cancellationReason,
  this.orderCreatedAt,
  this.orderCompletedAt,
  this.orderCompletedAtReview,
  this.writerAssignmentStatus,
  this.userId,
  this.writerFirebaseUid,
  this.selectedInkColor,
  this.selectedNotebook,

    this.deliveryChargesAmount,
    this.platformFeeAmount,
    this.noteBookChargesAmount,


    //Payment
    this.razorpayOrderId,
    this.paymentId,
    this.paymentStatus,

    this.paymentMethod,   // UPI / CARD
    this.paymentBank,

//Refund
    this.refundStatus,   // UPI / CARD
    this.refundId,
    this.userFileUrl,
    this.userFileName,
    this.userFileSize,
    this.userFilePageCount,

    this.userSuggestionText,
    this.UserRequestChangeDescription
  });


  factory Writerworkmodel.fromJson(Map<String, dynamic> json) {
  return Writerworkmodel(
    UserOrderId: json['UserOrderId'],
    writerWorkId: json['writerWorkId'],
  fileName: json['fileName'],
  fileUrl: json['fileUrl'],
  fileSize: json['fileSize'],
  filePageCount: json['filePageCount'],
  typeOfWork: json['typeOfWork'],
  writerSuggestionText: json['writerSuggestionText'],
  selectedDeadLineUrgency: json['selectedDeadLineUrgency'],
  selectedDate: json['selectedDate'] != null
  ? DateTime.parse(json['selectedDate'])
      : null,
  deliveryAddress: json['deliveryAddress'],
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  orderPageCountAmount: json['orderPageCountAmount'],
  urgencyAmount: json['urgencyAmount'],
  totalOrderAmount: json['totalOrderAmount'],
  orderStatus: json['orderStatus'],
  writerId: json['writerId'],
  cancellationReason: json['cancellationReason'],
  orderCreatedAt: json['orderCreatedAt'] != null
  ? DateTime.parse(json['orderCreatedAt'])
      : null,
  orderCompletedAt: json['orderCompletedAt'] != null
  ? DateTime.parse(json['orderCompletedAt'])
      : null,
  orderCompletedAtReview: json['orderCompletedAt_Review'] != null
  ? DateTime.parse(json['orderCompletedAt_Review'])
      : null,
  writerAssignmentStatus: json['writerAssignmentStatus'],
  userId: json['userId'],
  writerFirebaseUid: json['writerFirebaseUid'],
    selectedInkColor: json['selectedInkColor'],
    selectedNotebook: json['selectedNotebook'],

    deliveryChargesAmount:
    (json['deliveryChargesAmount'] as num?)!.toInt(),
    platformFeeAmount:
    (json['platformFeeAmount'] as num?)!.toInt(),
    noteBookChargesAmount:
    (json['noteBookChargesAmount'] as num?)?.toInt(),

    userFileSize:
    (json['userFileSize'] as num?)?.toInt(),
    userFilePageCount:
    (json['userFilePageCount'] as num?)?.toInt(),

    razorpayOrderId: json['razorpayOrderId'],
    paymentId: json['paymentId'],
    paymentStatus: json['paymentStatus'],
    paymentMethod: json['paymentMethod'],
    paymentBank: json['paymentBank'],

    refundStatus: json['refundStatus'],
    refundId: json['refundId'],
    userFileUrl: json['userFileUrl'],
    userFileName: json['userFileName'],
    userSuggestionText: json['userSuggestionText'],
    UserRequestChangeDescription: json['UserRequestChangeDescription'],



  );
  }


  Map<String, dynamic> toJson() {
  return {
  'UserOrderId': UserOrderId,
  'writerWorkId': writerWorkId,
  'fileName': fileName,
  'fileUrl': fileUrl,
  'fileSize': fileSize,
  'filePageCount': filePageCount,
  'typeOfWork': typeOfWork,
  'writerSuggestionText': writerSuggestionText,
  'selectedDeadLineUrgency': selectedDeadLineUrgency,
  'selectedDate': selectedDate?.toIso8601String(),
  'deliveryAddress': deliveryAddress,
  'latitude': latitude,
  'longitude': longitude,
  'orderPageCountAmount': orderPageCountAmount,
  'urgencyAmount': urgencyAmount,
  'totalOrderAmount': totalOrderAmount,
  'orderStatus': orderStatus,
  'writerId': writerId,
  'cancellationReason': cancellationReason,
  'orderCreatedAt': orderCreatedAt?.toIso8601String(),
  'orderCompletedAt': orderCompletedAt?.toIso8601String(),
  'orderCompletedAt_Review':
  orderCompletedAtReview?.toIso8601String(),
  'writerAssignmentStatus': writerAssignmentStatus,
  'userId': userId,
  'writerFirebaseUid': writerFirebaseUid,
  'selectedInkColor': selectedInkColor,
  'selectedNotebook': selectedNotebook,


    'deliveryChargesAmount': deliveryChargesAmount,
    'platformFeeAmount': platformFeeAmount,
    'noteBookChargesAmount': noteBookChargesAmount,

    'razorpayOrderId': razorpayOrderId,
    'paymentId': paymentId,
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'paymentBank': paymentBank,

    'refundStatus': refundStatus,
    'refundId': refundId,
    'userFileUrl': userFileUrl,
    'userFileName': userFileName,
    'userFileSize': userFileSize,
    'userFilePageCount': userFilePageCount,
    'userSuggestionText': userSuggestionText,
    'UserRequestChangeDescription': UserRequestChangeDescription,

  };
  }

}