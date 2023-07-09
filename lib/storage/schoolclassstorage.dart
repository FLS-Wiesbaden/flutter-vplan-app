import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:de_fls_wiesbaden_vplan/models/schooltype.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:logging/logging.dart';

class SchoolClassStorage extends ChangeNotifier {
  final Map<String, SchoolType> _types = {};
  final Map<String, SchoolClass> _list = {};
  final List<Lesson> _lessons = [];
  DateTime? _fetched;
  var _loading = false;
  static const collectionName = "classes";
  final LocalStorage storage = LocalStorage(collectionName);

  /// Resets / clears school type list.
  void clearTypes() {
    _types.clear();
  }

  /// Resets / clears all known classes.
  void clearClasses() {
    _list.clear();
  }

  /// Resets / clears all known lessons
  /// (combination of Class, Subject, Teacher)
  void clearLessons() {
    _lessons.clear();
  }

  /// Disable all pupil related bookmarks.
  void disableBookmarks() {
    for (var item in _types.values) {
      if (item.isBookmarked()) {
        item.setBookmarked(false);
      }
    }

    for(var item in _lessons) {
      if (item.isBookmarked()) {
        item.setBookmarked(false);
      }
    }

    for(var item in _list.values) {
      if (item.isBookmarked()) {
        item.setBookmarked(false);
      }
    }
  }

  /// Add a school class to a list of known school classes.
  void add(SchoolClass item) {
    // Check if item is already available in list.
    if (!_list.keys.contains(item.name)) {
      _list[item.name] = item;
    }
    notifyListeners();
  }

  /// Remove a school class from list of known school classes.
  void remove(SchoolClass item) {
    _list.remove(item.name);
    notifyListeners();
  }

  /// Sort list of lessons
  void sortLessons() {
    _lessons.sort((a, b) => a.compareTo(b));
  }

  /// Add a lesson to list of known lessons.
  bool addLesson(Lesson item) {
    // Check if item is already available in list.
    if (!_lessons.contains(item)) {
      _lessons.add(item);
      item.addListener(() {
        final log = Logger(vplanLoggerId);
        log.fine("Lesson ${item.name} by ${item.teacher.displayName} changed!");
        // TODO Delay save method
        save();
        notifyListeners();
      });
      return true;
    } else {
      return false;
    }
  }

  /// Remove given lesson from list of known lessons.
  void removeLesson(Lesson item) {
    _lessons.remove(item);
    notifyListeners();
  }

  /// Whenever data is loaded / downloaded,
  /// its returning true. Otherweise false.
  bool isLoading() {
    return _loading;
  }

  /// Get type based on its ID.
  SchoolType getType(int typeId) {
    if (_types.containsKey(typeId.toString())) {
      return _types[typeId.toString()]!;
    } else {
      throw SchoolTypeNotFoundException("SchoolType $typeId not found.");
    }
  }

  /// Get a list of known school types.
  List<SchoolType> getListOfTypes() {
    return _types.values.toList();
  }

  /// Returns number of known school types.
  int getNumberOfTypes() {
    return _types.length;
  }

  /// Get a list of school classe.
  List<SchoolClass> getListOfClass() {
    return _list.values.toList();
  }

  SchoolClass? getClass(String className) {
    if (_list.keys.contains(className)) {
      return _list[className];
    } else {
      return null;
    }
  }

  SchoolType getTypeByClass(String className) {
    int? type = getClass(className)?.schoolType;
    return getType(type ?? 0);
  }

  List<Lesson> getListOfLessons() {
    return _lessons;
  }

  int getNumberOfLessons() {
    return _lessons.length;
  }

  Iterable<SchoolType> getBookmarkedTypes() {
    return _types.values.where((element) => element.bookmarked);
  }

  Iterable<SchoolClass> getBookmarked() {
    return _list.values.where((element) => element.bookmarked);
  }

  Iterable<SchoolClass> getBookmarkedByType() {
    return _list.values.where((element) => getType(element.schoolType).bookmarked);
  }

  Iterable<Lesson> getBookmarkedLessonsByClass() {
    return _lessons.where((element) => getClass(element.name)?.bookmarked ?? false);
  }

  Map<String, List<Lesson>> getBookmarkedLessons() {
    Map<String, List<Lesson>> lessonList = {};

    for (var elm in _lessons.where((element) => element.bookmarked)) {
      if (!lessonList.containsKey(elm.name)) {
        lessonList[elm.name] = [];
      }
      lessonList[elm.name]!.add(elm);
    }

    return lessonList;
  }

  Map<String, List<int>> getBookmarkedLessonsHash() {
    Map<String, List<int>> lessonList = {};

    for (var elm in _lessons.where((element) => element.bookmarked)) {
      if (!lessonList.containsKey(elm.name)) {
        lessonList[elm.name] = [];
      }
      lessonList[elm.name]!.add(elm.hashCode);
    }

    return lessonList;
  }

  void disableLessonsByClass(String className) {
    for (var cl in _lessons.where((element) => element.name == className && element.isBookmarked())) {
      cl.setBookmarked(false);
    }
  }

  void disableClassesByType(int type) {
    for (var cl in _list.entries.where((element) => element.value.schoolType == type && element.value.isBookmarked())) {
      cl.value.setBookmarked(false);
      disableLessonsByClass(cl.key);
    }
  }

  void updateTypes(List<SchoolType>? types) {
    if (types == null) {
      _types.clear();
      return;
    }

    for(var e in types) {
      if (!_types.containsKey(e.schoolTypeId.toString())) {
        _types[e.schoolTypeId.toString()] = e;
        e.addListener(() {
          final log = Logger(vplanLoggerId);
          log.fine("SchoolType ${e.name} changed!");
          notifyListeners();
          save();
        });
      } else {
        _types[e.schoolTypeId.toString()]!.merge(e);
      }
    }
  }

  void updateClasses(Map<String, SchoolClass>? classList) {
    if (classList == null) {
      _list.clear();
      return;
    }

    classList.forEach((key, value) { 
      if (_list.containsKey(key)) {
        _list[key]!.merge(value);
      } else {
        _list[key] = value;
        value.addListener(() {
          final log = Logger(vplanLoggerId);
          log.fine("Class ${value.name} changed!");
          notifyListeners();
          save();
        });
      }
    });
  }

  void updateLessons(List<Lesson>? lessons) {
    if (lessons == null) {
      _list.clear();
      return;
    }

    for (var el in lessons) {
      if (!_lessons.contains(el)) {
        addLesson(el);
      }
    }
  }

  void updateData(
      {required DateTime fetched, required Map<String, SchoolClass> classList, List<SchoolType>? types, List<Lesson>? lessons, bool saveData = false}) {
    
    updateClasses(classList);
    updateTypes(types);
    if (lessons != null) {
      updateLessons(lessons);
    }
    _fetched = fetched;
    _loading = false;
    //notifyListeners();

    if (saveData) {
      save();
    }
  }

  Map<String, dynamic> toJson() =>
      {
        'types': _types.values.map((e) => e.toJson()).toList(), 
        'classes': getListOfClass().map((e) => e.toJson()).toList(), 
        'lessons': _lessons.map((e) => e.toJson()).toList(),
        'fetched': _fetched?.toIso8601String()
      };

  void save() {
    sortLessons();
    if (_fetched != null) {
      storage.setItem("data", this);
    } else {
      storage.deleteItem("data");
    }
  }

  Future<void> load({bool refresh = false, http.Client? client}) async {    
    _loading = true;
    if (!refresh && _fetched != null) {
      return;
    } else if (!refresh && await storage.ready && storage.getItem("data") != null) {
      var data = storage.getItem("data");
      var fetched = DateTime.parse(data['fetched']);
      List<SchoolType> types = [];
      List<Lesson> lessons = [];
      Map<String, SchoolClass> classList = {};
      if (data['types'] != null) {
        for (var e in (data['types'] as List<dynamic>)) {
          types.add(SchoolType.fromJson(e));
        }
      }
      if (data['classes'] != null) {
        for (var e in (data['classes'] as List<dynamic>)) {
          classList[e['name']] = SchoolClass.fromJson(e);
        }
      }
      if (data['lessons'] != null) {
        for (var e in (data['lessons'] as List<dynamic>)) {
          lessons.add(Lesson.fromJson(e));
        }
      }
      updateData(fetched: fetched, types: types, classList: classList, lessons: lessons);
      return;
    } else {
      downloadSchoolTypes().then((typeValue) => {
        downloadClasses().then((value) => {
          if (value != null) {
            updateData(fetched: DateTime.now(), types: typeValue, classList: value, saveData: true)
          }
        })
      });
    }
  }

  Future<List<SchoolType>?> downloadSchoolTypes({http.Client? client}) async {
    client ??= http.Client();
    final response = await client.get(
        (Uri.parse(await Config.getInstance().getEndpoint(subPath: "/vplan/loadSchoolTypes"))),
        headers: {HttpHeaders.authorizationHeader: await AuthController.getInstance().getAuthorizationHeader()});
    client.close();
    
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var rawData = jsonDecode(response.body) as List<dynamic>;
      developer.log("SchoolType downloaded -- status: ${response.statusCode}");
      List<SchoolType> types = [];
      var i = 0;
      for (var e in rawData) {
        types.add(SchoolType(i, e, false));
        i += 1;
      }
      return types;
    } else if (_fetched != null && (response.statusCode == 204 || response.statusCode == 304)) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      developer.log("Failed to download data", error: response);
      throw Exception('Failed to download data');
    }
  }

  Future<Map<String, SchoolClass>?> downloadClasses({http.Client? client}) async {
    client ??= http.Client();
    final response = await client.get(
        (Uri.parse(await Config.getInstance().getEndpoint(subPath: "/vplan/loadClasses"))),
        headers: {HttpHeaders.authorizationHeader: await AuthController.getInstance().getAuthorizationHeader()});
    client.close();
    
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var rawData = jsonDecode(response.body) as List<dynamic>;
      developer.log("SchoolType downloaded -- status: ${response.statusCode}");
      Map<String, SchoolClass> types = {};
      for (var e in rawData) {
        SchoolClass sc = SchoolClass.fromUpstreamJson(e);
        types[sc.name] = sc;
      }
      return types;
    } else if (_fetched != null && (response.statusCode == 204 || response.statusCode == 304)) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      developer.log("Failed to download data", error: response);
      throw Exception('Failed to download data');
    }
  }
}