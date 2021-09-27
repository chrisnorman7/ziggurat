import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('AssetReference', () {
    test('Initialisation', () {
      var ar = AssetReference('test', AssetType.file);
      expect(ar.name, equals('test'));
      expect(ar.type, equals(AssetType.file));
      expect(ar.encryptionKey, isNull);
      ar = AssetReference.collection('collection');
      expect(ar.name, equals('collection'));
      expect(ar.type, equals(AssetType.collection));
      expect(ar.encryptionKey, isNull);
      ar = AssetReference.file('file');
      expect(ar.name, equals('file'));
      expect(ar.type, equals(AssetType.file));
      expect(ar.encryptionKey, isNull);
      ar = AssetReference.collection('collection', encryptionKey: 'asdf123');
      expect(ar.name, equals('collection'));
      expect(ar.type, equals(AssetType.collection));
      expect(ar.encryptionKey, equals('asdf123'));
      ar = AssetReference.file('file', encryptionKey: 'asdf123');
      expect(ar.name, equals('file'));
      expect(ar.type, equals(AssetType.file));
      expect(ar.encryptionKey, equals('asdf123'));
    });
    test('.load', () {
      final encryptionKey = SecureRandom(32).base64;
      final random = Random();
      final ar = AssetReference.file('SDL2.dll', encryptionKey: encryptionKey);
      expect(() => ar.load(random), throwsArgumentError);
      expect(AssetReference.file(ar.name).load(random),
          equals(File(ar.name).readAsBytesSync()));
      final file = File(ar.name);
      final data = file.readAsBytesSync();
      final key = Key.fromBase64(encryptionKey);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encryptBytes(data, iv: iv);
      final encryptedFile = File(ar.name + '.encrypted')
        ..writeAsBytesSync(encrypted.bytes);
      final encryptedAssetReference =
          AssetReference.file(encryptedFile.path, encryptionKey: encryptionKey);
      expect(encryptedAssetReference.load(random),
          equals(File(ar.name).readAsBytesSync()));
      encryptedFile.deleteSync();
    });
    test('.getFile', () {
      final random = Random();
      var reference = AssetReference.file('SDL2.dll');
      var file = reference.getFile(random);
      expect(file.path, equals(reference.name));
      reference = AssetReference.collection('test');
      file = reference.getFile(random);
      final filenames = <String>[
        for (final file in Directory('test').listSync()) file.path
      ];
      expect(filenames, contains(file.path));
    });
  });
  group('AssetStore', () {
    late Directory tempDirectory;
    setUp(() => tempDirectory = Directory('.').createTempSync());
    tearDown(() => tempDirectory.deleteSync(recursive: true));
    test('Initialise', () {
      var store = AssetStore('test.dart');
      expect(store.filename, equals('test.dart'));
      expect(store.comment, isNull);
      expect(store.assets, isEmpty);
      store = AssetStore(store.filename, comment: 'Testing.');
      expect(store.filename, equals('test.dart'));
      expect(store.assets, isEmpty);
      expect(store.comment, equals('Testing.'));
      store = AssetStore(store.filename, assets: [
        AssetReferenceReference(
            variableName: 'firstFile',
            reference: AssetReference.file('file1.wav')),
        AssetReferenceReference(
            variableName: 'firstDirectory',
            reference: AssetReference.collection('directory1'))
      ]);
      expect(store.filename, equals('test.dart'));
      expect(store.comment, isNull);
      expect(store.assets.length, equals(2));
    });
    test('.importFile', () {
      final random = Random();
      final store = AssetStore('test.dart');
      final file = File('SDL2.dll');
      final reference = store.importFile(
          file: file,
          directory: tempDirectory,
          variableName: 'sdlDll',
          comment: 'The SDL DLL.');
      expect(reference, isA<AssetReferenceReference>());
      expect(tempDirectory.listSync().length, equals(1));
      final sdlDll = tempDirectory.listSync().first;
      expect(sdlDll, isA<File>());
      sdlDll as File;
      expect(sdlDll.path,
          equals(path.join(tempDirectory.path, file.path + '.encrypted')));
      expect(store.assets.length, equals(1));
      expect(store.assets.first, equals(reference));
      expect(reference.variableName, equals('sdlDll'));
      expect(reference.comment, equals('The SDL DLL.'));
      expect(reference.reference.name,
          equals(path.join(tempDirectory.path, file.path + '.encrypted')));
      expect(reference.reference.type, equals(AssetType.file));
      expect(reference.reference.load(random), equals(file.readAsBytesSync()));
    });
    test('.importDirectory', () {
      final testDirectory = Directory('test');
      final store = AssetStore('test.dart');
      final reference = store.importDirectory(
          directory: testDirectory,
          destination: tempDirectory,
          variableName: 'tests',
          comment: 'Tests directory.');
      expect(reference, isA<AssetReferenceReference>());
      expect(store.assets.length, equals(1));
      expect(store.assets.first, equals(reference));
      final unencryptedEntities = testDirectory.listSync()
        ..sort((a, b) => a.path.compareTo(b.path));
      final encryptedEntities = tempDirectory.listSync()
        ..sort((a, b) => a.path.compareTo(b.path));
      expect(unencryptedEntities.length, equals(encryptedEntities.length));
      for (var i = 0; i < unencryptedEntities.length; i++) {
        final unencryptedFile = unencryptedEntities[i];
        if (unencryptedFile is! File) {
          continue;
        }
        final encryptedFile = encryptedEntities[i] as File;
        final key = Key.fromBase64(reference.reference.encryptionKey!);
        final iv = IV.fromLength(16);
        final encrypter = Encrypter(AES(key));
        final encrypted = Encrypted(encryptedFile.readAsBytesSync());
        final data = encrypter.decryptBytes(encrypted, iv: iv);
        expect(data, equals(unencryptedFile.readAsBytesSync()),
            reason: 'File ${encryptedFile.path} did not decrypt to '
                '${unencryptedFile.path}.');
      }
    });
    test('Import both', () {
      final store = AssetStore('test.dart')
        ..importFile(
            file: File('SDL2.dll'),
            directory: tempDirectory,
            variableName: 'sdlDll')
        ..importDirectory(
            directory: Directory('test'),
            destination: tempDirectory,
            variableName: 'testsDirectory');
      expect(store.assets.length, equals(2));
    });
  });
}
