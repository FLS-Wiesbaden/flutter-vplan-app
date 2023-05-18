import 'dart:convert';

import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';
import 'package:de_fls_wiesbaden_vplan/storage/schoolclassstorage.dart';

void main() {
  group('lessons', () {
    IStorage storage = MockStorage();
    Config(storage: storage, overwrite: true);
    final scs = SchoolClassStorage();

    test('test lesson bookmark', () {
      final subject = Subject(name: "Mathematics", shortcut: "MATH");
      final teacher = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      Lesson l = Lesson('12', subject, teacher, false);
      expect(l.bookmarked, false);
      expect(l.isBookmarked(), false);
      l.setBookmarked(true);
      expect(l.bookmarked, true);
      expect(l.isBookmarked(), true);

      Lesson l2 = Lesson('12', subject, teacher, true);
      expect(l2.bookmarked, true);
      expect(l2.isBookmarked(), true);
      l2.toggleBookmarked();
      expect(l2.bookmarked, false);
      expect(l2.isBookmarked(), false);

      // Here, both lessons are same - except of the bookmark.
      // Comparism must still return 0.
      expect(l.compareTo(l2), 0);

      // And we can verify the hash code.
      expect(l.hashCode, l2.hashCode);

      // Check correct json
      expect(
        jsonEncode(l),
          '{"name":"12","subject":{"name":"Mathematics","shortcut":"MATH"},"teacher":{"firstName":"Max","lastName":'
          '"Mustermann","shortcut":"MMAX","bookmarked":false},"bookmarked":true}');

      // Convert back
      final rl = Lesson.fromJson(jsonDecode('{"name":"12","subject":{"name":"Mathematics","shortcut":"MATH"},"teacher":'
                                            '{"firstName":"Max","lastName":"Mustermann","shortcut":"MMAX",'
                                            '"bookmarked":false},"bookmarked":true}'));
      expect(rl.compareTo(l), 0);
    });

    test('compare order', () {
      final subject = Subject(name: "Mathematics", shortcut: "MATH");
      final teacher = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      Lesson l12 = Lesson('12', subject, teacher, true);
      Lesson l11w = Lesson('11/4 W', subject, teacher, true);

      expect(l12.compareTo(l12), 0);
      expect(l12.compareTo(l11w) > 0, true);
      expect(l11w.compareTo(l12) < 0, true);
    });

    test('add/remove a lesson', () async {
      final subject = Subject(name: "Mathematics", shortcut: "MATH");
      final teacher = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      Lesson l = Lesson('12', subject, teacher, false);
      scs.addLesson(l);
      expect(scs.getBookmarkedLessons().isEmpty, true);
      l.setBookmarked(true);
      expect(scs.getBookmarkedLessons().isEmpty, false);

      // After removing, it must empty again!
      scs.removeLesson(l);
      expect(scs.getBookmarkedLessons().isEmpty, true);

      // Test clear/reset. For this, we need to add again.
      scs.addLesson(l);
      expect(scs.getBookmarkedLessons().isEmpty, false);
      scs.clearLessons();
      expect(scs.getBookmarkedLessons().isEmpty, true);
    });
  });

  test('test lesson text', () async {
      final subject = Subject(name: "Mathematics", shortcut: "MATH");
      final teacher = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      Lesson l = Lesson('12', subject, teacher, false);
      expect(l.getText(), "12 hat Mathematics bei M. Mustermann");
  });

  test('test lesson by Entry', () async {
      final subject = Subject(name: "Mathematics", shortcut: "MATH");
      final teacher = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
      final e = Entry(
          startDateTime: DateTime.now(), 
          endDateTime: DateTime.now().add(const Duration(minutes: 90)), 
          hourText: "1.-2.", 
          className: "12", 
          school: 1, 
          entryType: 1024, 
          teacher: teacher, 
          subject: subject, 
          cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
      final l = Lesson.fromEntry(e);
      expect(l.name, "12");
      expect(l.subject.compareTo(subject), 0);
      expect(l.teacher.compareTo(teacher), 0);
  });

  test('test compare entries', () async {
    final s1 = Subject(name: "Mathematics", shortcut: "MATH");
    final s2 = Subject(name: "Chemistry", shortcut: "CHEM");
    final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
    final t2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MMRF");
    final l0 = Lesson('12', s1, t1, false);
    final l1 = Lesson('12', s1, t1, false);
    final l2 = Lesson('12', s2, t1, false);
    final l3 = Lesson('12', s1, t2, false);

    expect(l0.compareTo(l1), 0);
    expect(l0.compareTo(l2) > 0, true);
    expect(l3.compareTo(l0) < 0, true);
  });

  test('test hash', () async {
    final s1 = Subject(name: "Mathematics", shortcut: "MATH");
    final s2 = Subject(name: "Chemistry", shortcut: "CHEM");
    final t1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMAX");
    final t2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MMRF");

    final e1 = Entry(
          startDateTime: DateTime.now(), 
          endDateTime: DateTime.now().add(const Duration(minutes: 90)), 
          hourText: "1.-2.", 
          className: "12", 
          school: 1, 
          entryType: 1024, 
          teacher: t1, 
          subject: s1, 
          cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
    final e2 = Entry(
          startDateTime: DateTime.now(), 
          endDateTime: DateTime.now().add(const Duration(minutes: 90)), 
          hourText: "1.-2.", 
          className: "12", 
          school: 1, 
          entryType: 1024, 
          teacher: t2, 
          subject: s2, 
          cmphash: "4687168c-7f9f-4efa-b534-c06371a63506");
    expect(Lesson.getHashOfEntry(e1) != Lesson.getHashOfEntry(e2), true);
  });
}