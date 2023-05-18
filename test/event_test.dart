import 'dart:convert';

import 'package:de_fls_wiesbaden_vplan/models/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('event', () {
    test('test event', () {
      final eventStart = DateTime.now();
      final eventEnd = eventStart.add(const Duration(days: 5));
      final eventMiddle = eventStart.add(const Duration(days: 4));
      final eventOutsideNext = eventStart.add(const Duration(days: 6));
      final eventOutsidePrev = eventStart.subtract(const Duration(days: 10));
      const caption = "Test Event";
      final evt = Event(eventStart: eventStart, eventEnd: eventEnd, caption: caption);
      expect(evt.caption, caption);
      expect(evt.matchDate(eventMiddle), true);
      expect(evt.matchDate(eventOutsideNext), false);
      expect(evt.matchDate(eventOutsidePrev), false);
    });
  });

  test('test event json', () {
    final eventStart = DateTime.now();
    final eventEnd = eventStart.add(const Duration(days: 5));  
    const caption = "Test Event";
    final e2Json = '{"eventStart":"${eventStart.toIso8601String()}","eventEnd":"${eventEnd.toIso8601String()}",'
                   '"caption":"$caption","id":null,"type":null,"noLesson":false,"guid":null}';
    final e1 = Event(eventStart: eventStart, eventEnd: eventEnd, caption: caption);
    final e1Json = jsonEncode(e1.toJson());
    expect(e1Json, e2Json);

    // load data
    final e2 = Event.fromJson(jsonDecode(e2Json));
    expect(e1.caption, e2.caption);
    expect(e1.eventStart, e2.eventStart);
    expect(e1.eventEnd, e2.eventEnd);
  });
}