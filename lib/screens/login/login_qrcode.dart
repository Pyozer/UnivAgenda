import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../keys/string_key.dart';
import '../../utils/translations.dart';
import '../../widgets/ui/qr_scanner_overlay_shape.dart';

class LoginQrCode extends StatefulWidget {
  const LoginQrCode({Key? key}) : super(key: key);

  @override
  LoginQrCodeState createState() => LoginQrCodeState();
}

class LoginQrCodeState extends State<LoginQrCode> {
  MobileScannerController cameraController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  Widget _buildTorch(TorchState state) {
    switch (state) {
      case TorchState.auto:
      case TorchState.unavailable:
        return const SizedBox();
      case TorchState.off:
        return _buildTorchBtn(false);
      case TorchState.on:
        return _buildTorchBtn(true);
    }
  }

  Widget _buildTorchBtn(bool isFlashOn) {
    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      label: isFlashOn
          ? Text(i18n.text(StrKey.ADD_CALENDAR_QRCODE_DISABLE_FLASH))
          : Text(i18n.text(StrKey.ADD_CALENDAR_QRCODE_ENABLE_FLASH)),
      icon: isFlashOn
          ? const Icon(Icons.flash_off_rounded)
          : const Icon(Icons.flash_on_rounded),
      onPressed: cameraController.toggleTorch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanArea = min(screenSize.width, screenSize.height) * 0.65;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.text(StrKey.ADD_CALENDAR_QRCODE_SCANNING)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          MobileScanner(
              controller: cameraController,
              onDetect: (barcode) {
                if (barcode.barcodes.isEmpty) {
                  debugPrint('Failed to scan Barcode');
                } else {
                  final code = barcode.barcodes.first.rawValue!;
                  debugPrint('Barcode found! $code');
                  cameraController.stop();
                  Navigator.of(context).pop(code);
                }
              }),
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: scanArea,
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                valueListenable: cameraController,
                builder: (context, MobileScannerState state, child) {
                  return _buildTorch(state.torchState);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
