class AuthLoginResult {
  String result = '';

  AuthLoginResult(this.result);

  bool isCancelled() {
    return result == 'cancelled';
  }
  bool isSchoolNotSupported() {
    return result == 'school-not-supported';
  }
  bool isInvalidBarcode() {
    return result == 'invalid-barcode';
  }
  bool isNoInternet() {
    return result == 'no-internet';
  }
}