import 'dart:async';
import 'dart:io';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> reinitateLogin({http.StreamedResponse? response, Exception? exception}) async {
  return AuthController().login(notify: false).then((value) => null);
}

Future<bool> retryOnInvalidLogin({http.StreamedResponse? response, Exception? exception}) async {
  return (response != null && response.statusCode == 401);
}

Future<void> apiFailed({http.StreamedResponse? response, Exception? exception}) async {
  if (response != null && response.statusCode == 401) {
    // In this case, we need to remove login state.
    await AuthController().logout();
    return Future.error(ApiAuthException("Repeated login failed with status 401. Re-login required!"));
  } else {
    return Future.error(Exception("No proper connection is possible."));
  }
}

Future<T> apiRequest<T>(
  FutureOr<T> Function() fn, {
    int maxAttempts = 1,
    Duration? attemptWait,
    FutureOr<bool> Function({T? response, Exception? exception})? retryIf,
    FutureOr<void> Function({T? response, Exception? exception})? onRetry,
    FutureOr<void> Function({T? response, Exception? exception})? onLastRetryFailed,
}) async {
  var attempt = 0;
  while (true) {
    attempt++;
    try {
      final response = await fn();
      if (retryIf != null && (await retryIf(response: response))) {
        if (attempt >= maxAttempts) {
          if (onLastRetryFailed != null) {
            try {
              await onLastRetryFailed(response: response);
            } on Exception catch (error, stackTrace) {
              return Future.error(error, stackTrace);
            }
          } else {
            return Future.error("Consequence failure - stopping requests!");
          }
        }
        // Sleep for a delay
        if (attemptWait != null) {
          await Future.delayed(attemptWait);
        }
        if (onRetry != null) {
          try {
            await onRetry(response: response);
          } on Exception {
            // do nothing.
          }
        }
      } else {
        return response;
      }
    } on ApiAuthException {
      rethrow;
    } on Exception catch (error, stackTrace) {
      if (attempt >= maxAttempts || (retryIf != null && !(await retryIf(exception: error)))) {
        if (onLastRetryFailed != null) {
          await onLastRetryFailed(exception: error);
        } else {
          return Future.error(error, stackTrace);
        }
      }
      // Sleep for a delay
      if (attemptWait != null) {
        await Future.delayed(attemptWait);
      }
      // Give opportunity to do something before refreshing.
      if (onRetry != null) {
        try {
          await onRetry(exception: error);
        } on Exception {
          // do nothing.
        }
      }
    }
  }
}

enum ApiHttpMethod {
  get, post, put, patch, delete, head
}

String getMethodNameString(ApiHttpMethod method) {
  switch(method) {
    case ApiHttpMethod.get:
      return "get";
    case ApiHttpMethod.post:
      return "post";
    case ApiHttpMethod.put:
      return "put";
    case ApiHttpMethod.patch:
      return "patch";
    case ApiHttpMethod.delete:
      return "delete";
    case ApiHttpMethod.head:
      return "head";
    default:
      return "get";
  }
}

Future<http.StreamedResponse> defaultApiRequest(
  String endpointPath,
  {
    ApiHttpMethod method = ApiHttpMethod.get,
    bool authRequired = true,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    String? body,
    Map<String, String>? bodyFields
  }
) async {
  Uri uri = Uri.parse(await Config.getInstance().getEndpoint(subPath: endpointPath));
  if (queryParameters != null) {
    uri = uri.replace(queryParameters: queryParameters);
  }
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.appName;
  String appVersion = packageInfo.version;

  try {
    return apiRequest(() async {
        http.Request req = http.Request(
          getMethodNameString(method), 
          uri
        );
        if (headers != null) {
          req.headers.addAll(headers);
        }
        if (body != null) {
          req.body = body;
        }
        if (bodyFields != null) {
          req.bodyFields.addAll(bodyFields);
        }
        if (authRequired) {
          String authHeader = await AuthController.getInstance().getAuthorizationHeader();
          req.headers.update(
            HttpHeaders.authorizationHeader, 
            (value) => authHeader,
            ifAbsent: () => authHeader
          );
        }
        req.headers.update(
          HttpHeaders.userAgentHeader,
          (value) => "$appName/$appVersion",
          ifAbsent: () => "$appName/$appVersion"
        );
        return req.send();
      }, 
      onLastRetryFailed: apiFailed, 
      onRetry: reinitateLogin, 
      retryIf: retryOnInvalidLogin, 
      maxAttempts: 2
    ).onError((error, stackTrace) {
      return Future.error(error!, stackTrace);
    });
  } on Exception catch(error, stackTrace) {
    return Future.error(error, stackTrace);
  }
}