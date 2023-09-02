import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> analyzeImage(String path) async {
  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
    autoStart: true,
  );

  final scanCompleter = Completer<String?>();
  scanController.barcodes.listen((event) {
    if (event.barcodes.isNotEmpty) {
      scanCompleter.complete(event.barcodes.first.rawValue);
    }
  });
  scanController.analyzeImage(path).ignore();

  final result = await scanCompleter.future.timeout(
    const Duration(seconds: 5),
    onTimeout: (() => null),
  );
  scanController.dispose();

  return result;
}
