import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/util.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final random = Random();
  group(
    'AssetStore',
    () {
      final sdlFile = File('SDL2.dll');
      final assetsDirectory = Directory('test_assets');
      const blankAssetStore = AssetStore(
        filename: 'assets.dart',
        destination: 'assets',
        assets: [],
        comment: 'Test assets.',
      );
      setUp(assetsDirectory.createSync);
      tearDown(
        () => assetsDirectory.deleteSync(recursive: true),
      );

      final realAssetStore = AssetStore(
        filename: 'test_assets.dart',
        destination: assetsDirectory.path,
        assets: [],
      );

      test(
        'Initialise',
        () {
          expect(blankAssetStore.assets, isEmpty);
          expect(blankAssetStore.comment, 'Test assets.');
          expect(blankAssetStore.destination, 'assets');
          expect(blankAssetStore.directory.path, blankAssetStore.destination);
          expect(blankAssetStore.filename, 'assets.dart');
        },
      );

      test(
        '.fromFile',
        () {
          const original = AssetStore(
            filename: 'assets.dart',
            destination: 'assets',
            assets: [
              AssetReferenceReference(
                variableName: 'asset1',
                reference: AssetReference('asset1.mp3', AssetType.file),
                comment: 'An MP3 file.',
              ),
              AssetReferenceReference(
                variableName: 'footsteps',
                reference: AssetReference(
                  'footsteps',
                  AssetType.collection,
                  encryptionKey: 'asdf123',
                  gain: 1.0,
                ),
                comment: 'Footstep sounds.',
              )
            ],
            comment: 'Original assets.',
          );
          final file = File('store.json');
          final data = jsonEncode(original);
          file.writeAsStringSync(data);
          final assetStore = AssetStore.fromFile(file);
          for (var i = 0; i < original.assets.length; i++) {
            final originalAsset = original.assets[i];
            final loadedAsset = assetStore.assets[i];
            expect(loadedAsset.comment, originalAsset.comment);
            expect(
              loadedAsset.reference.encryptionKey,
              originalAsset.reference.encryptionKey,
            );
            expect(loadedAsset.reference.gain, originalAsset.reference.gain);
            expect(loadedAsset.reference.name, originalAsset.reference.name);
            expect(loadedAsset.reference.type, originalAsset.reference.type);
            expect(loadedAsset.variableName, originalAsset.variableName);
          }
          expect(assetStore.comment, original.comment);
          expect(assetStore.destination, original.destination);
          expect(assetStore.filename, original.filename);
          file.deleteSync();
        },
      );

      test(
        '.getAbsoluteDirectory',
        () {
          expect(
            blankAssetStore.getAbsoluteDirectory(Directory('test')).path,
            path.join('test', blankAssetStore.destination),
          );
        },
      );

      test(
        'getNextFilename',
        () {
          expect(
            blankAssetStore.getNextFilename(),
            '${blankAssetStore.destination}/0',
          );
          expect(
            blankAssetStore.getNextFilename(relativeTo: Directory('test')),
            '${blankAssetStore.destination}/0',
          );
          expect(
            blankAssetStore.getNextFilename(suffix: '.encrypted'),
            '${blankAssetStore.destination}/0.encrypted',
          );
          expect(
            blankAssetStore.getNextFilename(
              relativeTo: Directory('test'),
              suffix: '.encrypted',
            ),
            '${blankAssetStore.destination}/0.encrypted',
          );
        },
      );

      test(
        '.importFile',
        () {
          final assetReferenceReference = realAssetStore.importFile(
            source: sdlFile,
            variableName: 'sdl',
            comment: 'SDL file.',
          );
          expect(assetReferenceReference.comment, 'SDL file.');
          expect(assetReferenceReference.reference.encryptionKey, isNotNull);
          expect(assetReferenceReference.reference.gain, 0.7);
          expect(
            assetReferenceReference.reference.name,
            '${realAssetStore.destination}/0.encrypted',
          );
          expect(assetReferenceReference.reference.type, AssetType.file);
          expect(realAssetStore.assets, contains(assetReferenceReference));
          expect(
            assetReferenceReference.reference.load(random),
            sdlFile.readAsBytesSync(),
          );
        },
      );

      test(
        '.importDirectory',
        () {
          realAssetStore.assets.clear();
          final directory = Directory('test');
          final assetReferenceReference = realAssetStore.importDirectory(
            source: directory,
            variableName: 'test',
            comment: 'Test directory.',
          );
          expect(assetReferenceReference.comment, 'Test directory.');
          expect(assetReferenceReference.reference.encryptionKey, isNotNull);
          expect(assetReferenceReference.reference.gain, 0.7);
          expect(
            assetReferenceReference.reference.name,
            '${realAssetStore.destination}/0',
          );
          expect(assetReferenceReference.reference.type, AssetType.collection);
          expect(realAssetStore.assets, contains(assetReferenceReference));
          final files = directory.listSync().whereType<File>().toList();
          final importedDirectory = Directory(
            assetReferenceReference.reference.name,
          );
          final importedEntities = importedDirectory.listSync();
          expect(importedEntities.length, files.length);
          final importedFiles = importedEntities.whereType<File>().toList();
          expect(importedFiles.length, files.length);
          for (var i = 0; i < files.length; i++) {
            final originalFile = files[i];
            final importedFile = importedFiles[i];
            expect(
              decryptFileBytes(
                file: importedFile,
                encryptionKey: assetReferenceReference.reference.encryptionKey!,
              ),
              originalFile.readAsBytesSync(),
            );
          }
        },
      );
    },
  );
}
