class FeedbackRequestModel {
  final int orderId;
  final int userId;
  final int writerId;
  final int rating;
  final String reviewText;
  final bool anonymous;

  FeedbackRequestModel({
    required this.orderId,
    required this.userId,
    required this.writerId,
    required this.rating,
    required this.reviewText,
    required this.anonymous,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "userId": userId,
      "writerId": writerId,
      "rating": rating,
      "reviewText": reviewText,
      "anonymous": anonymous,
    };
  }
}