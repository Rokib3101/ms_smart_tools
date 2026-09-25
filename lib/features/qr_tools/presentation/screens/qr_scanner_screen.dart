import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/permission_utils.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionUtils.requestCameraPermission(
        context,
        customMessage: 'QR স্ক্যান করার জন্য ক্যামেরার প্রয়োজন। আপনার ক্যামেরা ডেটা কোনো সার্ভারে পাঠানো হয় না।',
      );
    });
  }

  Future<void> _scanImageFromGallery() async {
    final hasPermission = await PermissionUtils.requestPhotosPermission(context);
    if (!hasPermission) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? capture = await cameraController.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final String code = capture.barcodes.first.rawValue ?? 'Unknown';
        _showResultDialog(code);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found in this image')),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanComplete) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() => _isScanComplete = true);
      final String code = barcodes.first.rawValue ?? 'Unknown';
      _showResultDialog(code);
    }
  }

  void _showResultDialog(String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Scan Result', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(code, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (Uri.tryParse(code)?.hasAbsolutePath ?? false)
                  Expanded(
                    child: _actionButton(
                      icon: Icons.open_in_browser,
                      label: 'Open Link',
                      color: Colors.blue,
                      onTap: () => launchUrl(Uri.parse(code)),
                    ),
                  ),
                Expanded(
                  child: _actionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    color: Colors.green,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                    },
                  ),
                ),
                Expanded(
                  child: _actionButton(
                    icon: Icons.share,
                    label: 'Share',
                    color: Colors.orange,
                    onTap: () => Share.share(code),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isScanComplete = false);
              },
              child: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => _isScanComplete = false));
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR & Barcode Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _scanImageFromGallery,
            tooltip: 'Select from Gallery',
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.on: return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.off:
                  default: return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front: return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                  default: return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          _buildScannerOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.transparent)),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Text(
            'Position QR or barcode inside frame',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
