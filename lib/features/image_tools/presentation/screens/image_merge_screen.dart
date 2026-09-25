import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/image_processing_logic.dart';
import '../../../../core/utils/storage_utils.dart';

class ImageMergeScreen extends StatefulWidget {
  const ImageMergeScreen({super.key});

  @override
  State<ImageMergeScreen> createState() => _ImageMergeScreenState();
}

class _ImageMergeScreenState extends State<ImageMergeScreen> {
  final List<String> _selectedImages = [];
  MergeMode _mergeMode = MergeMode.vertical;
  bool _isProcessing = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  Future<void> _mergeAndSave() async {
    if (_selectedImages.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 images')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final resultPath = await ImageProcessingLogic.mergeImages(
        imagePaths: _selectedImages,
        mode: _mergeMode,
        spacing: 10,
      );

      if (resultPath != null) {
        final fileName = 'merged_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedPath = await StorageUtils.saveFileToCustomFolder(resultPath, fileName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(savedPath != null ? 'Saved to MS Smart Tools folder!' : 'Failed to save!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Merge'),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => setState(() => _selectedImages.clear()),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _modeButton(MergeMode.vertical, 'Vertical', Icons.view_stream),
                _modeButton(MergeMode.horizontal, 'Horizontal', Icons.view_column),
                _modeButton(MergeMode.grid, 'Grid', Icons.grid_view),
              ],
            ),
          ),
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No images selected'),
                      ],
                    ),
                  )
                : ReorderableListView(
                    padding: const EdgeInsets.all(8),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _selectedImages.removeAt(oldIndex);
                        _selectedImages.insert(newIndex, item);
                      });
                    },
                    children: _selectedImages.asMap().entries.map((entry) {
                      return Card(
                        key: ValueKey(entry.value + entry.key.toString()),
                        child: ListTile(
                          leading: Image.file(File(entry.value), width: 50, height: 50, fit: BoxFit.cover),
                          title: Text('Image ${entry.key + 1}'),
                          trailing: const Icon(Icons.drag_handle),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Add Images'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _mergeAndSave,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.done_all),
                      label: const Text('Merge & Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(MergeMode mode, String label, IconData icon) {
    final isSelected = _mergeMode == mode;
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: isSelected ? Colors.blue : Colors.grey,
          onPressed: () => setState(() => _mergeMode = mode),
        ),
        Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey, fontSize: 12)),
      ],
    );
  }
}
