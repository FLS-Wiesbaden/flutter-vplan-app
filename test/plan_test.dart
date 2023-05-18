import 'package:de_fls_wiesbaden_vplan/models/day.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/event.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/plan.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('plan test', () {
    test('test plan', () {
      final dt = DateTime.now();
      final p1 = Plan(list: [], lastUpdate: dt);
      expect(p1.isEmpty, true);
      expect(p1.length(), 0);
    });

    test('test events', () {
      final dt = DateTime.now();
      final e1 = Event(
        eventStart: DateTime.parse("2023-04-03T00:00:00+02:00"), 
        eventEnd: DateTime.parse("2023-04-22T23:59:59+02:00"), 
        caption: "Easter holiday",
        noLesson: true
      );
      final d1 = Day(dt: DateTime.parse("2023-04-11T08:30:00+02:00"), list: []);
      final p1 = Plan(list: [], lastUpdate: dt, events: [e1]);
      expect(p1.isEmpty, true); // Must be empty - no day - no event.
      expect(p1.events.isEmpty, false);
      expect(p1.events.first.hashCode, e1.hashCode);

      final p2 = Plan(list: [d1], lastUpdate: dt, events: [e1]);
      expect(d1.isEvent, true);
      expect(p2.isEmpty, false);

      final d2 = Day(dt: DateTime.parse("2023-04-11T08:30:00+02:00"), list: []);
      final p3 = Plan(list: [d2], lastUpdate: dt, events: []);
      expect(p3.isEmpty, true);
    });

    test('test plan days/entries', () {
      final dt = DateTime.now();
      final e1 = Event(
        eventStart: DateTime.parse("2023-04-03T00:00:00+02:00"), 
        eventEnd: DateTime.parse("2023-04-22T23:59:59+02:00"), 
        caption: "Easter holiday",
        noLesson: true
      );
      final d1 = Day(dt: DateTime.parse("2023-04-11T08:30:00+02:00"), list: []);
      final p1 = Plan(list: [d1], lastUpdate: dt, events: [e1]);
      expect(p1.getDay(0), isA<Day>());
      expect(p1.getEntries().isEmpty, true);

      // get all entries
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final s2 = Subject(name: "Chemics", shortcut: "CHEM");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final t2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MXMF");
      final startDateTime = DateTime.now();
      final endDateTime = startDateTime.add(const Duration(minutes: 90));
      final i1 = Entry(
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

      final d2 = Day(dt: DateTime.parse("2023-04-11T08:30:00+02:00"), list: [i1]);
      final p2 = Plan(list: [d2], lastUpdate: dt, events: []);
      expect(p2.getEntries().isEmpty, false);
      expect(p2.getEntriesHash().isEmpty, false);

      // try to filter elements.
      p2.filter([SchoolClass(1, "12", true)]);
      expect(p2.isEmpty, false);
    });

    test('test plan filter', () {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final s2 = Subject(name: "Chemics", shortcut: "CHEM");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final t2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MXMF"); 
      final t3 = Teacher(firstName: "Unnormal", lastName: "Teacher 1", shortcut: "UNT1");
      final t4 = Teacher(firstName: "Unnormal", lastName: "Teacher 2", shortcut: "UNT2");
      
      final dt1 = DateTime.now();

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
          cmphash: "$className-${isChg ? "chg":"nochg"}-${(teacher??t1).hashCode}"
        );
      }

      final e1 = getEntry(className: "12");
      final e2 = getEntry(className: "11/4 W");
      final e3 = getEntry(className: "1121", isChg: true);
      final e4 = getEntry(className: "13", isChg: true);
      final e5 = getEntry(className: "12", isChg: true);
      final e6 = getEntry(className: "12HF2", isChg: true, chgTeacher: t4);
      final e7 = getEntry(className: "12HF2", teacher: t3);

      final d1 = Day(dt: dt1, list: [e1, e2]);
      final d2 = Day(dt: dt1.add(const Duration(days: 1)), list: [e3, e4, e5]);
      final d3 = Day(dt: dt1.add(const Duration(days: 1)), list: [e6, e7]);
      final p1 = Plan(lastUpdate: dt1, list: [d1, d2]);
      final p2 = Plan(lastUpdate: dt1.add(const Duration(minutes: 30)), list: [d1, d2, d3]);

      // Compare if something changed.
      final cmp1 = p1.compare(p2);
      final cmp2 = p1.compare(null);
      expect(cmp1.isNotEmpty, true);
      expect(cmp2.isEmpty, true);

      // Work on filter
      final p3 = Plan.copyFilter(
        p1, 
        bookmarked: [SchoolClass(1, "12", true)],
        bookmarkedTeachers: [t1.shortcut],
        bookmarkedLessons: {
        "12": [Lesson.getHashOfEntry(e1)],
        "1121": [],
        "11/4 W": [],
        "12HF2": [],
        "13": []
        }
      );
      expect(p3.isEmpty, false);
      expect(p3.length(), p1.length());
      expect(p3.getEntries().length != p1.getEntries().length, true);

      final p4 = Plan.copyFilter(
        p1, 
        bookmarkedTeachers: [t1.shortcut],
        bookmarkedLessons: {
        "12": [Lesson.getHashOfEntry(e1)],
        "1121": [],
        "11/4 W": [],
        "12HF2": [],
        "13": []
        }
      );
      expect(p4.isEmpty, false);

      final p5 = Plan.copyFilter(
        p1, 
        bookmarkedTeachers: [t1.shortcut],
      );
      expect(p5.isEmpty, false);
    });

    test('test plan json', () {
      final dt = DateTime.now();
      final e1 = Event(
        eventStart: DateTime.parse("2023-04-03T00:00:00+02:00"), 
        eventEnd: DateTime.parse("2023-04-22T23:59:59+02:00"), 
        caption: "Easter holiday",
        noLesson: true
      );
      final d1 = Day(dt: DateTime.parse("2023-04-11T08:30:00+02:00"), list: []);
      final p1 = Plan(list: [d1], lastUpdate: dt, events: [e1]);
      final p1Json = p1.toJson();
      expect(p1Json, isA<Map<String, dynamic>>());
      expect(p1Json.isNotEmpty, true);
      expect(p1Json.keys.contains("data"), true);
      expect(p1Json.keys.contains("stand"), true);
      final p2 = Plan.fromJson(p1Json);
      expect(p1.lastUpdate.compareTo(p2.lastUpdate), 0);
      expect(p1.length(), p2.length());
    });
  });
}