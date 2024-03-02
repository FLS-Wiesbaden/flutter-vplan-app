import 'dart:convert';
import 'dart:io';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';
import 'package:unifiedpush/unifiedpush.dart';

class BackgroundPush {
  static BackgroundPush? _instance;
  bool _isRegistered = false;
  late Mutex processMessage;

  BackgroundPush({bool overwrite = false}) {
    // reset instance if requested.
    if (_instance != null && overwrite) {
      _instance = null;
    }
    processMessage = Mutex();
    _instance ??= this;
  }

  static BackgroundPush getInstance() {
    if (_instance == null) {
      BackgroundPush();
    }
    return _instance!;
  }

  void initialize() async {
    final log = getVPlanLogger();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      log.info("BackgroundPush is initializing...");
      await UnifiedPush.initialize(
        onNewEndpoint:
            onNewEndpoint, // takes (String endpoint, String instance) in args
        onRegistrationFailed: onRegistrationFailed, // takes (String instance)
        onUnregistered: onUnregistered, // takes (String instance)
        onMessage:
            pushNotifyReceived, // takes (String message, String instance) in args
      );
    } else {
      log.info(
          "BackgroundPush disabled as its not supported on this platform...");
    }
  }

  Future<void> setupPush() async {
    if (_isRegistered) {
      return;
    }
    _isRegistered = true;
    final log = getVPlanLogger();
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }
    log.fine("Setup background push");
    if (!await AuthController.getInstance().isLoggedIn()) {
      return;
    }

    /*Config cfg = Config.getInstance();
    if (cfg.notifyRegistered) {
      log.fine("Background push is already activated!");
      return;
    }*/

    if (!Platform.isIOS && (await UnifiedPush.getDistributors()).isNotEmpty) {
      await setupUp();
    } else {
      //setupFirebase();
    }
  }

  Future<void> setupUp() async {
    final log = getVPlanLogger();
    final distributors =
        await UnifiedPush.getDistributors([featureAndroidBytesMessage]);
    String distributor = distributors.first;
    for (var element in distributors) {
      log.finer("Found notification distributor: $element");
      if (distributor == vplanAppId && element != vplanAppId) {
        distributor = element;
      }
    }

    log.info("Choose distributor: $distributor");
    UnifiedPush.saveDistributor(distributor);

    Config cfg = Config.getInstance();
    final instance = cfg.getSchoolObj().notifyInstance;
    UnifiedPush.registerApp(instance, [featureAndroidBytesMessage]);
  }

  Future<void> unregister(String? instance) async {
    Config cfg = Config.getInstance();
    if (cfg.notifyRegistered) {
      await UnifiedPush.unregister(instance ?? vplanNotifyInstance);
    }
  }

  void onNewEndpoint(String endpoint, String instance) {
    Config cfg = Config.getInstance();
    final log = getVPlanLogger();
    log.fine(
        "Got new endpoint for instance $instance (waiting: $vplanNotifyInstance)");

    if (instance != cfg.getSchoolObj().notifyInstance) {
      return;
    }
    cfg.setNotifyRegistered(true);
    cfg.setNotifyEndpoint(endpoint);
    log.info("Notification endpoint is $endpoint");
  }

  void onRegistrationFailed(String instance) {
    onUnregistered(instance);
  }

  void onUnregistered(String instance) {
    final log = getVPlanLogger();
    log.fine(
        "Got new endpoint for instance $instance (waiting: $vplanNotifyInstance)");

    if (instance != vplanNotifyInstance) {
      return;
    }
    Config cfg = Config.getInstance();
    cfg.setNotifyRegistered(false);
    log.info("Notification registration is disabled.");
  }

  Future<void> pushNotifyReceived(Uint8List message, String instance) async {
    processMessage.protect(() => processNotification(message, instance));
  }

  Future<bool> processNotification(Uint8List message, String instance) async {
    final log = getVPlanLogger();
    log.finer("Cloud message processing: ${utf8.decode(message)}");
    final notificationBasics = Map<String, dynamic>.from(
      json.decode(utf8.decode(message)),
    );
    final notificationObj =
        notificationBasics.containsKey('gcm.notification.body')
            ? json.decode(notificationBasics['gcm.notification.body'])
            : notificationBasics;
    final Map<String, dynamic> data = notificationObj['notification'];

    Config cfg = Config.getInstance();
    final endpoint = cfg.getSchoolObj().endpoint;
    if (!data.containsKey("endpoint") || data["endpoint"] != endpoint) {
      log.info(
          "Ignore push notification: wrong endpoint ${data["endpoint"]}. Expected: $endpoint");
      return true;
    }

    log.fine("Got push notification for $instance: $data");
    await PlanStorage().refresh();

    return true;
  }
}
