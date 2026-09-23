class Userchatlistmodel {
  final int? userId;
  final int? writerId;
  final int? orderId;

  final String? userName;
  final String? userLastMessage;

  final String? userNumber;
  final String? countryCode;
  final String? countryName;

  final DateTime? createdAt;

  final int? totalOrders;

  final String? userFirebaseUid;

  final String? orderStatus;

  Userchatlistmodel({
    this.userId,
    this.writerId,
    this.orderId,
    this.userName,
    this.userLastMessage,
    this.userNumber,
    this.countryCode,
    this.countryName,
    this.createdAt,
    this.totalOrders,
    this.userFirebaseUid,
    this.orderStatus,
  });

  factory Userchatlistmodel.fromJson(Map<String, dynamic> json) {
    return Userchatlistmodel(
      userId: json['userId'],
      writerId: json['writerId'],
      orderId: json['orderId'],

      userName: json['userName'],
      userLastMessage: json['userLastMessage'],

      userNumber: json['userNumber'],
      countryCode: json['countryCode'],
      countryName: json['countryName'],

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      totalOrders: json['totalOrders'],
      userFirebaseUid: json['userFirebaseUid'],
      orderStatus: json['orderStatus'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'writerId': writerId,
      'orderId': orderId,
      'userName': userName,
      'writerLastMessage': userLastMessage,
      'userNumber': userNumber,
      'countryCode': countryCode,
      'countryName': countryName,
      'createdAt': createdAt?.toIso8601String(),
      'totalOrders': totalOrders,
      'userFirebaseUid': userFirebaseUid,
      'orderStatus': orderStatus,
    };
  }


}