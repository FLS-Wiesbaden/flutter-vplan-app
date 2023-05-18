import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localstorage/localstorage.dart';

abstract class IStorage {
  Future<bool> containsKey({required String key});
  Future<String?> read({required String key});
  Future<Map<String, String>> readAll();
  Future<void> write({required String key, required String? value});
}
abstract class ICollection {
  Future<void> clear();
  Future<void> deleteItem(String key);
  void dispose();
  dynamic getItem(String key);
  Future<void> setItem(String key, dynamic value);
}

class SecureStorage extends FlutterSecureStorage implements IStorage {}

class MockStorage implements IStorage {

  final Map<String, String> _db = {};

  @override
  Future<bool> containsKey({required String key}) async {
    return _db.containsKey(key);
  }

  @override
  Future<String?> read({required String key}) async {
    if (await containsKey(key: key)) {
      return _db[key];
    } else {
      return null;
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    return _db;
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _db.remove(key);
    } else {
      _db[key] = value;
    }
  }
}
