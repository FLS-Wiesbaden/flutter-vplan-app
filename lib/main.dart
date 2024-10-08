import 'dart:io';

import 'package:de_fls_wiesbaden_vplan/routes/routes.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:de_fls_wiesbaden_vplan/utils/logger.dart';
import 'package:de_fls_wiesbaden_vplan/utils/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

// Notifications
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  configureVPlanLogger();
  final log = getVPlanLogger();
  log.info("Background task started.");
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case vplanRefreshTask:
        case 'refreshTask':
          log.info("Android refresh task started.");
          PlanStorage().refresh();
          break;
        case Workmanager.iOSBackgroundTask:
          log.info("iOS refresh task started.");
          PlanStorage().refresh();
          break;
        default:
          log.info("Unknown task is triggered: $task");
          break;
      }
    } on Exception catch (error, stackTrace) {
      log.severe("Executing background refresh task failed due to ${error.toString()}.", error, stackTrace);
    }

    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Not supported.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set logging
  configureVPlanLogger();
  final log = getVPlanLogger();
  log.fine("App is starting,...");

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log.severe("Urgent error: ${details.library} in ${details.context?.toStringDeep()}", details.exception, details.stack);
    if (kReleaseMode) exit(1);
  };

  // Handle Tasks
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(vplanRefreshTask, vplanRefreshTask, 
        frequency: const Duration(minutes: 60), 
        tag: "refresh",
        constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: true
      ));
      log.fine("Registered Task (refreshTask) $vplanRefreshTask");
    }
  }

  // Notifications handling
  // ignore: unused_local_variable
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icon');
  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[];
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: darwinNotificationCategories,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('assets/images/AppIcon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  var config = Config();
  await config.load();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlanStorage(), lazy: false),
        ChangeNotifierProvider(create: (context) => config, lazy: false),
        Provider.value(value: packageInfo),
      ], 
      child: const FlsVplanApp()
    )
  );
}

class FlsVplanApp extends StatefulWidget {
  const FlsVplanApp(
    //this.notificationAppLaunchDetails, 
    {
    super.key,
    }
  );

  //final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp => false;
      //notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<FlsVplanApp> createState() => _FlsVplanAppState();
}

class _FlsVplanAppState extends State<FlsVplanApp> {

  final _appRouter = AppRouter();

  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    final log = getVPlanLogger();
    BackgroundPush.getInstance().initialize();

    _isAndroidPermissionGranted();
    try {
      _requestPermissions();
    } catch(e) {
      log.severe("Got exception on requesting permission: ${e.toString()}");
    }
  }

  Future<void> _isAndroidPermissionGranted() async {
    final log = getVPlanLogger();
    if (!kIsWeb && Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        log.fine("Android permission ${granted ? "granted" : "not granted"}");
        _notificationsEnabled = granted;
      });
    } else {
      log.fine("Android permission not requested due to wrong platform.");
    }
  }

  Future<void> _requestPermissions() async {
    final log = getVPlanLogger();
    log.fine("Requesting for additional permissions.");
    bool? granted = false;
    if (!kIsWeb && Platform.isIOS) {
      log.fine("... requesting permissions for iOS/macOS");
      granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (!kIsWeb && Platform.isMacOS) {
      log.fine("... requesting permissions for iOS/macOS");
      granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (!kIsWeb && Platform.isAndroid) {
      log.fine("... requesting permissions for Android");
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        try {
          granted = await androidImplementation.requestNotificationsPermission();      
        } on Exception {
          log.warning("Requesting for permission of notifications failed.");
        }
      }
    } else {
      log.info("Notifications disabled as not supported.");
    }

    // Platform not supported?
    if (!kIsWeb) {
      setState(() {
        _notificationsEnabled = granted ?? false;
        log.info("Notifications ${_notificationsEnabled ? "granted" : "not granted"}");
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final log = getVPlanLogger();
    log.finest("Building FlsVplanApp");

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
      theme: ThemeData(
        primarySwatch: PlanColors.MatPrimaryTextColor,
      ),
      routerConfig: _appRouter.config()
    );
  }
}
