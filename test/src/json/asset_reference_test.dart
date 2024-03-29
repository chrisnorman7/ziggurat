import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/util.dart';
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
      final file = File('SDL2.dll');
      final encryptionKey = generateEncryptionKey();
      final random = Random();
      final ar = AssetReference.file(file.path, encryptionKey: encryptionKey);
      expect(() => ar.load(random), throwsArgumentError);
      expect(
        AssetReference.file(file.path).load(random),
        file.readAsBytesSync(),
      );
      final encryptedFile = File('${file.path}.encrypted');
      encryptFile(
        inputFile: file,
        outputFile: encryptedFile,
        encryptionKey: encryptionKey,
      );
      final encryptedAssetReference = AssetReference.file(
        encryptedFile.path,
        encryptionKey: encryptionKey,
      );
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
    test('.file', () {
      const sound = AssetReference.file('test.wav');
      expect(sound.name, equals('test.wav'));
      expect(sound.type, equals(AssetType.file));
    });
    test(
      '.collection',
      () {
        const sound = AssetReference.collection('testing');
        expect(sound.name, equals('testing'));
        expect(sound.type, equals(AssetType.collection));
      },
    );
    test(
      '.copy',
      () {
        const file = AssetReference(
          'test',
          AssetType.file,
          encryptionKey: 'asdf123',
        );
        expect(file.gain, 0.7);
        final copyFile = file.copy(1.0);
        expect(copyFile.encryptionKey, file.encryptionKey);
        expect(copyFile.gain, 1.0);
        expect(copyFile.name, file.name);
        expect(copyFile.type, file.type);
        const directory = AssetReference(
          'directory',
          AssetType.collection,
          encryptionKey: 'proper secure',
          gain: 2.0,
        );
        expect(directory.gain, 2.0);
        final copyDirectory = directory.copy(0.5);
        expect(copyDirectory.encryptionKey, directory.encryptionKey);
        expect(copyDirectory.gain, 0.5);
        expect(copyDirectory.name, directory.name);
        expect(copyDirectory.type, directory.type);
      },
    );
    test(
      '.silent',
      () {
        const file = AssetReference.file(
          'sound.mp3',
          encryptionKey: 'asdf123',
          gain: 1.0,
        );
        final silentFile = file.silent();
        expect(silentFile.encryptionKey, file.encryptionKey);
        expect(silentFile.gain, 0.0);
        expect(silentFile.name, file.name);
        expect(silentFile.type, file.type);
        const directory = AssetReference.collection(
          'footsteps',
          encryptionKey: 'lovely thing',
          gain: 0.25,
        );
        final silentDirectory = directory.silent();
        expect(silentDirectory.encryptionKey, directory.encryptionKey);
        expect(silentDirectory.gain, 0.0);
        expect(silentDirectory.name, directory.name);
        expect(silentDirectory.type, directory.type);
      },
    );
  });
}
