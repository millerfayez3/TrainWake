import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionService {
  /// Checks and requests location permissions with a staggered flow.
  /// Explains WHY permissions are needed before requesting.
  Future<bool> checkAndRequestLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verify GPS service is enabled on the device
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Must prompt user to turn on GPS in settings
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show UI rationale here BEFORE requesting
      // e.g., "TrainWake needs your location in the background..."
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try again.
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      // Must prompt user to open app settings.
      return false;
    } 

    // 3. Request Notification permissions for Android 13+
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final bool? notificationGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    // If running on < Android 13, requestNotificationsPermission returns null (already granted basically).
    if (notificationGranted == false) {
      return false;
    }

    return true;
  }
}
