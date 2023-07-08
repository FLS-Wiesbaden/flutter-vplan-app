import 'dart:convert';
import 'dart:io';
import 'package:de_fls_wiesbaden_vplan/ui/helper/apirequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/plan.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'dart:developer' as developer;

import 'package:de_fls_wiesbaden_vplan/storage/schoolclassstorage.dart';
import 'package:de_fls_wiesbaden_vplan/storage/teacherstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:logging/logging.dart';
int notificationId = 0;

class PlanStorage extends ChangeNotifier {
  Plan? _plan;
  Plan? _standinPlan;
  Plan? _personalPlan;
  DateTime? _fetched;
  String? _etag;
  static const collectionName = "plan";
  final LocalStorage storage = LocalStorage(collectionName);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var _loading = false;
  Future<void>? _depRefresh;

  Plan? get plan => _plan;
  final SchoolClassStorage _scs = SchoolClassStorage();
  final TeacherStorage _tcs = TeacherStorage();
  bool get loading => _loading;
  late PlanType planType;

  PlanStorage() {
    Config.getInstance().addListener(handlePlanModeChange);
    planType = Config.getInstance().mode;

    _scs.addListener(() => _depDataChanged());
    _tcs.addListener(() => _depDataChanged());
  }

  void _depDataChanged() {
    final log = Logger(vplanLoggerId);
    log.fine("Some dependencies changed. Re-schedule personal plan reload.");
    _depRefresh ??= Future.delayed(const Duration(milliseconds: 500), () {
        final log = Logger(vplanLoggerId);
        if (_plan != null) {
          _personalPlan = Plan.copyFilter(
            _plan!, bookmarked: _scs.getBookmarked(), bookmarkedLessons: _scs.getBookmarkedLessonsHash(), bookmarkedTeachers: _tcs.getBookmarked()
          );
          log.info("Personal plan re-generated.");
          notifyListeners();
        }
      }).whenComplete(() => _depRefresh = null);
  }

  void handlePlanModeChange() {
    if (Config.getInstance().mode != planType) {
      planType = Config.getInstance().mode;
      // check what we need to disable.
      if (planType == PlanType.pupil) {
        _tcs.disableBookmarks();
      } else {
        _scs.disableBookmarks();
      }
    }
  }

  String getFetchedDate() {
    if (_fetched != null) {
      final DateFormat formatter = DateFormat('dd.MM.yy HH:mm');
      return "${formatter.format(_fetched!)} h";
    } else {
      return '';
    }
  }

  void notify(final List<Entry> newEntries, {int newLessons = 0}) async {
    // Only if there are entries.
    if (newEntries.isEmpty && newLessons <= 0) {
      return;
    }
    var body = '';
    final int numberEntries = newEntries.length;
    // TODO: add localization for this notification!
    if (numberEntries > 1) {
      body = "Es liegen $numberEntries neue Vertretungsplaneinträge vor.";
    } else if (numberEntries > 0) {
      body = "Es gibt einen neuen Vertretungsplaneintrag für den ${newEntries.first.getShortDateString()}.";
    } else if (newLessons > 0) {
      body = "Es sind neue Klassen/Kurse verfügbar!";
    } else {
      return;
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          vplanNewEntriesChannelId, 
          vplanNewEntriesChannelName,
          channelDescription: vplanNewEntriesChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ticker: 'ticker',
          number: numberEntries
        );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notificationId++, 'Neue Vertretungsplaneinträge', body, notificationDetails);
  }

  void setPlan(
      {required Plan plan, required DateTime fetched, bool savePlan = false, bool wasRefresh = false}) {

    final log = Logger(vplanLoggerId);
    int newLessons = 0;
    
    // is it required to update the lessons?
    if (savePlan) {
      for (var elem in plan.getEntries()) {
        if (elem.teacher != null) {
          Lesson lesson = Lesson.fromEntry(elem);
          if (schoolClassStorage.addLesson(lesson)) {
            newLessons++;
          }
        }
      }
      schoolClassStorage.save();
      log.fine("Saved school class storage after setting plan.");
    }

    Plan prevPersonalPlan = _personalPlan ?? Plan(list: [], lastUpdate: null);
    _plan = plan;
    _standinPlan = Plan.copyFilter(plan, onlyStandin: true);
    _personalPlan = Plan.copyFilter(plan, bookmarked: _scs.getBookmarked(), bookmarkedLessons: _scs.getBookmarkedLessonsHash(), bookmarkedTeachers: _tcs.getBookmarked());
    _fetched = fetched;
    _loading = false;
    notifyListeners();

    if (savePlan) {
      save();
    }
    log.fine("Plan updated and (if required) saved.");
    // only in case it was a refresh
    // Notify
    if (wasRefresh) {
      List<Entry> newEntries = prevPersonalPlan.compare(_personalPlan);
      notify(newEntries, newLessons: newLessons);
      log.fine("Got ${newEntries.length} new entries for personal plan.");
    }
  }

  Plan? getPlan({bool personalPlan = false}) {
    return personalPlan ? _personalPlan : _standinPlan;
  }

  SchoolClassStorage get schoolClassStorage => _scs;
  TeacherStorage get teacherStorage => _tcs;

  Map<String, dynamic> toJson() =>
      {'plan': _plan?.toJson(), 'fetched': _fetched?.toIso8601String(), 'etag': _etag};

  void save() {
    final log = Logger(vplanLoggerId);
    if (_fetched != null) {
      log.info("Saved plan to local storage.");
      storage.setItem("data", this);
    } else {
      log.info("Did not saved plan to local storage as no fetch information.");
      storage.deleteItem("data");
    }
  }

  Future<void> refresh() {
    final log = Logger(vplanLoggerId);
    log.info("Plan refresh triggered.");
    return load(refresh: true).then((value) => notifyListeners());
  }

  Future<Plan> load({bool refresh = false, bool personalPlan = false}) async {
    final log = Logger(vplanLoggerId);
    _loading = true;
    log.fine("Plan::load: load in progress.");
    await _scs.load();
    log.fine("Plan::load: School class storage loaded.");
    await _tcs.load();
    log.fine("Plan::load: Teacher storage loaded.");
    final bool storageReady = await storage.ready;
    log.fine("Plan::load: Storage is ${storageReady ? "ready" : "not ready"}.");
    final Map<String, dynamic>? storageData = storage.getItem("data");
    
    if (!refresh && _plan != null) {
      log.info("Plan::load: Load plan from cache.");
      return getPlan(personalPlan: personalPlan)!;
    } else if (!refresh && storageData != null) {
      var fetched = DateTime.parse(storageData['fetched']);
      var plan = Plan.fromJson(storageData['plan'] as Map<String, dynamic>);
      setPlan(fetched: fetched, plan: plan, savePlan: false);
      log.info("Plan::load: Load plan from local storage.");
      return getPlan(personalPlan: personalPlan)!;
    } else {
      return downloadPlan().then<Plan>((value) {
        if (value != null) {
          setPlan(fetched: DateTime.now(), plan: value, savePlan: true, wasRefresh: refresh);
        }
        log.info("Plan::load: Just downloaded plan and use that.");
        return getPlan(personalPlan: personalPlan)!;
      }).onError((error, stackTrace) {
        log.severe("Download and parsing of plan failed", error, stackTrace);
        return Future.error(error!, stackTrace);
      });
      
    }
  }

  Future<Plan?> downloadPlan() async {
    final log = Logger(vplanLoggerId);

    Map<String, String> queryParameters = {
      'skipHtml': '1',
      'disableCache': '1',
      'regular': Config.getInstance().addRegularPlan ? '1' : '0',
      'filterElapsedHours': '0',
      'days': Config.getInstance().numberDays.toString(),
      'planMode': Config.getInstance().mode == PlanType.teacher ? 'teacher' : 'pupil',
      'view': Config.getInstance().mode == PlanType.teacher ? 'teacher' : 'pupil'
    };
    if (Config.getInstance().notifyRegistered) {
      queryParameters['up'] = Config.getInstance().notifyEndpoint;
    }
    Map<String, String> headers = {};
    if (_etag != null) {
      headers[HttpHeaders.ifNoneMatchHeader] = _etag!;
    }
    if (_fetched != null) {
      final DateFormat formatter = DateFormat('EEE, dd LLL y H:m:s');
      headers[HttpHeaders.ifModifiedSinceHeader] = "${formatter.format(_fetched!.toUtc())} GMT";
    }
    final response = await defaultApiRequest(
      "/vplan/loadPlan", 
      headers: headers,
      queryParameters: queryParameters
    ).onError((error, stackTrace) {
      return Future.error(error!, stackTrace);
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var rawPlan = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
      developer.log("VPlan downloaded -- status: ${response.statusCode}");
      // We should set the etag.
      String? etag = response.headers.containsKey(HttpHeaders.etagHeader) ? response.headers[HttpHeaders.etagHeader] : null;
      if (etag != null) {
        _etag = etag;
      }
      log.info("Downloaded vplan -- status: ${response.statusCode}, etag: ${etag ?? "-"}");
      return Plan.fromJsonUpstream(rawPlan);
    } else if (response.statusCode == 304 && _plan != null) {
      log.info("Downloaded vplan - no data changed! -- status: ${response.statusCode}");
      return null;
    } else if (response.statusCode == 204 || response.statusCode == 304) {
      log.info("Downloaded vplan - no data changed or returned! -- status: ${response.statusCode}");
      return Plan(list: [], lastUpdate: DateTime.now());
    } else {
      log.warning("Vplan download failed -- status: ${response.statusCode}");
      throw Exception('Failed to download plan');
    }
  }
}
