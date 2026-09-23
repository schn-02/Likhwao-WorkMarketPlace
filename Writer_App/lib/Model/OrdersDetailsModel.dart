import 'dart:io';

import 'package:likho/Model/UserAddressModel.dart';

class Ordersdetailsmodel {

  int? UserOrderId;
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
  String? deliveryOption;
  String? deliveryPickupOption;
  String? selectedDeadLineUrgency;
  DateTime? selectedDate;
  String? userFirebaseUid;
  String? writerFirebaseUid;

  String? deliveryAddress;
  double? latitude;
  double? longitude;

  int? orderPageCountAmount;
  int? urgencyAmount;
  int? deliveryChargesAmount;
  int? platformFeeAmount;
  int? noteBookChargesAmount;
  int? totalOrderAmount;

  String? orderStatus;
  int? writerId;
  String? cancellationReason;

  DateTime? orderCreatedAt;
  DateTime? orderCompletedAt;

  String? writerAssignmentStatus;
  int? addressId;
  String? fullName;
  String? mobileNumber;
  String? pincode;
  String? houseNo;
  String? locality;
  String? city;
  String? state;
  String? saveAs;

  int? userId;
  String? userName;
  String? userEmail;
  String? userPhone;

  Ordersdetailsmodel({
  this.UserOrderId,
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
  this.deliveryOption,
  this.deliveryPickupOption,
  this.selectedDeadLineUrgency,
  this.selectedDate,
  this.userFirebaseUid,
  this.writerFirebaseUid,
  this.deliveryAddress,
  this.latitude,
  this.longitude,
  this.orderPageCountAmount,
  this.urgencyAmount,
  this.deliveryChargesAmount,
  this.platformFeeAmount,
  this.noteBookChargesAmount,
  this.totalOrderAmount,
  this.orderStatus,
  this.writerId,
  this.cancellationReason,
  this.orderCreatedAt,
  this.orderCompletedAt,
  this.writerAssignmentStatus,
  this.addressId,
  this.fullName,
  this.mobileNumber,
  this.pincode,
  this.houseNo,
  this.locality,
  this.city,
  this.state,
  this.saveAs,
  this.userId,
  this.userName,
  this.userEmail,
  this.userPhone,
  });

  factory Ordersdetailsmodel.fromJson(Map<String, dynamic> json) {
    return Ordersdetailsmodel(
      UserOrderId: json['UserOrderid'] as int,

      userFileUrl: json['userFileUrl'] as String?,
      userFilePath: json['userFilePath'] as String?,
      userFileName: json['userFileName'] as String?,

      userFileSize: json['userFileSize'] as int?,
      userFilePageCount: json['userFilePageCount'] as int?,


    writerFileUrl : json['writerFileUrl'] as String?,
        writerFilePath : json['writerFilePath'] as String?,
        writerFileName: json['writerFileName'] as String?,


      writerFileSize: json['writerFileSize'] as int?,
      writerFilePageCount: json['writerFilePageCount'] as int?,

      typeOfWork: json['typeOfWork'] as String?,
      languageSelectedChips: json['languageSelectedChips'] as String?,

      selectedInkColor: json['selectedInkColor'] as String?,
      selectedNotebook: json['selectedNotebook'] as String?,
      writerSuggestionText: json['writerSuggestionText'] as String?,
      deliveryOption: json['deliveryOption'] as String?,
      deliveryPickupOption: json['deliveryPickupOption'] as String?,
      selectedDeadLineUrgency: json['selectedDeadLineUrgency'] as String?,


      selectedDate: json['selectedDate'] !=null ? DateTime.parse(json['selectedDate']):null,

      userFirebaseUid: json['userFirebaseUid'] as String?,
      writerFirebaseUid: json['writerFirebaseUid'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,


      latitude: json['latitude'] == null
          ? null
          : double.tryParse(json['latitude'].toString()),

      longitude: json['longitude'] == null
          ? null
          : double.tryParse(json['longitude'].toString()),

      orderPageCountAmount: json['orderPageCountAmount'] as int?,
      urgencyAmount: json['urgencyAmount'] as int?,
      deliveryChargesAmount: json['deliveryChargesAmount'] as int?,
      platformFeeAmount: json['platformFeeAmount'] as int?,
      noteBookChargesAmount: json['noteBookChargesAmount'] as int?,
      totalOrderAmount: json['totalOrderAmount'] as int?,

      orderStatus: json['orderStatus'] as String?,
      writerId: json['writerId'] as int?,
      cancellationReason: json['cancellationReason'] as String?,


      orderCreatedAt: json['orderCreatedAt'] !=null ?DateTime.parse(json['orderCreatedAt']) : null,
      orderCompletedAt:json['orderCompletedAt']!=null ?DateTime.parse(json['orderCompletedAt']) :null,

      writerAssignmentStatus: json['writerAssignmentStatus'] as String?,
      addressId: json['Addressid'] as int?,

      fullName: json['fullName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      pincode: json['pincode'] as String?,
      houseNo: json['houseNo'] as String?,
      locality: json['locality'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      saveAs: json['saveAs'] as String?,

      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      userPhone: json['userPhone'] as String?,
    );
  }  Map<String, dynamic> toJson() {
  return {
  'UserOrderId': UserOrderId,
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


  'typeOfWork': typeOfWork,
  'languageSelectedChips': languageSelectedChips,
  'selectedInkColor': selectedInkColor,
  'selectedNotebook': selectedNotebook,
  'writerSuggestionText': writerSuggestionText,
  'deliveryOption': deliveryOption,
  'deliveryPickupOption': deliveryPickupOption,
  'selectedDeadLineUrgency': selectedDeadLineUrgency,
  'selectedDate': selectedDate?.toIso8601String(),
  'userFirebaseUid': userFirebaseUid,
  'writerFirebaseUid': writerFirebaseUid,
  'deliveryAddress': deliveryAddress,
  'latitude': latitude,
  'longitude': longitude,
  'orderPageCountAmount': orderPageCountAmount,
  'urgencyAmount': urgencyAmount,
  'deliveryChargesAmount': deliveryChargesAmount,
  'platformFeeAmount': platformFeeAmount,
  'noteBookChargesAmount': noteBookChargesAmount,
  'totalOrderAmount': totalOrderAmount,
  'orderStatus': orderStatus,
  'writerId': writerId,
  'cancellationReason': cancellationReason,
  'orderCreatedAt': orderCreatedAt?.toIso8601String(),
  'orderCompletedAt': orderCompletedAt?.toIso8601String(),
  'writerAssignmentStatus': writerAssignmentStatus,
  'Addressid': addressId,
  'fullName': fullName,
  'mobileNumber': mobileNumber,
  'pincode': pincode,
  'houseNo': houseNo,
  'locality': locality,
  'city': city,
  'state': state,
  'saveAs': saveAs,
  'userId': userId,
  'userName': userName,
  'userEmail': userEmail,
  'userPhone': userPhone,
  };
  }





}

