import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final random = Random();
  group('DirectoryMethods', () {
    test('.randomFile', () {
      final directory = Directory('test');
      expect(
        [
          for (final entity in directory.listSync())
            if (entity is File) entity.path
        ],
        contains(directory.randomFile(random).path),
      );
    });
  });
  group('FileSystemEntityMethods', () {
    test('.ensureFile', () {
      final directory = Directory('test');
      for (final entity in directory.listSync()) {
        if (entity is File) {
          expect(entity.ensureFile(random), equals(entity));
          break;
        } else if (entity is Directory) {
          final filenames = [
            for (final subEntity in entity.listSync())
              if (subEntity is File) subEntity.path
          ];
          expect(filenames, contains(entity.ensureFile(random).path));
          break;
        }
      }
    });
  });
  group(
    'SizeExtensions',
    () {
      test(
        '.kb',
        () {
          expect(1.kb, 1024);
          expect(2.kb, 2048);
        },
      );
      test(
        '.mb',
        () {
          expect(1.mb, 1048576);
          expect(10.mb, 10485760);
        },
      );
      test(
        '.gb',
        () {
          expect(1.gb, 1048576);
          expect(10.gb, 10485760);
        },
      );
    },
  );
}
