class CreateOrderResponse {
  final String razorpayOrderId;
  final int amount;
  final String currency;

  CreateOrderResponse({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      razorpayOrderId: json['razorpayOrderId'],
      amount: json['amount'],
      currency: json['currency'],
    );
  }
}
