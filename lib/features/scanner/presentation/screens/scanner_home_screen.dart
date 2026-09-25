import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/scanner_provider.dart';
import 'scanner_editor_screen.dart';
import '../../../../core/utils/permission_utils.dart';

class ScannerHomeScreen extends StatelessWidget {
  const ScannerHomeScreen({super.key});

  Future<void> _pickFromGallery(BuildContext context) async {
    final hasPermission = await PermissionUtils.requestPhotosPermission(context);
    if (!hasPermission) return;

    final picker = ImagePicker();
    List<XFile> selectedFiles = [];

    try {
      selectedFiles = await picker.pickMultiImage();
    } catch (_) {
      final single = await picker.pickImage(source: ImageSource.gallery);
      if (single != null) {
        selectedFiles = [single];
      }
    }

    if (selectedFiles.isEmpty) return;

    if (!context.mounted) return;

    final imagePaths = selectedFiles.map((f) => f.path).toList();
    final provider = Provider.of<ScannerProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerEditorScreen()),
    );

    // Initialize processing session in provider
    provider.initSession(imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Document Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Hero Graphic & Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner,
                  size: 56,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Gallery Document Scanner',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select document photos from Gallery to detect edges, correct perspective, and enhance readable text.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // Main Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.photo_library, size: 24),
                  label: const Text(
                    'Select from Gallery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _pickFromGallery(context),
                ),
              ),

              const SizedBox(height: 36),

              // Feature Highlights
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Key Features',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
              ),
              const SizedBox(height: 12),

              _buildFeatureTile(
                icon: Icons.crop_free,
                title: 'Auto Boundary & Perspective Crop',
                description: 'Detects paper edges and aligns perspective with 4 draggable corner handles.',
              ),
              _buildFeatureTile(
                icon: Icons.auto_fix_high,
                title: '6 Scanner Enhancement Filters',
                description: 'Original, Auto, Enhanced, Grayscale, B&W, and Shadow Reduction.',
              ),
              _buildFeatureTile(
                icon: Icons.photo_library_outlined,
                title: 'Multi-Page Editing Session',
                description: 'Process and edit multiple document pages in one seamless workflow.',
              ),
              _buildFeatureTile(
                icon: Icons.sd_card_outlined,
                title: 'Save to MS Smart Tools',
                description: 'Saves individual clean images directly as JPG or PNG to device storage.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
