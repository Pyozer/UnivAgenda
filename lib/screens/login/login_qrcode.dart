import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class LoginQrCode extends StatefulWidget {
  const LoginQrCode({Key? key}) : super(key: key);

  @override
  _LoginQrCodeState createState() => _LoginQrCodeState();
}

class _LoginQrCodeState extends State<LoginQrCode> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isFlash = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      print(scanData.code);
      Navigator.pop(context, scanData.code);
    });
  }

  void _onFlashBtn() {
    _controller?.toggleFlash();
    setState(() => _isFlash = !_isFlash);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanArea = min(screenSize.width, screenSize.height) * 0.65;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Scannez votre QRCode'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            formatsAllowed: const [BarcodeFormat.qrcode],
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: scanArea,
            ),
          ),
          SafeArea(
            minimum: EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton.icon(
                style: TextButton.styleFrom(primary: Colors.white),
                label: Text(_isFlash ? 'Désactiver le flash' : 'Activer le flash'),
                icon: Icon(_isFlash
                    ? Icons.flash_off_rounded
                    : Icons.flash_on_rounded),
                onPressed: _onFlashBtn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
