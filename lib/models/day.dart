import 'package:de_fls_wiesbaden_vplan/models/event.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:intl/intl.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';

class Day implements Comparable {
  DateTime _date = DateTime.now();
  List<Entry> _list = [];
  Event? _event;  

  Day({required DateTime dt, required List<Entry> list, Event? event}) {
    _date = dt;
    _list = list;
    _event = event;

    sortByTime();
  }

  int length() {
    return _list.length;
  }

  bool get isEmpty {
    return _list.isEmpty;
  }

  DateTime get date {
    return _date;
  }

  List<Entry> get entries {
    return _list;
  }

  bool get isEvent {
    return _event != null && _event!.noLesson;
  }

  bool get isNotEmptyOrEvent {
    return !isEmpty || isEvent;
  }

  Event? get event {
    return _event;
  }

  void setEvent(Event evt) {
    _event = evt;
  }

  @override
  int compareTo(other) {
    return _date.compareTo(other.date);
  }

  void sortByTime() {
    _list.sort((a, b) => a.compareTo(b));
  }

  String getWeekdayName() {
    switch (_date.weekday) {
      case DateTime.monday:
        return "Montag";
      case DateTime.tuesday:
        return "Dienstag";
      case DateTime.wednesday:
        return "Mittwoch";
      case DateTime.thursday:
        return "Donnerstag";
      case DateTime.friday:
        return "Freitag";
      case DateTime.saturday:
        return "Samstag";
      case DateTime.sunday:
        return "Sonntag";
      default:
        return "Unbekannt";
    }
  }

  String getDateString({String format = "dd.MM.yyyy"}) {
    final DateFormat formatter = DateFormat(format);
    return formatter.format(_date);
  }

  factory Day.clone({required Day other, Iterable<SchoolClass>? bookmarked, Map<String, List<int>>? bookmarkedLessons, bool onlyStandin = false, List<String>? bookmarkedTeachers}) {
    List<Entry> entries = [];
    for (var entry in (bookmarked != null && bookmarked.isNotEmpty ? other.entries.where((element) => element.match(bookmarked)) : other.entries)) {
      if (!onlyStandin || !entry.isRegular()) {
        // Now check if lessons must be checked or not....
        if (
            entry.teacher == null || (
              (bookmarkedLessons == null || !bookmarkedLessons.containsKey(entry.className) || bookmarkedLessons[entry.className]!.contains(Lesson.getHashOfEntry(entry))) &&
              (bookmarkedTeachers == null || bookmarkedTeachers.isEmpty || bookmarkedTeachers.contains(entry.teacher!.shortcut) || (
                entry.chgTeacher != null && bookmarkedTeachers.contains(entry.chgTeacher!.shortcut)
              ))
            )
        ) {
          entries.add(entry);
        }
      }
    }

    return Day(dt: other.date, list: entries, event: other.event);
  }

  factory Day.fromJson(DateTime dt, List<dynamic> json) {
    List<Entry> entries = [];
    for (var element in json) {
      entries.add(Entry.fromJson(element));
    }

    return Day(dt: dt, list: entries);
  }

  Map<String, dynamic> toJson() => {
    'date': _date.toIso8601String(),
    'data': _list.map((e) => e.toJson()).toList()
  };

  void filter(Iterable<SchoolClass> bookmarked) {
    _list = _list.where((element) => element.match(bookmarked)).toList();
  }
}
