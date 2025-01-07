// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerPage extends StatefulWidget {
  final ValueChanged<String> onQRScanned;

  const QRScannerPage({super.key, required this.onQRScanned});

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              controller?.resumeCamera(); // Resume the camera if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Align the QR code within the frame to scan',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        try {
          await controller.pauseCamera(); // Pause to avoid repeated scans
          widget.onQRScanned(scanData.code!);
          Navigator.pop(context); // Close the scanner
        } catch (e) {
          debugPrint('Error during QR scanning: $e');
        }
      }
    });
  }
}
