import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class StorageUtils {
  static Future<String> getAppOutputDir() async {
    if (Platform.isAndroid) {
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final customPath = '${extDir.path}/MS Smart Tools';
          final dir = Directory(customPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          return customPath;
        }
      } catch (_) {}

      final docDir = await getApplicationDocumentsDirectory();
      final customPath = '${docDir.path}/MS Smart Tools';
      final dir = Directory(customPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return customPath;
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
        final targetFile = File(targetPath);
        if (await targetFile.exists() && await targetFile.length() > 0) {
          return targetPath;
        }
      } catch (e) {
        print('Copy file error: $e');
      }

      return sourcePath;
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

      if (bytes.isEmpty) {
        print('Source file bytes are empty!');
        return null;
      }

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
        try {
          if (!await savedFile.exists() || (await savedFile.length()) == 0) {
            await savedFile.writeAsBytes(bytes, flush: true);
          }
        } catch (e) {
          print('Write bytes error: $e');
        }

        // Verify if file actually contains data
        if (await savedFile.exists() && await savedFile.length() > 0) {
          return savedPath;
        } else {
          // If file is 0 KB, delete the corrupted empty placeholder
          try {
            if (await savedFile.exists()) {
              await savedFile.delete();
            }
          } catch (_) {}
        }
      }

      // Fallback to custom app directory if FilePicker failed or created a 0 KB file
      return await saveFileToCustomFolder(sourcePath, fileName);
    } catch (e) {
      print('saveDocumentToStorage error: $e');
      return await saveFileToCustomFolder(sourcePath, fileName);
    }
  }
}
