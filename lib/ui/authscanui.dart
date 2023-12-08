import 'dart:typed_data';

import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginLoginCard)),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            String? scanResult = barcodes.first.rawValue;
            log.finest("Scanned barcode: $scanResult");
            Navigator.pop(context, scanResult);
          }
        },
      )
    );
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}