import 'dart:io';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/ziggurat.dart';

/// A file system entity has been selected.
class OnDoneException implements Exception {
  /// Create an instance.
  OnDoneException(this.entity);

  /// The entity to use.
  final FileSystemEntity entity;
}

void main() {
  final sdl = Sdl();
  group('FilePickerMenu', () {
    test('Initialise', () {
      final currentDirectory = Directory('test');
      FileSystemEntity? thing;
      final game = Game(
        title: 'File Picker Menu',
        sdl: sdl,
      );
      final menu = FilePickerMenu(
        game: game,
        onDone: (final entity) => thing = entity,
        start: currentDirectory,
      );
      expect(menu.allowDirectories, isFalse);
      expect(menu.showFiles, isTrue);
      expect(menu.currentDirectory, currentDirectory);
      expect(
        menu.menuItems.length,
        currentDirectory.listSync().length + 1,
      );
      expect(menu.menuItems.first.label.text, equals('..'));
      expect(thing, isNull);
    });
    test('.onDone', () {
      final game = Game(
        title: 'FilePickerMenu.onDone',
        sdl: sdl,
      );
      final directory = Directory('test');
      final menu = FilePickerMenu(
        game: game,
        onDone: (final entity) => throw OnDoneException(entity),
        start: directory,
      );
      game.pushLevel(menu);
      final directories = <Directory>[];
      final files = <File>[];
      for (final entity in directory.listSync()) {
        if (entity is Directory) {
          directories.add(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }
      for (var i = 0; i < directories.length; i++) {
        final expected = directories[i];
        menu.position = i + 1;
        final name = path.basename(expected.path);
        expect(
          menu.currentMenuItem?.label.text,
          '$name ${expected is File ? "file" : "directory"}',
        );
        menu.activate();
        expect(
          game.currentLevel,
          predicate(
            (final value) =>
                value is FilePickerMenu &&
                value.currentDirectory.path == expected.path,
          ),
        );
        game.replaceLevel(menu);
      }
      for (var i = 0; i < files.length; i++) {
        final expected = files[i];
        menu.position = i + (directories.length + 1);
        expect(
          menu.activate,
          throwsA(
            predicate(
              (final value) =>
                  value is OnDoneException &&
                  value.entity.path == expected.path,
            ),
          ),
        );
      }
    });
    test('Parent directory', () {
      final game = Game(
        title: 'FilePickerMenu Parent Directory',
        sdl: sdl,
      );
      final directory = Directory('test');
      final menu = FilePickerMenu(
        game: game,
        onDone: print,
        start: directory,
      );
      game.pushLevel(menu);
      menu.down();
      expect(menu.currentMenuItem?.label.text, equals('..'));
      menu.activate();
      expect(game.currentLevel, isNot(menu));
      expect(game.currentLevel, isA<FilePickerMenu>());
      expect(game.currentLevel, isNot(menu));
      final newMenu = game.currentLevel! as FilePickerMenu;
      expect(
        newMenu.currentDirectory.path,
        equals(directory.parent.path),
      );
      expect(newMenu.onDone, equals(menu.onDone));
    });
  });
}
