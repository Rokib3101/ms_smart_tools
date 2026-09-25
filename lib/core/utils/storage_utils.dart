import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class StorageUtils {
  static Future<String> getAppOutputDir() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33), we need different permissions
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
         try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null && extDir.path.contains('/Android/data/')) {
            final rootPath = extDir.path.split('/Android/data/')[0];
            final customPath = '$rootPath/MS Smart Tools';
            final dir = Directory(customPath);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            return customPath;
          }
        } catch (_) {}
      }
      
      final fallbackDir = Directory('/storage/emulated/0/MS Smart Tools');
      if (!await fallbackDir.exists()) {
        try {
          await fallbackDir.create(recursive: true);
        } catch (_) {
           final docDir = await getApplicationDocumentsDirectory();
           return docDir.path;
        }
      }
      return fallbackDir.path;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      final customPath = '${docDir.path}/MS Smart Tools';
      final dir = Directory(customPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return customPath;
    }
  }

  static Future<String?> saveFileToCustomFolder(String sourcePath, String fileName) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final lowerName = fileName.toLowerCase();
      final isImage = lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png') ||
          lowerName.endsWith('.webp');

      if (isImage) {
        try {
          await Gal.putImage(sourcePath, album: 'MS Smart Tools');
        } catch (e) {
          print('Gal error: $e');
        }
      }

      try {
        final outputDir = await getAppOutputDir();
        final targetPath = '$outputDir/$fileName';
        await sourceFile.copy(targetPath);
        return targetPath;
      } catch (e) {
        return sourcePath;
      }
    } catch (e) {
      print('Save error: $e');
    }
    return null;
  }

  static Future<String?> saveDocumentToStorage({
    required String sourcePath,
    required String fileName,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;
      final bytes = await sourceFile.readAsBytes();

      final ext = fileName.contains('.') ? fileName.split('.').last : '';
      String? savedPath;

      try {
        savedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'স্টোরেজে সেভ করুন',
          fileName: fileName,
          type: ext.isNotEmpty ? FileType.custom : FileType.any,
          allowedExtensions: ext.isNotEmpty ? [ext] : null,
          bytes: bytes,
        );
      } catch (e) {
        print('FilePicker saveFile error: $e');
      }

      if (savedPath != null && savedPath.isNotEmpty) {
        final savedFile = File(savedPath);
        if (!await savedFile.exists() || (await savedFile.length()) == 0) {
          await savedFile.writeAsBytes(bytes);
        }
        return savedPath;
      }

      return await saveFileToCustomFolder(sourcePath, fileName);
    } catch (e) {
      print('saveDocumentToStorage error: $e');
      return await saveFileToCustomFolder(sourcePath, fileName);
    }
  }
}
