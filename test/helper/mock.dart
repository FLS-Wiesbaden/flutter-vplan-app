import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

void packageInfoMock() {
  /*const MethodChannel('dev.fluttercommunity.plus/package_info')
    .setMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        'appName': 'FLS Vertretungsplan App',  // <--- set initial values here
        'packageName': 'de_fls_wiesbaden_vplan',  // <--- set initial values here
        'version': '3.0.12',  // <--- set initial values here
        'buildNumber': ''  // <--- set initial values here
      };
    }
    return null;
  });*/
  PackageInfo.setMockInitialValues(
    appName: 'FLS Vertretungsplan App',  // <--- set initial values here
    packageName: 'de_fls_wiesbaden_vplan',  // <--- set initial values here
    version: '3.0.12',  // <--- set initial values here
    buildNumber: '',  // <--- set initial values here
    buildSignature: ''
  );
}