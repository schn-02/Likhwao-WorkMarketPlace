class FeedbackResponseModel {
  final bool success;
  final String message;

  FeedbackResponseModel({
    required this.success,
    required this.message,
  });

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(
      success: json["success"] ?? false,
      message: json["message"]?.toString() ?? "",
    );
  }
}