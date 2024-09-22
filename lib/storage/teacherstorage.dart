import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/apirequest.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';
import 'package:http/http.dart' as http;
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:logging/logging.dart';

class TeacherStorage extends ChangeNotifier {
  final List<Teacher> _list = [];
  DateTime? _fetched; // DateTime
  static const collectionName = "teachers";
  final LocalStorage storage = LocalStorage(collectionName);

  List<Teacher> get teachers => _list;

  void add(Teacher item, {bool notify = true}) {
    // Check if item is already available in list.
    var existEntries = _list.where((element) => element.shortcut == item.shortcut);
    if (existEntries.isNotEmpty) {
      existEntries.first.merge(item);
    } else {
      _list.add(item);
    }
    if (notify) {
      notifyListeners();
    }
  }

  void disableBookmarks() {
    final log = Logger(vplanLoggerId);
    log.fine("Clear teacher bookmarks.");
    for(var item in _list) {
      if (item.isBookmarked()) {
        item.setBookmarked(false, skipNotification: true);
      }
    }
  }

  void updateTeachers(List<Teacher>? teacherList) {
    if (teacherList == null) {
      _list.clear();
      return;
    }

    for(var item in teacherList) {
      try {
        var existEntry = _list.firstWhere((element) => element.shortcut == item.shortcut);
        existEntry.merge(item);
      } on StateError {
        add(item, notify: false);
        item.addListener(() async {
          final log = Logger(vplanLoggerId);
          log.fine("Teacher ${item.listName} changed!");
          await save();
          notifyListeners();
        });
      }
    }

    sort();
    notifyListeners();
  }

  void remove(Teacher item) {
    _list.add(item);
    notifyListeners();
  }

  void sort() {
    _list.sort((a, b) => a.compareTo(b));
  }

  List<String> getBookmarked() {
    return _list.where((element) => element.bookmarked).map((e) => e.shortcut).toList();
  }

  Future<void> save() async {
    await storage.setItem("data", _list);
    await storage.setItem("fetched", _fetched?.toIso8601String());
  }

  Future<void> load({bool refresh = false}) async {
    // Check last refresh and force if required.
    if (_fetched != null) {
      DateTime now = DateTime.now();
      DateTime graceTime = _fetched!.add(Duration(days: 1));
      if (now.isAfter(graceTime)) {
        refresh = true;
      }
    }

    if (!refresh && _fetched != null) {
      return;
    } else if (!refresh && await storage.ready && storage.getItem("data") != null) {
      if (storage.getItem("fetched") != null) {
        _fetched = DateTime.parse(storage.getItem("fetched"));
      } else {
        _fetched = DateTime.now();
      }
      var x = storage.getItem("data");
      List<Teacher> teacherList = [];
      x.forEach((element) {
        teacherList.add(Teacher.fromJson(element));
      });
      updateTeachers(teacherList);
      // save() is not required, as we just loaded from storage.
    } else {
      await fetchTeachers().then((teacherList) async {
        if (teacherList != null) {
          _fetched = DateTime.now();
          updateTeachers(teacherList);
        }
        await save();
      });
    }
  }

  Future<List<Teacher>?> fetchTeachers() async {
    final log = Logger(vplanLoggerId);

    Map<String, String> headers = {};
    if (_fetched != null) {
      final DateFormat formatter = DateFormat('EEE, dd LLL y H:m:s');
      headers[HttpHeaders.ifModifiedSinceHeader] =
          "${formatter.format(_fetched!.toUtc())} GMT";
    }

    final response = await defaultApiRequest("/teacher",
            headers: headers)
        .onError((error, stackTrace) {
      return Future.error(error!, stackTrace);
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<Teacher> list = [];

      for (var element in (jsonDecode(await response.stream.bytesToString()) as Map).values) {
        list.add(Teacher.fromJson(element));
      }
      return list;
    } else if (_fetched != null && (response.statusCode == 204 || response.statusCode == 304)) {
      log.info(
          "Downloaded teachers - no data changed! -- status: ${response.statusCode}");
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load teachers');
    }
  }
}
