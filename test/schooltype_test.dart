import 'dart:convert';

import 'package:de_fls_wiesbaden_vplan/models/schooltype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('schooltype', () {
    test('test school type merge', () {
      final sc1 = SchoolType(1, "BG", false);
      final sc2 = SchoolType(5, "HBFS", false);
      sc1.merge(sc2);
      expect(sc1.name, sc2.name);
      expect(sc1.schoolTypeId != sc2.schoolTypeId, true);
    });

    test('test school type update name', () {
      final sc1 = SchoolType(1, "BG", false);
      sc1.setName("HBFSI");
      expect(sc1.name, "HBFSI");
      expect(sc1.schoolTypeId, 1);
    });

    test('test school type colors', () {
      for(int i = 0; i < 6; i++) {
        final sc1 = SchoolType(i, "BG", false);
        expect(sc1.getGradient(), isA<LinearGradient>());
        expect(sc1.getColor(), isA<Color>());
      }
    });

    test('test school type json', () {
      const scJson = '{"id":1,"name":"BG","bookmarked":false}';
      final sc1 = SchoolType(1, "BG", false);
      final sc1Json = jsonEncode(sc1.toJson());
      expect(sc1Json, scJson);
      final sc2 = SchoolType.fromJson(jsonDecode(scJson));
      expect(sc2.name, sc1.name);
      expect(sc2.schoolTypeId, sc1.schoolTypeId);
      expect(sc2.bookmarked, sc1.bookmarked);
    });
  });
}