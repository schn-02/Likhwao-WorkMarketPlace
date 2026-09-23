class Writerchatlistmodel {
  final int? userId;
  final int? writerId;
  final int? orderId;

  final String? writerName;
  final String? writerLastMessage;

  final String? writerNumber;
  final String? countryCode;
  final String? countryName;

  final DateTime? createdAt;

  final int? totalOrders;

  final String? writerFirebaseUid;

  final String? orderStatus;
  Writerchatlistmodel({
    this.userId,
    this.writerId,
    this.orderId,
    this.writerName,
    this.writerLastMessage,
    this.writerNumber,
    this.countryCode,
    this.countryName,
    this.createdAt,
    this.totalOrders,
    this.writerFirebaseUid,
    this.orderStatus,
  });

  factory Writerchatlistmodel.fromJson(Map<String, dynamic> json) {
    return Writerchatlistmodel(
      userId: json['userId'],
      writerId: json['writerId'],
      orderId: json['orderId'],

      writerName: json['writerName'],
      writerLastMessage: json['writerLastMessage'],

      writerNumber: json['writerNumber'],
      countryCode: json['countryCode'],
      countryName: json['countryName'],

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      totalOrders: json['totalOrders'],
      writerFirebaseUid: json['writerFirebaseUid'],
      orderStatus: json['orderStatus'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'writerId': writerId,
      'orderId': orderId,
      'writerName': writerName,
      'writerLastMessage': writerLastMessage,
      'writerNumber': writerNumber,
      'countryCode': countryCode,
      'countryName': countryName,
      'createdAt': createdAt?.toIso8601String(),
      'totalOrders': totalOrders,
      'writerFirebaseUid': writerFirebaseUid,
      'orderStatus': orderStatus,
    };
  }


}