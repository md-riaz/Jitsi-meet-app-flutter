import 'package:permission_handler/permission_handler.dart';

/// Service to handle runtime permissions for camera, microphone, and bluetooth.
class PermissionService {
  /// Request camera and microphone permissions required for video meetings.
  /// Returns true if all permissions are granted, false otherwise.
  Future<PermissionResult> requestMeetingPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];

    // Check Bluetooth permission for Android 12+ (API level 31+)
    // Only add if the permission is supported on the current platform
    if (!await Permission.bluetoothConnect.isRestricted) {
      permissions.add(Permission.bluetoothConnect);
    }

    final statuses = await permissions.request();
    
    final deniedPermissions = <Permission>[];
    final permanentlyDeniedPermissions = <Permission>[];
    
    for (final entry in statuses.entries) {
      if (entry.value.isDenied) {
        deniedPermissions.add(entry.key);
      } else if (entry.value.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(entry.key);
      }
    }

    if (permanentlyDeniedPermissions.isNotEmpty) {
      return PermissionResult(
        granted: false,
        permanentlyDenied: true,
        deniedPermissions: _formatPermissions(permanentlyDeniedPermissions),
      );
    }

    if (deniedPermissions.isNotEmpty) {
      return PermissionResult(
        granted: false,
        deniedPermissions: _formatPermissions(deniedPermissions),
      );
    }

    return PermissionResult(granted: true);
  }

  /// Check if meeting permissions are already granted.
  Future<bool> hasMeetingPermissions() async {
    final camera = await Permission.camera.isGranted;
    final microphone = await Permission.microphone.isGranted;
    
    // For older Android versions, bluetooth permission might not be available
    bool bluetooth = true;
    if (!await Permission.bluetoothConnect.isRestricted) {
      bluetooth = await Permission.bluetoothConnect.isGranted;
    }

    return camera && microphone && bluetooth;
  }

  /// Format permission names for user-friendly display.
  String _formatPermissions(List<Permission> permissions) {
    return permissions.map((p) {
      switch (p) {
        case Permission.camera:
          return 'Camera';
        case Permission.microphone:
          return 'Microphone';
        case Permission.bluetoothConnect:
          return 'Bluetooth';
        default:
          return p.toString();
      }
    }).join(', ');
  }
}

/// Result of a permission request.
class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;
  final String deniedPermissions;

  PermissionResult({
    required this.granted,
    this.permanentlyDenied = false,
    this.deniedPermissions = '',
  });

  String get errorMessage {
    if (permanentlyDenied) {
      return 'Permission denied permanently for: $deniedPermissions.\n\n'
          'Please enable permissions in device settings to join meetings.';
    }
    return 'Permission denied for: $deniedPermissions.\n\n'
        'These permissions are required to join video meetings.';
  }
}
