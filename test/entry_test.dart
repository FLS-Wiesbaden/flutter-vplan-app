import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';

void main() {
  group('entries', () {
    test('test entry', () async {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final startDateTime = DateTime.now();
      final endDateTime = startDateTime.add(const Duration(minutes: 90));

      final e1 = Entry(
            startDateTime: startDateTime, 
            endDateTime: endDateTime, 
            hourText: "1.-2.", 
            className: "12", 
            school: 1, 
            entryType: 1024, 
            teacher: t1, 
            subject: s1, 
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");

      final startDateTimeSpec = DateTime.parse("2023-05-02T08:30:00Z");
      final endDateTimeSpec = startDateTimeSpec.add(const Duration(minutes: 90));
      final e2 = Entry(
            startDateTime: startDateTimeSpec, 
            endDateTime: endDateTimeSpec, 
            hourText: "1.-2.", 
            className: "12", 
            school: 1, 
            entryType: 1024, 
            teacher: t1, 
            subject: s1, 
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");

      // do the necessary tests
      expect(e1.getShortDateString(), "1.-2.");
      expect(e2.getShortDateString(), "02.05., 1.-2.");
      expect(e2.getStartTime(), "08:30");
      expect(e2.getEndTime(), "10:00");
    });

    test('test type', () async {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final startDateTime = DateTime.now();
      final endDateTime = startDateTime.add(const Duration(minutes: 90));

      getTypedEntry(int type) {
        return Entry(
            startDateTime: startDateTime, 
            endDateTime: endDateTime, 
            hourText: "1.-2.", 
            className: "12", 
            school: 1, 
            entryType: type, 
            teacher: t1, 
            subject: s1, 
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
      }

      // Test regular entry
      final regular = getTypedEntry(2048);
      expect(regular.isRegular(), true);
      expect(regular.isFree(), false);

      // Test yard duty
      final yd = getTypedEntry(128 | 2048);
      expect(yd.isYardDuty(), true);
      expect(yd.isRegular(), true);
      expect(yd.isFree(), false);

      // Test standin
      final si = getTypedEntry(1024 | 8 | 4 | 2);
      expect(si.isRegular(), false);
      expect(si.isYardDuty(), false);
      expect(si.isFree(), false);

      // Test free
      final sf = getTypedEntry(1024 | 64);
      expect(sf.isRegular(), false);
      expect(sf.isYardDuty(), false);
      expect(sf.isFree(), true);
    });

    test('test variants', () async {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final startDateTime = DateTime.now();
      final endDateTime = startDateTime.add(const Duration(minutes: 90));

      getEntryVariant({String? info, String? note, int type = 1024 | 8}) {
        return Entry(
            startDateTime: startDateTime, 
            endDateTime: endDateTime, 
            hourText: "1.-2.", 
            className: "12", 
            school: 1, 
            entryType: type, 
            teacher: t1, 
            subject: s1,
            note: note,
            info: info, 
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
      }

      // Test no note / no info
      final nnni = getEntryVariant();
      expect(nnni.chgNotes, isNull);

      // Test note / no info
      final nni = getEntryVariant(note: "Test note");
      expect(nni.chgNotes, "Test note");

      // Test no note / info
      final nnbi = getEntryVariant(info: "Test info");
      expect(nnbi.chgNotes, "Test info");

      // Test note / info
      final ni = getEntryVariant(info: "Test info", note: "Test note");
      expect(ni.chgNotes, "Test info - Test note");
    });

    test('test lesson', () async {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
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
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
      final e2 = Entry(
            startDateTime: startDateTime, 
            endDateTime: endDateTime, 
            hourText: "1.-2.", 
            className: "12", 
            school: 1, 
            entryType: 1024 | 8, 
            teacher: null, 
            subject: s1,
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");

      final l1 = Lesson("12", s1, t1, false);

      expect(e1.getLessonOfEntry(), isNotNull);
      expect(e1.getLessonOfEntry()!.compareTo(l1), 0);
      expect(e2.getLessonOfEntry(), isNull);
    });

    test('test comparism', () async {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final startDateTime = DateTime.now();

      getEntryVariant({required DateTime startDateTime, int schoolType = 1, String className = "12", int type = 1024 | 8}) {
        final endDateTime = startDateTime.add(const Duration(minutes: 90));
        return Entry(
            startDateTime: startDateTime, 
            endDateTime: endDateTime, 
            hourText: "1.-2.", 
            className: className, 
            school: schoolType, 
            entryType: type, 
            teacher: t1, 
            subject: s1,
            cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
      }

      final v0 = getEntryVariant(startDateTime: startDateTime);
      final v1 = getEntryVariant(startDateTime: startDateTime);
      final v2 = getEntryVariant(startDateTime: startDateTime.add(const Duration(days: 1)));
      final v3 = getEntryVariant(startDateTime: startDateTime.subtract(const Duration(days: 1)));
      final v4 = getEntryVariant(startDateTime: startDateTime, schoolType: 0);
      final v5 = getEntryVariant(startDateTime: startDateTime, schoolType: 2);
      final v6 = getEntryVariant(startDateTime: startDateTime, className: "11/4 W");
      final v7 = getEntryVariant(startDateTime: startDateTime, className: "13");

      // Now execute the different tests
      expect(v0.compareTo(v1), 0);
      expect(v1.compareTo(v2) < 0, true);
      expect(v1.compareTo(v3) > 0, true);
      expect(v1.compareTo(v4) > 0, true);
      expect(v1.compareTo(v5) < 0, true);
      expect(v1.compareTo(v6) > 0, true);
      expect(v1.compareTo(v7) < 0, true);
    });

    test('test json', () async {
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

      final s1Json = e1.toJson();
      expect(s1Json, isA<Map<String, dynamic>>());
      expect(s1Json.isNotEmpty, true);
      expect(s1Json.keys.contains("type"), true);

      // Rebuild
      final e2 = Entry.fromJson(s1Json);
      expect(e2.cmphash, e1.cmphash);
      expect(e2.compareTo(e1), 0);
    });

    test('test bookmarked', () async {
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

      final List<SchoolClass> ls1 = [
        SchoolClass(1, "12", true),
        SchoolClass(1, "13", true),
      ];
      final List<SchoolClass> ls2 = [
        SchoolClass(1, "12", false),
        SchoolClass(1, "13", true),
      ];
      final List<SchoolClass> ls3 = [
        SchoolClass(1, "13", true),
      ];

      expect(e1.match(ls1), true);
      // Theoretically this should not be, but we do not check SchoolClass bookmark there
      // because the bookmark could be because of the school type!
      expect(e1.match(ls2), true);
      expect(e1.match(ls3), false);
    });

  });
}