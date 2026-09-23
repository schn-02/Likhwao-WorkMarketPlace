class AdminDetailsResponse {
  final int? id;
  final String? firebaseUid;
  final String? email;
  final String? name;
  final String? phone;
  final String? role;
  final bool detailsCompleted;
  final String? createdAt;

  AdminDetailsResponse({
    this.id,
    this.firebaseUid,
    this.email,
    this.name,
    this.phone,
    this.role,
    required this.detailsCompleted,
    this.createdAt,
  });

  factory AdminDetailsResponse.fromJson(Map<String, dynamic> json) {
    return AdminDetailsResponse(
      id: json["id"],
      firebaseUid: json["firebaseUid"],
      email: json["email"],
      name: json["name"],
      phone: json["phone"],
      role: json["role"],
      detailsCompleted: json["detailsCompleted"] == true ||
          json["details_completed"] == true ||
          json["detailsCompleted"] == "true" ||
          json["details_completed"] == "true",
      createdAt: json["createdAt"]?.toString(),
    );
  }
}