import 'package:de_fls_wiesbaden_vplan/models/school.dart';
import 'package:de_fls_wiesbaden_vplan/storage/storage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/utils/notifications.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Plan Type to define whether pupil or teacher plan is requested.
enum PlanType { pupil, teacher }

/// Main app configuration
/// Is a singleton.
class Config extends ChangeNotifier {
  static const cfgEndpoint = "endpoint";
  static const defaultEndpoint = "https://www.fls-wiesbaden.de";

  static const configKeyMode = "mode";
  static const configKeyAddRegularPlan = "addRegularPlan";
  static const configKeyNumberDays = "numberDays";
  static const configKeySchool = "school";
  static const configKeyAuthUser = "authUser";
  static const configKeyAuthSecret = "authSecret";
  static const configKeyAuthJwt = "authJwt";
  static const configKeyPermTeacher = "permTeacher";
  static const configKeyFirstCall = "firstCall";
  static const configPlanTeacher = "teacher";
  static const configPlanPupil = "pupil";
  static const configDefaultSchool = "fls";
  static const configKeyNotifyRegistered = "notifyRegistered";
  static const configKeyNotifyEndpoint = "notifyEndpoint";

  static Config? _instance;
  static List<School> schools = [
    School(
        "fls",
        "FLS-Wiesbaden",
        "assets/images/AppIcon.png",
        "https://www.fls-wiesbaden.de",
        "https://www.fls-wiesbaden.de/geco/auth"),
    /*School(
        "local",
        "Local",
        "assets/schools/lss.png",
        "http://fls.local",
        "http://fls.local/geco/auth"),*/
    /*School("sds", "SDS Wiesbaden", "assets/schools/sds.png", "https://sds.fls-wiesbaden.de", "https://sds.fls-wiesbaden.de/geco/auth"),
    School("gks", "GKS Obertshausen", "assets/schools/gks.png", "https://vplan.gks-obertshausen.de", "https://vplan.gks-obertshausen.de/geco/auth"),
    School("lss", "LSS Wiesbaden", "assets/schools/lss.png", "https://lss.fls-wiesbaden.de", "https://lss.fls-wiesbaden.de/geco/auth"),*/
  ];

  /// Attributes
  ///
  PlanType _planType = PlanType.pupil;
  bool _addRegularPlan = true;
  int _numberDays = 5;
  String _schoolName = configDefaultSchool;
  String _notifyEndpoint = "";
  bool _notifyRegistered = false;
  bool _teacherPermission = false;
  late IStorage _storage;
  late School _school;

  Config({IStorage? storage, bool overwrite = false}) {
    // reset instance if requested.
    if (_instance != null && overwrite) {
      _instance = null;
    }

    _instance ??= this;
    // Initialize and set fls as default school.
    _school = schools.first;
    if (storage == null) {
      _storage = SecureStorage();
    } else {
      _storage = storage;
    }
    _teacherPermission = false;
  }

  static Config getInstance() {
    if (_instance == null) {
      Config();
    }
    return _instance!;
  }

  PlanType get mode {
    return _planType;
  }

  String get endpoint {
    return _school.endpoint;
  }

  bool get addRegularPlan {
    return _addRegularPlan;
  }

  int get numberDays {
    return _numberDays;
  }

  String get schoolName {
    return _schoolName;
  }

  School get school {
    return _school;
  }

  String get notifyEndpoint {
    return _notifyEndpoint;
  }

  bool get notifyRegistered {
    return _notifyRegistered;
  }

  bool get teacherPermission {
    return _teacherPermission;
  }

  void setNotifyRegistered(bool registered) async {
    _notifyRegistered = registered;
    await _storage.write(
        key: configKeyNotifyRegistered, value: registered.toString());
  }

  void setNotifyEndpoint(String notifyEndpoint) async {
    _notifyEndpoint = notifyEndpoint;
    await _storage.write(key: configKeyNotifyEndpoint, value: notifyEndpoint);
  }

  /// Load basic configuration from storage
  /// which are mandatory to know them at
  /// every point of time.
  Future<void> load() async {
    final log = Logger(vplanLoggerId);
    log.fine("Config: Loading configuration");
    _planType = await getMode();
    _addRegularPlan = await getAddRegularPlan();
    _numberDays = await getNumberDays();
    _schoolName = await getSchoolName();
    _school = getSchoolObj();
    _notifyRegistered = await getNotifyRegistered();
    _notifyEndpoint = await getNotifyEndpoint();
    _teacherPermission = await getTeacherPermission();
    log.info("Config: Loaded");
  }

  /// Return the plan type. Read directly from storage.
  Future<PlanType> getMode() async {
    if (!await _storage.containsKey(key: configKeyMode)) {
      return PlanType.pupil;
    }
    final log = Logger(vplanLoggerId);
    PlanType planMode = PlanType.pupil;
    try {
      String? storeMode = await _storage.read(key: configKeyMode);
      if (storeMode == configPlanTeacher) {
        planMode = PlanType.teacher;
      }
    } on Exception {
      log.fine("No plan mode stored yet.");
    }
    
    return planMode;
  }

  /// Update configuration and set plan type.
  Future<void> setMode(PlanType pt) async {
    _planType = pt;
    return _storage
        .write(
            key: configKeyMode,
            value: pt == PlanType.teacher ? configPlanTeacher : configPlanPupil)
        .whenComplete(() => notifyListeners());
  }

  /// Update configuration and set plan type.
  Future<void> setModeString(String planType) async {
    setMode(planType == configPlanTeacher ? PlanType.teacher : PlanType.pupil);
  }

  /// Get base school vplan endpoint based on school configuration from
  /// storage.
  Future<String> getBaseEndpoint() async {
    return _school.endpoint;
  }

  /// Get API endpoint based on base endpoint.
  Future<String> getEndpoint({String subPath = ""}) async {
    return "${_school.apiEndpoint}$subPath";
  }

  /// Get the authentication endpoint.
  Future<String> getAuthEndpoint() async {
    return _school.authEndpoint;
  }

  /// Get configuration whether regular plan schould be loaded.
  Future<bool> getAddRegularPlan() async {
    if (await _storage.containsKey(key: configKeyAddRegularPlan)) {
      try {
        return (await _storage.read(key: configKeyAddRegularPlan))! == 'true';
      } on Exception {
        return true;
      }
    } else {
      return true;
    }
  }

  /// Set configuration whether regular plan should be added or not.
  void setAddRegularPlan(bool pt) async {
    _addRegularPlan = pt;
    await _storage
        .write(key: configKeyAddRegularPlan, value: pt ? 'true' : 'false')
        .whenComplete(() => notifyListeners());
  }

  /// Get number of days which should be requested to the API server.
  /// It does not mean, that the API server is providing us these
  /// number of days.
  Future<int> getNumberDays() async {
    if (await _storage.containsKey(key: configKeyNumberDays)) {
      try {
        int? days =
            int.tryParse((await _storage.read(key: configKeyNumberDays))!);
        return days ?? 5;
      } on Exception {
        return 5;
      }
    } else {
      return 5;
    }
  }

  /// Set the number of days which should be requested to the API server.
  void setNumberDays({int days = 5}) async {
    _numberDays = days;
    await _storage
        .write(key: configKeyNumberDays, value: days.toString())
        .whenComplete(() => notifyListeners());
  }

  /// Get school identifier.
  Future<String> getSchoolName() async {
    if (await _storage.containsKey(key: configKeySchool)) {
      try {
        return (await _storage.read(key: configKeySchool))!;
      } on Exception {
        return configDefaultSchool;
      }
    } else {
      return configDefaultSchool;
    }
  }

  /// Set school identifier.
  Future<void> setSchool(String school) async {
    // Throws an exception, if school cannot be found.
    int schoolIdx = Config.schools.indexWhere((element) => element.id == school);
    if (schoolIdx < 0) {
      throw SchoolNotFoundException("School $school not found!");
    }
    if (_schoolName != school) {
      BackgroundPush.getInstance().unregister(_school.notifyInstance);
    }
    _schoolName = school;
    _school = Config.schools.elementAt(schoolIdx);
    return _storage
        .write(key: configKeySchool, value: school)
        .whenComplete(()  => notifyListeners());
  }

  /// Get school identifier.
  Future<bool> getNotifyRegistered() async {
    if (await _storage.containsKey(key: configKeyNotifyRegistered)) {
      try {
        return (await _storage.read(key: configKeyNotifyRegistered))! == 'true';
      } on Exception {
        return false;
      }
    } else {
      return false;
    }
  }

  /// Get school identifier.
  Future<String> getNotifyEndpoint() async {
    if (await _storage.containsKey(key: configKeyNotifyEndpoint)) {
      try {
        return (await _storage.read(key: configKeyNotifyEndpoint))!;
      } on Exception {
        return "";
      }
    } else {
      return "";
    }
  }

  /// Set auth user (can be a client_id)
  Future<void> setAuthUser(String? user) {
    final log = Logger(vplanLoggerId);
    return _storage
        .write(key: configKeyAuthUser, value: user)
        .then((value) => log.fine("User $user saved."));
  }

  /// Get auth user (can be a client_id)
  Future<String?> getAuthUser() {
    return _storage.read(key: configKeyAuthUser);
  }

  /// Set the auth secret (can be a client_secret)
  Future<void> setAuthSecret(String? secret) {
    return _storage.write(key: configKeyAuthSecret, value: secret);
  }

  /// Get the auth secret (can be a client_secret)
  Future<String?> getAuthSecret() {
    return _storage.read(key: configKeyAuthSecret);
  }

  /// Save and store a JWT
  Future<void> setAuthJwt(String? jwt) {
    return _storage.write(key: configKeyAuthJwt, value: jwt);
  }

  /// Get last saved JWT
  Future<String?> getAuthJwt() {
    return _storage.read(key: configKeyAuthJwt);
  }

  Future<bool> getTeacherPermission() async {
    try {
      if (await _storage.containsKey(key: configKeyPermTeacher)) {
        return (await _storage.read(key: configKeyPermTeacher))! == 'true';
      }
    } catch (e) {
      final log = Logger(vplanLoggerId);
      log.severe(
          "Config: Failed loading teacher permission -- fallback to false!");
    }
    return false;
  }

  Future<void> setTeacherPermission(bool hasPerm) async {
    _teacherPermission = hasPerm;
    if (!hasPerm) {
      setMode(PlanType.pupil);
    }
    await _storage.write(key: configKeyPermTeacher, value: hasPerm.toString());
  }

  /// Return true if its the first time this app is
  /// started.
  Future<bool> isFirstCall() {
    return _storage
        .read(key: configKeyFirstCall)
        .then<bool>((value) => value == null || value != '1');
  }

  /// Set whether first call was successful.
  Future<void> setFirstCallDone(bool firstCallDone) {
    return _storage.write(
        key: configKeyFirstCall, value: firstCallDone ? '1' : '0');
  }

  /// Return the school object based on school identifier
  School getSchoolObj({String? schoolId}) {
    schoolId ??= _schoolName;
    return Config.schools.firstWhere((element) => element.id == schoolId);
  }
}
