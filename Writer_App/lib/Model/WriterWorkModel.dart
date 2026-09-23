class Writerworkmodel {

  int ?userId;
  int? UserOrderId;
  String? fileUrl;
  String? fileName;
  int? fileSize;
  int? filePageCount;
  int? writerId;
  String? cancellationReason;
  DateTime? orderCreatedAt;
  DateTime? orderCompletedAt;
  String? writerAssignmentStatus;
  String? writerSuggestionText;

  Writerworkmodel({
    this.userId,
    this.UserOrderId,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.filePageCount,
    this.writerId,
    this.cancellationReason,
    this.orderCreatedAt,
    this.orderCompletedAt,
    this.writerAssignmentStatus,
    this.writerSuggestionText,
  });

  factory Writerworkmodel.fromJson(Map<String, dynamic> json) {

    return Writerworkmodel(
      userId: json['userId'] as int?,
      UserOrderId: json['UserOrderId'] is int
          ? json['UserOrderId']
          : int.tryParse(json['UserOrderId']?.toString() ?? ''),

      fileUrl: json['fileUrl'] as String?,

      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      filePageCount: json['filePageCount'] as int?,
      writerId: json['writerId'] as int?,
      cancellationReason: json['cancellationReason'] as String?,

      orderCreatedAt: json['orderCreatedAt'] != null
          ? DateTime.tryParse(json['orderCreatedAt'])
          : null,

      orderCompletedAt: json['orderCompletedAt'] != null
          ? DateTime.tryParse(json['orderCompletedAt'])
          : null,

      writerAssignmentStatus: json['writerAssignmentStatus'] as String?,
      writerSuggestionText: json['writerSuggestionText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'UserOrderId': UserOrderId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'filePageCount': filePageCount,
      'writerId': writerId,
      'cancellationReason': cancellationReason,
      'orderCreatedAt': orderCreatedAt?.toIso8601String(),
      'orderCompletedAt': orderCompletedAt?.toIso8601String(),
      'writerAssignmentStatus': writerAssignmentStatus,
      'writerSuggestionText': writerSuggestionText,

    };
  }
}