import 'package:de_fls_wiesbaden_vplan/models/day.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/event.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('plan day', () {
    test('test plan day', () {
      final dt = DateTime.now();
      final d1 = Day(dt: dt, list: []);

      expect(d1.isEmpty, true);
      expect(d1.length(), 0);
      expect(d1.date.compareTo(dt), 0);
      expect(d1.entries, isA<List<Entry>>());
      expect(d1.entries.isEmpty, true);
      expect(d1.isEvent, false);
      expect(d1.isNotEmptyOrEvent, false);
    });

    test('test plan day date string', () {
      final dt = DateTime.parse("2023-04-11T08:30:00Z");
      final d1 = Day(dt: dt, list: []);
      expect(d1.getDateString(), "11.04.2023");
      expect(d1.getDateString(format: 'yyyy-MM-dd'), "2023-04-11");
    });

    test('test plan day events', () {
      final dt1 = DateTime.parse("2023-04-11T08:30:00Z");
      final dt2 = DateTime.parse("2023-04-29T08:30:00Z");
      final evt = Event(
        eventStart: DateTime.parse("2023-04-03T00:00:00+02:00"), 
        eventEnd: DateTime.parse("2023-04-22T23:59:59+02:00"), 
        caption: "Easter holiday",
        noLesson: true
      );
      final d1 = Day(dt: dt1, event: evt, list: []);
      final d2 = Day(dt: dt2, list: []);
      expect(d1.isNotEmptyOrEvent, true);
      expect(d1.isEvent, true);
      expect(d1.event!.caption, evt.caption);
      expect(d2.event, isNull);
      d2.setEvent(evt);
      expect(d2.event, isNotNull);
    });

    test('test plan day weekday', () {
      // Start with a sunday.
      final dt1 = DateTime.parse("2023-04-23T08:30:00Z");
      String weekdayName = "";
      for(int i = 1; i <= 7; i++) {
        final d1 = Day(dt: dt1.add(Duration(days: i)), list: []);
        expect(d1.getWeekdayName() != weekdayName, true);
        weekdayName = d1.getWeekdayName();
      }
    });

    test('test plan day filter', () {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final s2 = Subject(name: "Chemics", shortcut: "CHEM");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final t2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MXMF"); 
      final t3 = Teacher(firstName: "Unnormal", lastName: "Teacher 1", shortcut: "UNT1");
      final t4 = Teacher(firstName: "Unnormal", lastName: "Teacher 2", shortcut: "UNT2");

      getEntry({String className = "12", bool isChg = false, Teacher? teacher, Teacher? chgTeacher}) {
        final startDateTime = DateTime.now();
        final endDateTime = startDateTime.add(const Duration(minutes: 90));
        return Entry(
          startDateTime: startDateTime, 
          endDateTime: endDateTime, 
          hourText: "1.-2.", 
          className: className,
          entryType: isChg ? 1024 | 8 | 64 : 2048,
          school: 1,
          teacher: teacher ?? t1, 
          subject: s1,
          room: "A12",
          chgRoom: isChg ? "A13" : null,
          chgSubject: isChg ? s2 : null,
          chgTeacher: isChg ? chgTeacher ?? t2 : null,
          cmphash: "4687168c-7f9f-4efa-b534-c06371a63506"
        );
      }

      final e1 = getEntry(className: "12");
      final e2 = getEntry(className: "11/4 W");
      final e3 = getEntry(className: "1121", isChg: true);
      final e4 = getEntry(className: "13", isChg: true);
      final e5 = getEntry(className: "12", isChg: true);
      final e6 = getEntry(className: "12HF2", isChg: true, chgTeacher: t4);
      final e7 = getEntry(className: "12HF2", teacher: t3);

      final l1 = Lesson("12", s1, t1, true);

      final dt = DateTime.now();
      final d1 = Day(dt: dt, list: [e1, e2, e3, e4, e5, e6, e7]);
      final d2 = Day(dt: dt, list: [e1, e2, e3, e4, e5, e6, e7]);
      
      // first try of filter.
      final List<SchoolClass> lsc = [SchoolClass(1, "12", true), SchoolClass(1, "13", true)];
      d1.filter(lsc);
      expect(d1.length() != d2.length(), true);
      expect(d1.length(), 3);

      // first try to copy
      final f2 = Day.clone(other: d2, onlyStandin: true);
      expect(f2.length(), 4);

      // Filter by School Class
      final f3 = Day.clone(other: d2, onlyStandin: false, bookmarked: lsc);
      expect(f3.length(), 3);

      // Filter by Teacher
      final f4 = Day.clone(other: d2, onlyStandin: false, bookmarkedTeachers: [t3.shortcut, t4.shortcut]);
      expect(f4.length(), 2);

      // you might stumble across the situation, that if lessons classes are skipped, 
      // that you receive more entries than expected. Don't worry, this is intended.
      final f5 = Day.clone(other: d2, onlyStandin: false, bookmarkedLessons: {
        "12": [l1.hashCode],
        "1121": [],
        "11/4 W": [],
        "12HF2": [],
        "13": []
      });
      expect(f5.length(), 2);
    });

    test('test plan day json', () {
      final dt = DateTime.now();
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final s2 = Subject(name: "Chemics", shortcut: "CHEM");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final t2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MXMF");
      final startDateTime = DateTime.now();
      final endDateTime = startDateTime.add(const Duration(minutes: 90));
      final e1 = Entry(
          startDateTime: startDateTime, 
          endDateTime: endDateTime, 
          hourText: "1.-2.", 
          className: "12", 
          school: 1, 
          entryType: 1024 | 8, 
          teacher: t1, 
          subject: s1,
          room: "A12",
          chgRoom: "A13",
          chgSubject: s2,
          chgTeacher: t2,
          cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
      final d1 = Day(dt: dt, list: [e1]);
      final d1Json = d1.toJson();
      expect(d1Json, isA<Map<String, dynamic>>());
      expect(d1Json.isNotEmpty, true);
      expect(d1Json.keys.contains("date"), true);
      expect(d1Json.keys.contains("data"), true);
      final d2 = Day.fromJson(DateTime.parse(d1Json['date']), d1Json['data']);
      expect(d2.compareTo(d1), 0);
    });
  });
}