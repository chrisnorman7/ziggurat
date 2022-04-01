import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('AssetReference', () {
    test('Initialisation', () {
      var ar = const AssetReference('test', AssetType.file);
      expect(ar.name, equals('test'));
      expect(ar.type, equals(AssetType.file));
      expect(ar.encryptionKey, isNull);
      ar = const AssetReference.collection('collection');
      expect(ar.name, equals('collection'));
      expect(ar.type, equals(AssetType.collection));
      expect(ar.encryptionKey, isNull);
      ar = const AssetReference.file('file');
      expect(ar.name, equals('file'));
      expect(ar.type, equals(AssetType.file));
      expect(ar.encryptionKey, isNull);
      ar = const AssetReference.collection(
        'collection',
        encryptionKey: 'asdf123',
      );
      expect(ar.name, equals('collection'));
      expect(ar.type, equals(AssetType.collection));
      expect(ar.encryptionKey, equals('asdf123'));
      ar = const AssetReference.file('file', encryptionKey: 'asdf123');
      expect(ar.name, equals('file'));
      expect(ar.type, equals(AssetType.file));
      expect(ar.encryptionKey, equals('asdf123'));
    });
    test('.load', () {
      final encryptionKey = SecureRandom(32).base64;
      final random = Random();
      final ar = AssetReference.file('SDL2.dll', encryptionKey: encryptionKey);
      expect(() => ar.load(random), throwsArgumentError);
      expect(
        AssetReference.file(ar.name).load(random),
        equals(File(ar.name).readAsBytesSync()),
      );
      final file = File(ar.name);
      final data = file.readAsBytesSync();
      final key = Key.fromBase64(encryptionKey);
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encryptBytes(data, iv: iv);
      final encryptedFile = File('${ar.name}.encrypted')
        ..writeAsBytesSync(encrypted.bytes);
      final encryptedAssetReference =
          AssetReference.file(encryptedFile.path, encryptionKey: encryptionKey);
      expect(
        encryptedAssetReference.load(random),
        equals(File(ar.name).readAsBytesSync()),
      );
      encryptedFile.deleteSync();
    });
    test('.getFile', () {
      final random = Random();
      var reference = const AssetReference.file('SDL2.dll');
      var file = reference.getFile(random);
      expect(file.path, equals(reference.name));
      reference = const AssetReference.collection('test');
      file = reference.getFile(random);
      final filenames = <String>[];
      for (final entity in Directory('test').listSync()) {
        if (entity is File) {
          filenames.add(entity.path);
        }
      }
      expect(filenames, contains(file.path));
    });
  });
}
