class RaiseDisputeRequestModel {
  final String reason;
  final String message;

  RaiseDisputeRequestModel({
    required this.reason,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "reason": reason,
      "message": message,
    };
  }
}

class RaiseDisputeResponseModel {
  final String status;
  final String message;
  final int? disputeId;
  final int? orderId;
  final String? disputeStatus;
  final String? orderStatus;
  final String? writerSubmissionVersion;

  RaiseDisputeResponseModel({
    required this.status,
    required this.message,
    this.disputeId,
    this.orderId,
    this.disputeStatus,
    this.orderStatus,
    this.writerSubmissionVersion,
  });

  factory RaiseDisputeResponseModel.fromJson(Map<String, dynamic> json) {
    return RaiseDisputeResponseModel(
      status: json["status"]?.toString() ?? "",
      message: json["message"]?.toString() ?? "",
      disputeId: json["disputeId"] is int
          ? json["disputeId"]
          : int.tryParse(json["disputeId"]?.toString() ?? ""),
      orderId: json["orderId"] is int
          ? json["orderId"]
          : int.tryParse(json["orderId"]?.toString() ?? ""),
      disputeStatus: json["disputeStatus"]?.toString(),
      orderStatus: json["orderStatus"]?.toString(),
      writerSubmissionVersion: json["writerSubmissionVersion"]?.toString(),
    );
  }
}