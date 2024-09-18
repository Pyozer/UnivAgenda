import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> analyzeImage(String path) async {
  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
    autoStart: true,
  );

  final result = await scanController.analyzeImage(path).timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

  String? value;
  if (result != null && result.barcodes.isNotEmpty) {
    value = result.barcodes.first.rawValue;
  }

  await scanController.dispose();

  return value;
}
