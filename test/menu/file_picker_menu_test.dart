import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('FilePickerMenu', () {
    test('Initialise', () {
      FileSystemEntity? thing;
      final game = Game('File Picker Menu');
      final menu = FilePickerMenu(game, (entity) => thing = entity);
      expect(menu.allowDirectories, isFalse);
      expect(menu.showFiles, isTrue);
      expect(menu.menuItems.length,
          equals(Directory.current.listSync().length + 1));
      expect(menu.menuItems.first.label.text, equals('..'));
      expect(menu.currentDirectory.path, equals(Directory.current.path));
      expect(thing, isNull);
    });
    test('.onDone', () {
      FileSystemEntity? thing;
      final game = Game('FilePickerMenu.onDone');
      final menu = FilePickerMenu(game, (entity) => thing = entity);
      game.pushLevel(menu);
      expect(thing, isNull);
      menu
        ..position = menu.menuItems.length - 1
        ..activate();
      expect(thing, isA<File>());
      expect(
          thing!.path, equals(path.join(Directory.current.path, 'SDL2.dll')));
    });
    test('Parent directory', () {
      final game = Game('FilePickerMenu Parent Directory');
      final menu = FilePickerMenu(game, print);
      game.pushLevel(menu);
      menu.down();
      expect(menu.currentMenuItem?.label.text, equals('..'));
      menu.activate();
      expect(game.currentLevel, isA<FilePickerMenu>());
      expect(game.currentLevel, isNot(menu));
      final newMenu = game.currentLevel! as FilePickerMenu;
      expect(
          newMenu.currentDirectory.path, equals(Directory.current.parent.path));
      expect(newMenu.onDone, equals(menu.onDone));
    });
  });
}
