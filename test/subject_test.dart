import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';

void main() {
  group('subject', () {
    test('test subject displays', () {
      final s = Subject(name: "Mathematics", shortcut: "MATH");
      expect(s.name, "Mathematics");
      expect(s.shortcut, "MATH");
    });
    test('test subject merge', () {
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final s2 = Subject(name: "Chemics", shortcut: "CHEM");
      s1.merge(s2);
      expect(s1.name, s2.name);
      expect(s1.shortcut, s2.shortcut);
    });
    test('test subject json', () {
      const s2Json = '{"name":"Mathematics","shortcut":"MATH"}';
      final s1 = Subject(name: "Mathematics", shortcut: "MATH");
      final s1Json = jsonEncode(s1.toJson());
      final s2 = Subject.fromJson(jsonDecode(s2Json));
      expect(s1.name, s2.name);
      expect(s1.shortcut, s2.shortcut);
      expect(s1Json, s2Json);
    });
  });
}