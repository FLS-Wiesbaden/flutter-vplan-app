import 'package:de_fls_wiesbaden_vplan/models/event.dart';
import 'package:de_fls_wiesbaden_vplan/models/day.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';

class Plan {
  List<Day> _list = [];
  List<Event> _events = [];
  DateTime? _lastUpdate;

  Plan({required List<Day> list, required lastUpdate, List<Event>? events}) {
    _list = list;
    _lastUpdate = lastUpdate;
    _events = events ?? [];
    mergeEventNote();

    // sort entries
    _list.sort((a, b) => a.compareTo(b));
  }

  void mergeEventNote() {
    for (var day in _list) {
      for (var event in _events) { 
        if (event.matchDate(day.date)) {
          day.setEvent(event);
          break;
        }
      }
    }
  }

  int length() {
    return _list.length;
  }

  Day getDay(int index) {
    return _list.elementAt(index);
  }

  List<Entry> getEntries() {
    List<Entry> list = [];
    for (var day in _list) {
      list.addAll(day.entries);
    }

    return list;
  }

  List<String> getEntriesHash() {
    List<String> list = [];
    for (var day in _list) {
      list.addAll(day.entries.map((e) => e.cmphash));
    }

    return list;
  }

  DateTime get lastUpdate {
    return _lastUpdate!;
  }

  List<Event> get events {
    return _events;
  }

  bool get isEmpty {
    if (_list.isEmpty) {
      return true;
    }

    try {
      return !_list.firstWhere((element) => element.isNotEmptyOrEvent).isNotEmptyOrEvent;
    } on StateError {
      return true;
    }
  }

  void filter(Iterable<SchoolClass> bookmarked) {
    for (var element in _list) {
      element.filter(bookmarked);
     }
  }

  factory Plan.copyFilter(
    Plan other, {Iterable<SchoolClass>? bookmarked, Map<String, List<int>>? bookmarkedLessons, 
    bool onlyStandin = false, List<String>? bookmarkedTeachers}
  ) {
    List<Day> dayList = [];
    // If no filter is given, result is always: empty!
    if (onlyStandin || other.events.isNotEmpty || 
        (bookmarked != null && bookmarked.isNotEmpty) || 
        (bookmarkedLessons != null && bookmarkedLessons.isNotEmpty) || 
        (bookmarkedTeachers != null && bookmarkedTeachers.isNotEmpty)
    ) {
      for (int i = 0; i < other.length(); i++) {
        dayList.add(
          Day.clone(
            other: other.getDay(i), 
            bookmarked: bookmarked, 
            bookmarkedLessons: bookmarkedLessons, 
            bookmarkedTeachers: bookmarkedTeachers, 
            onlyStandin: onlyStandin
          )
        );
      }
    }

    return Plan(lastUpdate: other.lastUpdate, list: dayList, events: other.events);
  }

  factory Plan.fromJsonUpstream(Map<String, dynamic> json) {
    List<Event> events = [];
    List<Day> entries = [];
    if (json['changes'] != null && json['changes'] is Map<String, dynamic>) {
      json['changes'].forEach((key, value) {
        entries.add(Day.fromJson(DateTime.fromMillisecondsSinceEpoch(int.parse(key)*1000, isUtc: false), value));
      });
    }
    json['events'].forEach((value) {
      events.add(Event.fromJson(value));
    });
    List<String> dateList = entries.map((e) => e.getDateString(format: 'yyyy-MM-dd')).toList();
    json['days'].forEach((value) {
      if (!dateList.contains(value)) {
        dateList.add(value);
        entries.add(Day(dt: DateTime.parse(value), list: []));
      }
    });

    return Plan(
      list: entries, 
      lastUpdate: DateTime.fromMicrosecondsSinceEpoch(json['stand']*1000),
      events: events
    );
  }

  factory Plan.fromJson(Map<String, dynamic> json) {
    List<Day> entries = [];
    for (var value in (json['data'] as List<dynamic>)) {
      entries.add(Day.fromJson(DateTime.parse(value['date']), value['data']));
    }
    List<Event> events = [];
    for (var value in (json['events'] as List<dynamic>)) {
      events.add(Event.fromJson(value));
    }

    return Plan(
      list: entries, 
      lastUpdate: json['stand'] != null ? DateTime.parse(json['stand']) : DateTime.now(),
      events: events
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'data': _list.map((e) => e.toJson()).toList(), 
        'events': _events.map((e) => e.toJson()).toList(), 
        'stand': _lastUpdate?.toIso8601String()
      };

  List<Entry> compare(Plan? newPlan) {
    List<Entry> newEntries = [];
    if (newPlan == null) {
      return newEntries;
    }
    List<String> currentEntries = getEntriesHash();

    for(var entry in newPlan.getEntries()) {
      if (!entry.isRegular() && !currentEntries.contains(entry.cmphash)) {
        newEntries.add(entry);
      }
    }

    return newEntries;
  }
}
