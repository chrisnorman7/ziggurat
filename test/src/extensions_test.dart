import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final random = Random();
  group(
    'Point<double>',
    () {
      test(
        '.angleBetween',
        () {
          const origin = Point(0.0, 0.0);
          expect(origin.angleBetween(const Point(0.0, 1.0)), 0.0);
          expect(origin.angleBetween(const Point(1.0, 1.0)), 45.0);
          expect(origin.angleBetween(const Point(1.0, 0.0)), 90.0);
          expect(origin.angleBetween(const Point(1, -1)), 135.0);
          expect(origin.angleBetween(const Point(0, -1)), 180.0);
          expect(origin.angleBetween(const Point(-1, -1)), 225.0);
          expect(origin.angleBetween(const Point(-1, 0)), 270.0);
          expect(origin.angleBetween(const Point(-1, 1)), 315.0);
        },
      );
    },
  );
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
        'kb',
        () {
          expect(kilobytes, 1024);
        },
      );
      test(
        '.kb',
        () {
          expect(1.kb, 1024);
          expect(2.kb, 2048);
          expect(10.kb, 10240);
        },
      );
      test(
        'mb',
        () {
          expect(megabytes, 1048576);
        },
      );
      test(
        '.mb',
        () {
          expect(1.mb, megabytes);
          expect(2.mb, megabytes * 2);
          expect(10.mb, megabytes * 10);
        },
      );
      test(
        'gb',
        () {
          expect(gigabytes, 1073741824);
        },
      );
      test(
        '.gb',
        () {
          expect(1.gb, gigabytes);
          expect(2.gb, gigabytes * 2);
          expect(10.gb, gigabytes * 10);
        },
      );
      test(
        'tb',
        () {
          expect(terabytes, gigabytes * 1024);
        },
      );
      test(
        '.tb',
        () {
          expect(1.tb, terabytes);
          expect(2.tb, terabytes * 2);
          expect(10.tb, terabytes * 10);
        },
      );
    },
  );
}
