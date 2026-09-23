class AdminSaveDetailsRequest {
  final String name;
  final String phone;

  AdminSaveDetailsRequest({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
    };
  }
}