import 'dart:io';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:path/path.dart' as path;

import '../game.dart';
import '../json/ambiance.dart';
import '../json/message.dart';
import '../json/music.dart';
import '../json/random_sound.dart';
import 'menu.dart';
import 'menu_item.dart';
import 'widgets/button.dart';

/// A level for picking a file.
class FilePickerMenu extends Menu {
  /// Create an instance.
  FilePickerMenu({
    required Game game,
    required this.onDone,
    Directory? start,
    this.caption = 'Open',
    this.getEntityMessage,
    this.allowDirectories = false,
    this.showFiles = true,
    void Function()? onCancel,
    Music? music,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  })  : currentDirectory = start ?? _lastUsed,
        super(
          game: game,
          title: Message(text: '$caption (${(start ?? _lastUsed).path})'),
          onCancel: onCancel,
          music: music,
          ambiances: ambiances,
          randomSounds: randomSounds,
        ) {
    _lastUsed = currentDirectory;
    addButton(
      () => game.replaceLevel(
        FilePickerMenu(
            game: game,
            onDone: onDone,
            allowDirectories: allowDirectories,
            getEntityMessage: getEntityMessage,
            onCancel: onCancel,
            showFiles: showFiles,
            start: currentDirectory.parent,
            caption: caption),
      ),
      label: '..',
    );
    if (allowDirectories) {
      addButton(
        () => onDone(currentDirectory),
        label: 'Select This Directory',
      );
    }
    final directories = <Directory>[];
    final files = <File>[];
    for (final entity in currentDirectory.listSync()) {
      if (entity is Directory) {
        directories.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }
    for (final directory in directories) {
      menuItems.add(
        MenuItem(
          getLabel(directory),
          Button(
            () => game.replaceLevel(
              FilePickerMenu(
                game: game,
                onDone: onDone,
                allowDirectories: allowDirectories,
                caption: caption,
                getEntityMessage: getEntityMessage,
                onCancel: onCancel,
                showFiles: showFiles,
                start: directory,
              ),
            ),
          ),
        ),
      );
    }
    if (showFiles == true) {
      for (final file in files) {
        menuItems.add(
          MenuItem(
            getLabel(file),
            Button(
              () => onDone(file),
            ),
          ),
        );
      }
    }
  }

  /// The most recent directory used.
  static Directory _lastUsed = Directory.current;

  /// What to do when an entity is selected.
  final void Function(FileSystemEntity entity) onDone;

  /// The starting directory.
  final Directory currentDirectory;

  /// The title of this menu.
  final String caption;

  /// A function for getting entry labels.
  final Message Function(FileSystemEntity entity)? getEntityMessage;

  /// Whether or not directories can be selected.
  final bool allowDirectories;

  /// Whether or not to show files.
  final bool showFiles;

  /// Get the label for [entity].
  Message getLabel(FileSystemEntity entity) {
    if (getEntityMessage == null) {
      final shortName = path.relative(entity.path, from: currentDirectory.path);
      return Message(
          text: '$shortName${entity is Directory ? " directory" : ""}');
    } else {
      return getEntityMessage!(entity);
    }
  }

  @override
  void handleSdlEvent(Event event) {
    if (event is KeyboardEvent &&
        event.key.scancode == ScanCode.backspace &&
        event.key.modifiers.isEmpty &&
        event.repeat == false &&
        event.state == PressedState.pressed) {
      game.replaceLevel(FilePickerMenu(
          game: game,
          onDone: onDone,
          allowDirectories: allowDirectories,
          caption: caption,
          getEntityMessage: getEntityMessage,
          onCancel: onCancel,
          showFiles: showFiles,
          start: currentDirectory.parent));
    } else {
      super.handleSdlEvent(event);
    }
  }
}
