import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final file = File('preferences.json');

  void deletePreferences() {
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }
  }

  group(
    'Preferences',
    () {
      setUp(deletePreferences);
      tearDown(deletePreferences);
      final preferences = Preferences(file: file);
      test(
        'Initialise',
        () {
          expect(preferences.file, file);
          expect(preferences.key, defaultPreferencesKey);
          expect(file.existsSync(), false);
        },
      );
      test(
        '.cache',
        () {
          final cache = preferences.cache;
          expect(cache, isEmpty);
          cache['hello'] = 'world';
          expect(preferences.cache['hello'], 'world');
          cache.remove('hello');
          expect(preferences.cache, isEmpty);
          expect(file.existsSync(), false);
        },
      );
      test(
        '.save()',
        () {
          final cache = preferences.cache;
          cache['hello'] = 'world';
          cache['1'] = 2;
          preferences.save();
          expect(file.existsSync(), true);
          final data = file.readAsStringSync();
          final json = jsonDecode(data) as Map<String, dynamic>;
          expect(json.containsKey(preferences.key), true);
          final map = json[preferences.key] as Map<String, dynamic>;
          expect(map.keys.length, cache.keys.length);
          expect(map['hello'], 'world');
          expect(map['1'], 2);
        },
      );
      test(
        '.set()',
        () {
          final cache = preferences.cache..clear();
          preferences.set('hello', 'world');
          expect(cache['hello'], 'world');
          preferences.set('test', 'ing');
          expect(cache['test'], 'ing');
          expect(file.existsSync(), true);
        },
      );
      test(
        '.getString',
        () {
          const key = 'player_name';
          expect(preferences.getString(key), isNull);
          expect(preferences.getString(key, 'John'), 'John');
          expect(preferences.cache.containsKey(key), false);
          preferences.setString(key, 'Bill');
          expect(preferences.getString(key, 'Aaron'), 'Bill');
          expect(preferences.getString(key), 'Bill');
        },
      );
      test(
        '.getInt',
        () {
          const key = 'age';
          expect(preferences.getInt(key), isNull);
          expect(preferences.getInt(key, 42), 42);
          expect(preferences.cache.containsKey(key), false);
          preferences.setInt(key, 32);
          expect(preferences.getInt(key, 85), 32);
          expect(preferences.getInt(key), 32);
        },
      );
      test(
        '.getDouble',
        () {
          const key = 'xCoordinate';
          expect(preferences.getDouble(key), null);
          expect(preferences.getDouble(key, 4.5), 4.5);
          expect(preferences.cache.containsKey(key), false);
          const value = 82.8;
          preferences.setDouble(key, value);
          expect(preferences.getDouble(key, pi), value);
          expect(preferences.getDouble(key), value);
        },
      );
      test(
        '.getBool',
        () {
          const key = 'dead';
          expect(preferences.getBool(key, true), true);
          expect(preferences.getBool(key), isNull);
          expect(preferences.cache.containsKey(key), isFalse);
          preferences.setBool(key, false);
          expect(preferences.getBool(key, true), false);
          expect(preferences.getBool(key), false);
        },
      );
    },
  );
}
