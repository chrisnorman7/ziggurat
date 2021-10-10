import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final random = Random();
  group('DirectoryMethods', () {
    test('.randomFile', () {
      final directory = Directory('test');
      expect([
        for (final entity in directory.listSync())
          if (entity is File) entity.path
      ], contains(directory.randomFile(random).path));
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
}
