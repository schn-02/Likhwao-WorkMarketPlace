class ChatMessageRequestModel {
  final int orderId;
  final String receiverFirebaseUid;
  final String message;
  final String clientMessageId;

  ChatMessageRequestModel({
    required this.orderId,
    required this.receiverFirebaseUid,
    required this.message,
    required this.clientMessageId,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "receiverFirebaseUid": receiverFirebaseUid,
      "message": message,
      "clientMessageId": clientMessageId,
    };
  }
}