class AuthModel {
  final String firebaseUid;
  final String email;
  final String name;
  final String firebaseIdToken;

  final String deviceId;
  final String deviceModel;
  final String androidId;
  final String firebaseInstallationId;
  final String brand;
  final String manufacturer;

  final String countryCode;
  final String countryName;
  final String phoneNumber;

  final bool rooted;
  final bool emulator;
  final String appHash;

  final bool emailVerified;
  final bool detailsCompleted;

  AuthModel({
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.firebaseIdToken,
    required this.deviceId,
    required this.deviceModel,
    required this.androidId,
    required this.firebaseInstallationId,
    required this.brand,
    required this.manufacturer,
    required this.countryCode,
    required this.countryName,
    required this.phoneNumber,
    required this.rooted,
    required this.emulator,
    required this.appHash,
    required this.emailVerified,
    this.detailsCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "firebaseUid": firebaseUid,
      "email": email,
      "name": name,
      "firebaseIdToken": firebaseIdToken,

      "deviceId": deviceId,
      "deviceModel": deviceModel,
      "androidId": androidId,
      "firebaseInstallationId": firebaseInstallationId,
      "brand": brand,
      "manufacturer": manufacturer,

      "countryCode": countryCode,
      "countryName": countryName,
      "phoneNumber": phoneNumber,

      "rooted": rooted,
      "emulator": emulator,
      "appHash": appHash,

      "emailVerified": emailVerified,
      "detailsCompleted": detailsCompleted,
    };
  }

  @override
  String toString() {
    return 'AuthModel{'
        'firebaseUid: $firebaseUid, '
        'email: $email, '
        'name: $name, '
        'firebaseIdToken: $firebaseIdToken, '
        'deviceId: $deviceId, '
        'deviceModel: $deviceModel, '
        'androidId: $androidId, '
        'firebaseInstallationId: $firebaseInstallationId, '
        'brand: $brand, '
        'manufacturer: $manufacturer, '
        'countryCode: $countryCode, '
        'countryName: $countryName, '
        'phoneNumber: $phoneNumber, '
        'rooted: $rooted, '
        'emulator: $emulator, '
        'appHash: $appHash, '
        'emailVerified: $emailVerified, '
        'detailsCompleted: $detailsCompleted'
        '}';
  }
}