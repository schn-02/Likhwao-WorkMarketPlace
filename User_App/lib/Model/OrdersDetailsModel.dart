import 'dart:io';

import 'package:likhwao/Model/UserAddressModel.dart';

class Ordersdetailsmodel {

  int? UserOrderId;
  int? writerId;
  String? writerName;

  File?selectedPdfFile;

  String? userFileUrl;
  String? userFilePath;
  String? userFileName;

  int? userFileSize;
  int? userFilePageCount;

  String? writerFileUrl;
  String? writerFilePath;
  String? writerFileName;

  int? writerFileSize;
  int? writerFilePageCount;

  String? typeOfWork;
  String? languageSelectedChips;
  String? selectedInkColor;
  String? selectedNotebook;
  String? writerSuggestionText;
  String? workToBeDone;
  String? deliveryPickupOption;
  String? selectedDeadLineUrgency;
  DateTime? selectedDate;

  List<Useraddressmodel>? addressList;

  int ? orderPageCountAmount;
  int ?urgencyAmount;
  int ?deliveryChargesAmount;
  int ?platformFeeAmount;
  int?noteBookChargesAmount;
  int ? totalOrderAmount;

  String? userFirebaseUid;
  String?writerFirebaseUid;

  String?userName;
  String?userNumber;
  String?writerAssignmentStatus;


  Ordersdetailsmodel({
    this.UserOrderId,
    this.writerName,
    this.selectedPdfFile,
    this.writerId,
    this.userFileUrl,
    this.userFilePath,
    this.userFileName,
    this.userFileSize,
    this.userFilePageCount,

    this. writerFileUrl,
    this. writerFilePath,
    this. writerFileName,
    this. writerFileSize,
    this. writerFilePageCount,
    this.typeOfWork,
    this.languageSelectedChips,
    this.selectedInkColor,
    this.selectedNotebook,
    this.writerSuggestionText,
    this.workToBeDone,
    this.deliveryPickupOption,
    this.selectedDeadLineUrgency,
    this.selectedDate,
    this.addressList,
    this.deliveryChargesAmount ,
    this.platformFeeAmount,
    this.orderPageCountAmount,
    this.urgencyAmount,
    this.noteBookChargesAmount,
    this.totalOrderAmount,
    this.userFirebaseUid,
    this.writerFirebaseUid,
    this.userName,
    this.userNumber,
    this.writerAssignmentStatus,
  });



  Map<String, dynamic> toJson() {
    return {

      "writerId": writerId,
      "writerName": writerName,
      'userFileUrl': userFileUrl,
      'userFilePath': userFilePath,
      'userFileName': userFileName,
      'userFileSize': userFileSize,
      'userFilePageCount': userFilePageCount,

      'writerFileUrl': writerFileUrl,
      'writerFilePath': writerFilePath,
      'writerFileName': writerFileName,
      'writerFileSize': writerFileSize,
      'writerFilePageCount': writerFilePageCount,

      "UserOrderId": UserOrderId,
      "typeOfWork": typeOfWork,
      "languageSelectedChips": languageSelectedChips,
      "selectedInkColor": selectedInkColor,
      "selectedNotebook": selectedNotebook,
      "writerSuggestionText": writerSuggestionText,
      "workToBeDone": workToBeDone,
      "deliveryPickupOption": deliveryPickupOption,
      "selectedDeadLineUrgency": selectedDeadLineUrgency,
      "selectedDate": selectedDate?.toIso8601String(),
      "deliveryChargesAmount":deliveryChargesAmount,
      "platformFeeAmount":platformFeeAmount,
      "orderPageCountAmount":orderPageCountAmount,
      "urgencyAmount":urgencyAmount,
      "noteBookChargesAmount":noteBookChargesAmount,
      "totalOrderAmount":totalOrderAmount,
      "userFirebaseUid":userFirebaseUid,
      "writerFirebaseUid":writerFirebaseUid,
      "userName":userName,
      "userNumber":userNumber,
      "writerAssignmentStatus":writerAssignmentStatus,

      "addressList": addressList?.map((e) => e.toJson()).toList(),
    };
  }
}
