class apiConfig {
  static const String emulatorBaseUrl = "http://10.0.2.2:8080";
  static const String realDeviceUrl = "http://192.168.29.111:8080";

  static const String appEnv =
  String.fromEnvironment("APP_ENV", defaultValue: "local");

  static String get baseUrl {
    if (appEnv == "emulator") {
      return emulatorBaseUrl;
    }

    if (appEnv == "local") {
      return realDeviceUrl;
    }

    return realDeviceUrl;
  }
}