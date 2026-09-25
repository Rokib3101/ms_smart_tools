import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission(BuildContext context, {String? customMessage}) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (!context.mounted) return false;

    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('ক্যামেরা অনুমতি (Camera Permission)'),
          ],
        ),
        content: Text(
          customMessage ??
              'ডকুমেন্ট বা QR স্ক্যান করার জন্য ক্যামেরার প্রয়োজন। আপনার ডকুমেন্ট আপনার অনুমতি ছাড়া কোনো সার্ভারে পাঠানো হবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            child: const Text('অনুমতি দিন'),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      final result = await Permission.camera.request();
      if (result.isPermanentlyDenied && context.mounted) {
        _showSettingsDialog(context, 'ক্যামেরা');
      }
      return result.isGranted;
    }
    return false;
  }

  static Future<bool> requestPhotosPermission(BuildContext context) async {
    final permission = Permission.photos;
    final status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;

    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.photo_library, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('গ্যালারি অনুমতি (Photo Access)'),
          ],
        ),
        content: const Text(
          'গ্যালারি থেকে ছবি নির্বাচন করার জন্য ফটো অ্যাক্সেস প্রয়োজন। আপনার ছবিগুলো সম্পূর্ণ সুরক্ষিত থাকে এবং ডিভাইসের বাইরে কোথাও পাঠানো হয় না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            child: const Text('অনুমতি দিন'),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      final result = await permission.request();
      if (result.isPermanentlyDenied && context.mounted) {
        _showSettingsDialog(context, 'গ্যালারি');
      }
      return result.isGranted || result.isLimited;
    }
    return false;
  }

  static void _showSettingsDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$featureName অনুমতি প্রয়োজন'),
        content: Text('অ্যাপের সেটিংস থেকে অনুগ্রহ করে $featureName অনুমতিটি চালু করুন।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('সেটিংস খুলুন'),
          ),
        ],
      ),
    );
  }
}
