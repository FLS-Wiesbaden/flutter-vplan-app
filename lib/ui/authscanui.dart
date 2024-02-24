import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/routes/routes.gr.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Provides widget to scan some kind of
/// login card for authentication.
/// This makes it more easy to login.
/// Content is not validated within this widget.
/// Its valided in the request widget.
@RoutePage()
class AuthScanUi extends StatefulWidget {
  const AuthScanUi({super.key, this.onScanCompleted});
  final void Function(AuthLoginResult)? onScanCompleted;

  @override
  State<AuthScanUi> createState() => _AuthScanUi();
}

class _AuthScanUi extends State<AuthScanUi> {
  final AuthController _authController = AuthController.getInstance();
  ValueNotifier<bool> loginOngoing = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginLoginCard)),
      body: ListenableBuilder(
          listenable: loginOngoing,
          builder: (context, child) {
            if (loginOngoing.value) {
              return const Center(
                  child: SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator()));
            } else {
              return MobileScanner(
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  setState(() => loginOngoing.value = true);
                  if (barcodes.isNotEmpty) {
                    String? scanResult = barcodes.first.rawValue;
                    if (scanResult != null) {
                      String? scanResultReadable = scanResult.replaceAll(
                          RegExp(r'"clientSecret": +".*"'),
                          '"clientSecret": "***"');
                      log.finest("Scanned barcode: $scanResultReadable");
                      await _checkLoginCardResult(scanResult);
                    } else {
                      log.finest("No barcode scanned.");
                      sendResponse(AuthLoginResult('cancelled'));
                    }
                  }
                },
              );
            }
          }),
    );
  }

  Future<void> _checkLoginCardResult(String answer) async {
    final log = Logger(vplanLoggerId);
    final Config config = Config.getInstance();
    bool loginOk = false;
    String? errorType;
    try {
      final object = jsonDecode(answer);
      List<Future<void>> vl = [];
      vl.add(config.setAuthUser(object['clientId']));
      vl.add(config.setAuthSecret(object['clientSecret']));
      vl.add(config.setSchool(object['school']));
      if (object['mode'] != null) {
        vl.add(config.setModeString(object['mode']));
      }
      await Future.wait<void>(vl);

      loginOk = await _authController
          .login()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        errorType = 'no-internet';
        return false;
      }).catchError((e) {
        if (e.runtimeType == ApiConnectException) {
          errorType = 'no-internet';
        } else {
          errorType = 'invalid-barcode';
        }
        return false;
      });
      log.finest(
          "Login triggered and got result: ${loginOk ? "Perfect!" : "Failed!"}");
    } on SchoolNotFoundException {
      errorType = 'school-not-supported';
    } on Exception {
      errorType = 'invalid-barocde';
    }

    if (mounted && context.mounted) {
      if (loginOk) {
        context.navigateTo(const WizardRoute());
      } else if (errorType != null) {
        sendResponse(AuthLoginResult(errorType!));
      }
    }
  }

  void sendResponse(AuthLoginResult message) {
    if (context.mounted) {
      if (widget.onScanCompleted != null) {
        widget.onScanCompleted!(message);
      }
      context.popRoute();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
