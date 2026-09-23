
class Ordersviewdetailsmodel {
  final int orderId;

  final String writerSubmissionVersion;

  final String orderStatus;
  final String writerAssignmentStatus;
  final String statusLabel;

  final String userName;
  final String userNumber;
  final String userFirebaseUid;

  final String writerName;
  final String writerFirebaseUid;

  final String fileName;
  final String userFileUrl;
  final String userFilePath;
  final int filePageCount;
  final int fileSize;

  final String writerSubmissionFileName;
  final String writerSubmissionFileUrl;
  final String writerSubmissionFilePath;
  final String writerSubmissionVideoUrl;
  final String writerSubmissionText;
  final String writerSubmittedAt;

  final String typeOfWork;
  final String selectedLanguage;
  final String selectedInkColor;
  final String selectedNotebook;
  final String workToBeDone;
  final String writerSuggestionText;

  final String deliveryPickupOption;
  final String deliveryAddress;

  final String urgency;
  final String deadline;

  final int orderPageCountAmount;
  final int urgencyAmount;
  final int deliveryChargesAmount;
  final int platformFeeAmount;
  final int noteBookChargesAmount;
  final int totalOrderAmount;

  final String paymentStatus;
  final String paymentMethod;
  final String paymentBank;

  final String orderCreatedAt;
  final String orderCompletedAt;



  Ordersviewdetailsmodel({
    required this.orderId,
    required this.writerSubmissionVersion,
    required this.orderStatus,
    required this.writerAssignmentStatus,
    required this.statusLabel,
    required this.userName,
    required this.userNumber,
    required this.userFirebaseUid,
    required this.writerName,
    required this.writerFirebaseUid,
    required this.fileName,
    required this.userFileUrl,
    required this.userFilePath,
    required this.filePageCount,
    required this.fileSize,
    required this.writerSubmissionFileName,
    required this.writerSubmissionFileUrl,
    required this.writerSubmissionFilePath,
    required this.writerSubmissionVideoUrl,
    required this.writerSubmissionText,
    required this.writerSubmittedAt,
    required this.typeOfWork,
    required this.selectedLanguage,
    required this.selectedInkColor,
    required this.selectedNotebook,
    required this.workToBeDone,
    required this.writerSuggestionText,
    required this.deliveryPickupOption,
    required this.deliveryAddress,
    required this.urgency,
    required this.deadline,
    required this.orderPageCountAmount,
    required this.urgencyAmount,
    required this.deliveryChargesAmount,
    required this.platformFeeAmount,
    required this.noteBookChargesAmount,
    required this.totalOrderAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paymentBank,
    required this.orderCreatedAt,
    required this.orderCompletedAt,

  });

  factory Ordersviewdetailsmodel.fromJson(Map<String, dynamic> json) {
    return Ordersviewdetailsmodel(

      orderId: _toInt(json["orderId"]),


      writerSubmissionVersion: _toString(json["writerSubmissionVersion"]),

      orderStatus: _toString(json["orderStatus"]),
      writerAssignmentStatus: _toString(json["writerAssignmentStatus"]),
      statusLabel: _toString(json["statusLabel"]),

      userName: _toString(json["userName"]),
      userNumber: _toString(json["userNumber"]),
      userFirebaseUid: _toString(json["userFirebaseUid"]),

      writerName: _toString(json["writerName"]),
      writerFirebaseUid: _toString(json["writerFirebaseUid"]),

      fileName: _toString(json["fileName"]),
      userFileUrl: _toString(json["userFileUrl"]),
      userFilePath: _toString(json["userFilePath"]),
      filePageCount: _toInt(json["filePageCount"]),
      fileSize: _toInt(json["fileSize"]),

      writerSubmissionFileName: _toString(json["writerSubmissionFileName"]),
      writerSubmissionFileUrl: _toString(json["writerSubmissionFileUrl"]),
      writerSubmissionFilePath: _toString(json["writerSubmissionFilePath"]),
      writerSubmissionVideoUrl: _toString(json["writerSubmissionVideoUrl"]),
      writerSubmissionText: _toString(json["writerSubmissionText"]),
      writerSubmittedAt: _toString(json["writerSubmittedAt"]),

      typeOfWork: _toString(json["typeOfWork"]),
      selectedLanguage: _toString(json["selectedLanguage"]),
      selectedInkColor: _toString(json["selectedInkColor"]),
      selectedNotebook: _toString(json["selectedNotebook"]),
      workToBeDone: _toString(json["workToBeDone"]),
      writerSuggestionText: _toString(json["writerSuggestionText"]),

      deliveryPickupOption: _toString(json["deliveryPickupOption"]),
      deliveryAddress: _toString(json["deliveryAddress"]),

      urgency: _toString(json["urgency"]),
      deadline: _toString(json["deadline"]),

      orderPageCountAmount: _toInt(json["orderPageCountAmount"]),
      urgencyAmount: _toInt(json["urgencyAmount"]),
      deliveryChargesAmount: _toInt(json["deliveryChargesAmount"]),
      platformFeeAmount: _toInt(json["platformFeeAmount"]),
      noteBookChargesAmount: _toInt(json["noteBookChargesAmount"]),
      totalOrderAmount: _toInt(json["totalOrderAmount"]),

      paymentStatus: _toString(json["paymentStatus"]),
      paymentMethod: _toString(json["paymentMethod"]),
      paymentBank: _toString(json["paymentBank"]),

      orderCreatedAt: _toString(json["orderCreatedAt"]),
      orderCompletedAt: _toString(json["orderCompletedAt"]),
    );
  }

  static String _toString(dynamic value) {
    if (value == null) return "";
    final text = value.toString();
    if (text.toLowerCase() == "null") return "";
    return text;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}