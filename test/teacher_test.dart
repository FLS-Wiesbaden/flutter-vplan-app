import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';

void main() {
  group('teacher', () {
    test('test teacher displays', () {
      final s = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMRM");
      expect(s.firstName, "Max");
      expect(s.lastName, "Mustermann");
      expect(s.shortcut, "MMRM");
      expect(s.displayName, "M. Mustermann");
    });
    test('test teacher merge', () {
      final s1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMRM");
      final s2 = Teacher(firstName: "Maxi", lastName: "Musterfrau", shortcut: "MMRF");
      s1.merge(s2);
      expect(s1.firstName, "Maxi");
      expect(s1.lastName, "Musterfrau");
      expect(s1.shortcut, "MMRF");
      expect(s1.displayName, "M. Musterfrau");
    });
    test('test teacher json', () {
      const s2Json = '{"firstName":"Max","lastName":"Mustermann","shortcut":"MMRM","bookmarked":false}';
      final s1 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMRM");
      final s1Json = jsonEncode(s1.toJson());
      final s2 = Teacher.fromJson(jsonDecode(s2Json));
      expect(s1.firstName, s2.firstName);
      expect(s1.lastName, s2.lastName);
      expect(s1.shortcut, s2.shortcut);
      expect(s1.displayName, s2.displayName);
      expect(s1Json, s2Json);
    });
    test('test name display variants', () {
      final s1 = Teacher(firstName: "", lastName: "", shortcut: "MMRM");
      expect(s1.displayName, "MMRM");
      expect(s1.listName, "MMRM");
      final s3 = Teacher(firstName: "Maxi", lastName: "", shortcut: "MMRF");
      expect(s3.displayName, "MMRF");
      expect(s3.listName, "MMRF");
      final s2 = Teacher(firstName: "Max", lastName: "Mustermann", shortcut: "MMRM");
      expect(s2.displayName, "M. Mustermann");
      expect(s2.listName, "Mustermann, Max");
    });
  });
}