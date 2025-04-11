// lib/utils/connectivity_utils.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityUtils {
  static Future<bool> isInternetAvailable() async {
    return await InternetConnectionChecker().hasConnection;
  }

  static Future<ConnectivityResult> getConnectionType() async {
    return await Connectivity().checkConnectivity();
  }

  static String getConnectionTypeString(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}