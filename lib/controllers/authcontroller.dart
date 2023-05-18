import 'dart:convert';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:logging/logging.dart';

class AuthController extends ChangeNotifier {

  static AuthController? _instance;

  AuthController() {
    _instance = this;
  }

  static AuthController getInstance() {
    if (_instance == null) {
      AuthController();
    }

    return _instance!;
  }

  Future<void> logout() async {
    final Config config = Config.getInstance();
    config.setAuthJwt(null);
    notifyListeners();
  }

  Future<String> oidcEndpoint() async {
    final Config config = Config.getInstance();
    final String authEndpoint = await config.getAuthEndpoint();
    return "$authEndpoint${authEndpoint.endsWith('/') ? '' : '/'}.well-known/openid-configuration";
  }

  Future<String> getAuthorizationEndpoint() async {
    final log = Logger(vplanLoggerId);
    final oidc = await http.get(Uri.parse(await oidcEndpoint())).onError((error, stackTrace) {
      log.warning("Could not determine oidc config: ${error.toString()}.", error, stackTrace);
      return Future.error("Could not determine OIDC config!");
    });
    if (oidc.statusCode != 200) {
      return Future.error("Could not determine OIDC config!");
    }
    Map<String, dynamic> oidcConfig = jsonDecode(oidc.body);
    return oidcConfig['authorization_endpoint'];
  }

  Future<bool> login({bool notify = true}) async {
    final log = Logger(vplanLoggerId);
    final Config config = Config.getInstance();
    // get all required information
    String? userName = await config.getAuthUser();
    String? secret = await config.getAuthSecret();
    String endpoint = await config.getBaseEndpoint();

    // Validate everything.
    if (userName == null || userName.isEmpty) {
      log.fine("Login not possible as user is not known.");
      return false;
    }
    if (secret == null || secret.isEmpty) {
      log.fine("Login not possible as secret is not known.");
      return false;
    }
    if (endpoint.isEmpty) {
      log.fine("Login not possible as endpoint is not known.");
      return false;
    }

    // Get OIDC authorization endpoint
    final authorizationEndpoint = await getAuthorizationEndpoint();

    // ok.. great. continue.
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };
    
    final response = await http.post(
      Uri.parse(authorizationEndpoint),
      headers: headers,
      body: {
        'client_id': userName,
        'client_secret': secret,
        'grant_type': 'client_credentials',
        'scope': 'vplan mobileapp',
      },
      encoding: Encoding.getByName('utf-8'),
    ).onError((error, stackTrace) {
      log.warning("Login not possible - could not connect: ${error.toString()}.", error, stackTrace);
      throw Exception("Could not connect!");
    });
    if (response.statusCode != 200) {
      return false;
    }
    await config.setAuthJwt(response.body);
    if (notify) {
      notifyListeners();
    }
    return true;
  }

  Future<String> getAuthorizationHeader() async {
    final log = Logger(vplanLoggerId);
    final Config config = Config.getInstance();
    String? jwtStr = await config.getAuthJwt();
    if (jwtStr == null || jwtStr.isEmpty) {
      // Try to fetch a token.
      if (await login(notify: false)) {
        jwtStr = await config.getAuthJwt();
      }
      if (jwtStr == null || jwtStr.isEmpty) {
        log.fine("Authorization header cannot be set - JWT missing!");
        return "";
      }
    }

    Map<String, dynamic>? jwt;
    try {
      jwt = jsonDecode(jwtStr);
    } on Exception catch (error, stackTrace) {
      log.warning("Could not decode token object.", error, stackTrace);
      return "";
    }

    if (jwt == null || !jwt.containsKey("access_token")) {
      return "";
    }

    return "${jwt['token_type'] ?? 'Bearer'} ${jwt['access_token']}";
  }

  Future<String?> getAccessToken() async {
    final log = Logger(vplanLoggerId);
    final Config config = Config.getInstance();
    String? jwtStr = await config.getAuthJwt();
    if (jwtStr == null || jwtStr.isEmpty) {
      log.fine("Cannot provide access_token as JWT object missing");
      return null;
    }

    Map<String, dynamic>? jwt;
    try {
      jwt = jsonDecode(jwtStr);
    } on Exception catch (error, stackTrace) {
      log.warning("Could not decode token object.", error, stackTrace);
      return null;
    }

    if (jwt != null && jwt.containsKey("access_token")) {
      return jwt['access_token'];
    }

    return null;
  }

  Future<String?> getRefreshToken() async {
    final Config config = Config.getInstance();
    String? jwtStr = await config.getAuthJwt();
    if (jwtStr == null || jwtStr.isEmpty) {
      return null;
    }

    Map<String, dynamic> jwt = jsonDecode(jwtStr);
    if (jwt.containsKey("refresh_token")) {
      return jwt['refresh_token'];
    }
    
    return null;
  }

  Future<bool> refreshToken() async {
    final Config config = Config.getInstance();
    String? refreshToken = await getRefreshToken();
    String? userName = await config.getAuthUser();

    if (refreshToken == null || refreshToken.isEmpty || userName == null || userName.isEmpty) {
      return false;
    }

    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.post(
      Uri.parse(await Config.getInstance().getEndpoint(subPath: "/auth/token")),
      headers: headers,
      body: {
        'client_id': userName,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token'
      },
      encoding: Encoding.getByName('utf-8'),
    );
    if (response.statusCode != 200) {
      return false;
    }
    config.setAuthJwt(response.body);
    return true;
  }

  Future<bool> isLoggedIn() async {
    String? accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}