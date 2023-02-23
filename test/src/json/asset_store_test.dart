import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
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
          );
          expect(realAssetStore.assets, contains(assetReferenceReference));
        },
      );
    },
  );
}
