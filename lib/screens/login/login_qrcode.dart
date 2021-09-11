// import 'package:flutter/material.dart';
// import 'package:qrcode/qrcode.dart';

// class LoginQrCode extends StatefulWidget {
//   const LoginQrCode({Key? key}) : super(key: key);

//   @override
//   _LoginQrCodeState createState() => _LoginQrCodeState();
// }

// class _LoginQrCodeState extends State<LoginQrCode> {
//   final _captureController = QRCaptureController();
//   bool _isFlashActive = false;

//   @override
//   void initState() {
//     super.initState();
//     _captureController.onCapture((data) {
//       _captureController.pause();
//       _onScanned(data);
//     });
//   }

//   void _onScanned(String urlScanned) async {
//     Navigator.of(context).pop(urlScanned);
//   }

//   void _onFlashBtn() {
//     if (_isFlashActive) {
//       _captureController.torchMode = CaptureTorchMode.off;
//     } else {
//       _captureController.torchMode = CaptureTorchMode.on;
//     }
//     setState(() => _isFlashActive = !_isFlashActive);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final redBoxSize = MediaQuery.of(context).size.width * 0.6;
//     return Material(
//       child: Stack(
//         children: [
//           QRCaptureView(controller: _captureController),
//           Container(
//             decoration: ShapeDecoration(
//               shape: QrScanOverlayShape(
//                 cutOutSize: redBoxSize,
//                 overlayColor: Colors.black.withOpacity(0.6),
//                 borderWidth: 6,
//                 borderRadius: 8,
//                 borderColor: Colors.red,
//                 marginTop: 30.0,
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       icon: const Icon(
//                         Icons.close,
//                         size: 32.0,
//                         color: Colors.white,
//                       ),
//                       onPressed: Navigator.of(context).pop,
//                     ),
//                     const SizedBox(height: 16.0),
//                     Text(
//                       "Scanner le QRCode sur votre ENT",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 18.0,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: SafeArea(
//               minimum: const EdgeInsets.only(bottom: 16.0),
//               child: FloatingActionButton.extended(
//                 label: Text(
//                   "Flash",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 icon: Icon(
//                   _isFlashActive ? Icons.flash_off : Icons.flash_on,
//                   color: Colors.white,
//                 ),
//                 onPressed: _onFlashBtn,
//                 heroTag: 'flash',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Source: https://github.com/Furkankyl/twitter_qr_scanner/blob/master/lib/QrScannerOverlayShape.dart
// class QrScanOverlayShape extends ShapeBorder {
//   final Color borderColor;
//   final double borderWidth;
//   final Color overlayColor;
//   final double borderRadius;
//   final double borderLength;
//   final double cutOutSize;
//   final double marginTop;

//   QrScanOverlayShape({
//     this.borderColor = Colors.red,
//     this.borderWidth = 3.0,
//     this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
//     this.borderRadius = 0,
//     this.borderLength = 40,
//     this.cutOutSize = 250,
//     this.marginTop = 0,
//   }) : assert(
//           borderLength <= cutOutSize / 2 + borderWidth * 2,
//           "Border can't be larger than ${cutOutSize / 2 + borderWidth * 2}",
//         );

//   @override
//   EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//     return Path()
//       ..fillType = PathFillType.evenOdd
//       ..addPath(getOuterPath(rect), Offset.zero);
//   }

//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     Path _getLeftTopPath(Rect rect) {
//       return Path()
//         ..moveTo(rect.left, rect.bottom)
//         ..lineTo(rect.left, rect.top)
//         ..lineTo(rect.right, rect.top);
//     }

//     return _getLeftTopPath(rect)
//       ..lineTo(rect.right, rect.bottom)
//       ..lineTo(rect.left, rect.bottom)
//       ..lineTo(rect.left, rect.top);
//   }

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
//     final width = rect.width;
//     final borderWidthSize = width / 2;
//     final height = rect.height;
//     final borderOffset = borderWidth / 2;
//     final _borderLength = borderLength > cutOutSize / 2 + borderWidth * 2
//         ? borderWidthSize / 2
//         : borderLength;
//     final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

//     final backgroundPaint = Paint()
//       ..color = overlayColor
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderWidth;

//     final boxPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOut;

//     final cutOutRect = Rect.fromLTWH(
//       width / 2 - _cutOutSize / 2 + borderOffset,
//       height / 2 - _cutOutSize / 2 + borderOffset + marginTop,
//       _cutOutSize - borderOffset * 2,
//       _cutOutSize - borderOffset * 2,
//     );

//     canvas.saveLayer(rect, backgroundPaint);

//     canvas
//       ..drawRect(rect, backgroundPaint)
//       // Draw top right corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.right - _borderLength,
//           cutOutRect.top,
//           cutOutRect.right,
//           cutOutRect.top + _borderLength,
//           topRight: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw top left corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.left,
//           cutOutRect.top,
//           cutOutRect.left + _borderLength,
//           cutOutRect.top + _borderLength,
//           topLeft: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw bottom right corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.right - _borderLength,
//           cutOutRect.bottom - _borderLength,
//           cutOutRect.right,
//           cutOutRect.bottom,
//           bottomRight: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       // Draw bottom left corner
//       ..drawRRect(
//         RRect.fromLTRBAndCorners(
//           cutOutRect.left,
//           cutOutRect.bottom - _borderLength,
//           cutOutRect.left + _borderLength,
//           cutOutRect.bottom,
//           bottomLeft: Radius.circular(borderRadius),
//         ),
//         borderPaint,
//       )
//       ..drawRRect(
//         RRect.fromRectAndRadius(
//           cutOutRect,
//           Radius.circular(borderRadius),
//         ),
//         boxPaint,
//       )
//       ..restore();
//   }

//   @override
//   ShapeBorder scale(double t) {
//     return QrScanOverlayShape(
//       borderColor: borderColor,
//       borderWidth: borderWidth,
//       overlayColor: overlayColor,
//     );
//   }
// }
