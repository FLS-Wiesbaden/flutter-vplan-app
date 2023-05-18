import 'dart:convert';

import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('schoolclass', () {
    test('test school class merge', () {
      final sc1 = SchoolClass(2, "1121", false);
      final sc2 = SchoolClass(1, "11/4", false);
      sc1.merge(sc2);
      expect(sc1.name, sc2.name);
      expect(sc1.schoolType, sc2.schoolType);
    });
    test('test school class json', () {
      const scJson = '{"name":"1121","schoolType":2,"bookmarked":false}';
      final sc1 = SchoolClass(2, "1121", false);
      final sc1Json = jsonEncode(sc1.toJson());
      expect(sc1Json, scJson);
      final sc2 = SchoolClass.fromJson(jsonDecode(scJson));
      expect(sc2.name, sc1.name);
      expect(sc2.schoolType, sc1.schoolType);
      expect(sc1.bookmarked, sc2.bookmarked);
    });
  });
}