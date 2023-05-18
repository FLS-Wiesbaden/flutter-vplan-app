import 'dart:io';

import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:de_fls_wiesbaden_vplan/storage/teacherstorage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'fetch_teacher_test.mocks.dart';

// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
@GenerateMocks([http.Client])
void main() {
  group('fetchTeachers', () {
    test('returns a list of teachers if the http call completes successfully', () async {
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmock"}');

      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client
              .get(Uri.parse(await cfg.getEndpoint(subPath: '/teacher')), headers: {HttpHeaders.authorizationHeader: "Bearer flsmock"}))
          .thenAnswer((_) async =>
              http.Response(
              '{"MMFR": {"id": 197,"userId": null,"firstName": "Maxi","lastName": "Musterfrau","shortcut": "MMFR"},'
              '"MMAM": {"id": 63,"userId": null,"firstName": "Max","lastName": "Mustermann","shortcut": "MMAM"}}',
              200));

      final result = await TeacherStorage.fetchTeachers(client: client);
      expect(result, isA<List<Teacher>>());
      expect(result.length, 2);
      expect(result.first.shortcut, "MMFR");
      expect(result.first.firstName, "Maxi");
    });

    test('could return exception as well', () async {
      // Destroy config if set.
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmockfail"}');

      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client
              .get(Uri.parse(await cfg.getEndpoint(subPath: '/teacher')), headers: {HttpHeaders.authorizationHeader: "Bearer flsmockfail"}))
          .thenAnswer((_) async =>
              http.Response('', 401));

      try {
        await TeacherStorage.fetchTeachers(client: client);
        fail('exception not thrown!');
      } catch (e) {
        expect(e, isInstanceOf<Exception>());
      }
    });

    test('load teacher list and ensure it is stored', () async {
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmock"}');

      final client = MockClient();
      final TeacherStorage tstg = TeacherStorage();
      final LocalStorage lstg = LocalStorage(TeacherStorage.collectionName);

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client
              .get(Uri.parse(await cfg.getEndpoint(subPath: '/teacher')), headers: {HttpHeaders.authorizationHeader: "Bearer flsmock"}))
          .thenAnswer((_) async =>
              http.Response(
              '{"MMFR": {"id": 197,"userId": null,"firstName": "Maxi","lastName": "Musterfrau","shortcut": "MMFR"},'
              '"MMAM": {"id": 63,"userId": null,"firstName": "Max","lastName": "Mustermann","shortcut": "MMAM"}}',
              200));

      await tstg.load(client: client);
      expect(tstg.teachers, isA<List<Teacher>>());
      expect(tstg.teachers.length, 2);
      expect(lstg.getItem('fetched'), isNotNull);
      expect(lstg.getItem('data'), isA<List<Teacher>>());
    });

  });
}