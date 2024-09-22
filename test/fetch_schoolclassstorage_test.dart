import 'dart:convert';
import 'dart:io';

import 'package:de_fls_wiesbaden_vplan/models/schooltype.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/storage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:de_fls_wiesbaden_vplan/storage/schoolclassstorage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'fetch_schoolclassstorage_test.mocks.dart';
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

  group('fetchSchoolClass', () {
    test('_loading (only initialized)', () {
      final scs = SchoolClassStorage();
      expect(scs.isLoading(), false);
    });

    test('returns a list of classes if the http call completes successfully', () async {
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmock"}');

      final interceptor = nock('https://www.fls-wiesbaden.de')
        .get('/geco/vplan/loadClasses')
        ..headers({
          'Authorization': 'Bearer flsmock',
        })
        ..reply(200, [
          {"shortcut":"InteA","schoolType":2},
          {"shortcut":"13","schoolType":1},
          {"shortcut":"12","schoolType":1}
        ]);

      final scs = SchoolClassStorage();

      final result = await scs.downloadClasses();
      expect(result, isNotNull);
      expect(result, isA<Map<String, SchoolClass>>());
      expect(result?.length, 3);
      for (var f in ['InteA', '13', '12']) {
        expect(result?.containsKey(f), isTrue);
      }
    });

    test('interacting and testing class storages', () async {
      final scs = SchoolClassStorage();
      expect(scs.getListOfClass().isEmpty, true);
      // Add a simple type
      scs.updateTypes([
        SchoolType(1, 'BG', false),
        SchoolType(2, 'BFS', false),
      ]);

      List<SchoolClass> scl = [];
      scl.add(SchoolClass(1, '11/4 W', false));
      scl.add(SchoolClass(1, '12', false));
      scl.add(SchoolClass(2, '1121', false));
      SchoolClass sc13 = SchoolClass(1, '13', false);

      scs.add(sc13);
      expect(scs.getListOfClass().isNotEmpty, true);

      scs.clearClasses();
      expect(scs.getListOfClass().isEmpty, true);

      scs.add(sc13);
      scs.remove(sc13);
      expect(scs.getListOfClass().isEmpty, true);

      for (var sc in scl) {
        scs.add(sc);
      }
      expect(scs.getListOfClass().length, scl.length);
      final clget = scs.getClass('1121');
      expect(clget, isNotNull);
      expect(clget!.name, '1121');
      expect(scs.getClass('2111'), isNull);
      expect(scs.getTypeByClass('11/4 W').schoolTypeId, 1);
      
      // We do not have unknown / zero defined as school type. 
      // We should get an exception
      try {
        scs.getTypeByClass('9191');
        fail('exception not thrown!');
      } catch (e) {
        expect(e, isInstanceOf<SchoolTypeNotFoundException>());
      }
    });

    test('bookmarked classes', () {
      final scs = SchoolClassStorage();
      // Prepare data for testing.
      scs.updateTypes([
        SchoolType(1, 'BG', false),
        SchoolType(2, 'BFS', false),
      ]);
      List<SchoolClass> scl = [];
      scl.add(SchoolClass(1, '11/4 W', false));
      scl.add(SchoolClass(1, '12', false));
      scl.add(SchoolClass(2, '1121', false));
      for (var sc in scl) {
        scs.add(sc);
      }

      // At beginning, nothing should be bookmarked.
      expect(scs.getBookmarked().isEmpty, true);
      // Same applies based on school type
      expect(scs.getBookmarkedByType().isEmpty, true);
      // Set a type.
      scs.getType(1).setBookmarked(true);
      expect(scs.getBookmarkedByType().isNotEmpty, true);
      scs.getType(1).setBookmarked(false);
      expect(scs.getBookmarkedByType().isEmpty, true);

      // Now test based on class directly.
      scs.getClass('11/4 W')!.setBookmarked(true);
      expect(scs.getBookmarked().isNotEmpty, true);
      scs.getClass('11/4 W')!.setBookmarked(false);
      expect(scs.getBookmarked().isEmpty, true);
    });

    test('returns a list of school types if the http call completes successfully', () async {
      // Prepare configuration
      IStorage storage = MockStorage();
      Config cfg = Config(storage: storage, overwrite: true);
      cfg.setAuthJwt('{"access_token": "flsmock"}');

      final scs = SchoolClassStorage();

      final interceptor = nock('https://www.fls-wiesbaden.de')
        .get('/geco/vplan/loadSchoolTypes')
        ..headers({
          'Authorization': 'Bearer flsmock',
        })
        ..reply(200, ["Unbekannt","BG","BS","BFS","HBFS"]);

      final result = await scs.downloadSchoolTypes();
      expect(result, isNotNull);
      expect(result.types, isNotNull);
      expect(result.types, isA<List<SchoolType>>());
      expect(result.types?.length, 5);
      for (var f in ['Unbekannt', 'BG', 'BS', 'BFS', 'HBFS']) {
        expect(result.types?.indexWhere((element) => element.name == f), isNonNegative);
      }
    });

    test('update school type list', () async {
      final scs = SchoolClassStorage();
      assert(scs.getNumberOfTypes() == 0);

      List<SchoolType> stl = [];
      stl.add(SchoolType(1, 'BG', false));
      stl.add(SchoolType(2, 'BS', false));
      stl.add(SchoolType(3, 'BFS', false));
      assert(stl.length == 3);

      // Update list to storage
      scs.updateTypes(stl);

      // Content should be 3.
      expect(scs.getNumberOfTypes(), stl.length);
      // Check whether entries match
      expect(jsonEncode(stl.elementAt(0).toJson()), jsonEncode(scs.getType(1).toJson()));
      
      // Check same list.
      expect(scs.getListOfTypes().length, stl.length);

      // compare bookmarked types
      expect(scs.getBookmarkedTypes().isEmpty, true);
      scs.getListOfTypes().first.setBookmarked(true);
      expect(scs.getBookmarkedTypes().isNotEmpty, true);

      // check if data get deleted.
      scs.clearTypes();
      expect(scs.getNumberOfTypes(), 0);

      // add entries again
      scs.updateTypes(stl);
      expect(scs.getNumberOfTypes(), stl.length);
      // Now update, but with types null.
      scs.updateTypes(null);
      expect(scs.getNumberOfTypes(), 0);
    });
  });
}