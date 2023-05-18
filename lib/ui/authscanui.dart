import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// Provides widget to scan some kind of 
/// login card for authentication. 
/// This makes it more easy to login.
/// Content is not validated within this widget.
/// Its valided in the request widget.
class AuthScanUi extends StatefulWidget {
  const AuthScanUi({super.key});

  @override
  State<AuthScanUi> createState() => _AuthScanUi();
}

class _AuthScanUi extends State<AuthScanUi> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);

    void onQRViewCreated(QRViewController controller) {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        setState(() {
          result = scanData;
          scanResult = scanData.code;
        });
        log.finest("Scanned barcode: $scanResult");
        Navigator.pop(context, scanResult);
      });
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginLoginCard)),
      body: QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
      )
    );
    
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}