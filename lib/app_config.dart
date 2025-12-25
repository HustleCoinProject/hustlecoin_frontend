import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static String localAppVersion = '1.0.0';

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    localAppVersion = packageInfo.version;
  }
}
