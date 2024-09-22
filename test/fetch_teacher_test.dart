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
import 'package:nock/nock.dart';
import 'helper/mock.dart';

// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
@GenerateMocks([http.Client])
void main() {

  setUpAll(nock.init);

  setUp(() {
    nock.cleanAll();
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  packageInfoMock();

  group('fetchTeachers', () {
    test('returns a list of teachers if the http call completes successfully', () async {
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmock"}');

      final interceptor = nock('https://www.fls-wiesbaden.de')
        .get('/geco/teacher')
        ..headers({
          'Authorization': 'Bearer flsmock',
        })
        ..reply(200, {
          "MMFR": {"id": 197,"userId": null,"firstName": "Maxi","lastName": "Musterfrau","shortcut": "MMFR"},
          "MMAM": {"id": 63,"userId": null,"firstName": "Max","lastName": "Mustermann","shortcut": "MMAM"}
        });

      TeacherStorage ts = TeacherStorage();
      final result = await ts.fetchTeachers();
      expect(result, isA<List<Teacher>>());
      expect(result?.length, 2);
      expect(result?.first.shortcut, "MMFR");
      expect(result?.first.firstName, "Maxi");
    });

    test('could return exception as well', () async {
      // Destroy config if set.
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmockfail"}');

      final interceptor = nock('https://www.fls-wiesbaden.de')
        .get('/geco/teacher')
        ..headers({
          'Authorization': 'Bearer flsmockfail',
        })
        ..reply(401, '');

      try {
        TeacherStorage ts = TeacherStorage();
        await ts.fetchTeachers();
        fail('exception not thrown!');
      } catch (e) {
        expect(e, isInstanceOf<NetConnectionNotAllowed>());
      }
    });

    test('load teacher list and ensure it is stored', () async {
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmock"}');

      final TeacherStorage tstg = TeacherStorage();
      final LocalStorage lstg = LocalStorage(TeacherStorage.collectionName);

      final interceptor = nock('https://www.fls-wiesbaden.de')
        .get('/geco/teacher')
        ..headers({
          'Authorization': 'Bearer flsmock',
        })
        ..reply(200, {
          "MMFR": {"id": 197,"userId": null,"firstName": "Maxi","lastName": "Musterfrau","shortcut": "MMFR"},
          "MMAM": {"id": 63,"userId": null,"firstName": "Max","lastName": "Mustermann","shortcut": "MMAM"}
        });

      await tstg.load();
      expect(tstg.teachers, isA<List<Teacher>>());
      expect(tstg.teachers.length, 2);
      expect(lstg.getItem('fetched'), isNotNull);
      expect(lstg.getItem('data'), isA<List<Teacher>>());
    });

  });
}