/// Provides the [Menu] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';

import '../json/message.dart';
import '../sound/buffer_store.dart';
import 'menu_item.dart';
import 'widgets/button.dart';

/// A menu.
///
/// Menus hold lists of [MenuItem] instances, and can be moved through with the
/// [up] and [down] methods.
///
/// The currently focussed menu item can be accessed with the [currentMenuItem]
/// member, and activated with the [activate] method.
///
/// If it is possible to cancel from this menu, you can do so with the [cancel]
/// method.
class Menu {
  /// Create a menu.
  Menu(this.title, this.menuItems, this.outputText, Context context,
      this.bufferStore,
      {this.onCancel}) {
    source = DirectSource(context);
    generator = BufferGenerator(context);
    source.addGenerator(generator);
  }

  /// The title of this menu.
  final Message title;

  /// The menu items contained by this menu.
  final List<MenuItem> menuItems;

  /// The function to use to output text.
  final void Function(String) outputText;

  /// The buffer store to use.
  final BufferStore bufferStore;

  /// If this value is not `null`, then the [cancel] method will call it.
  final void Function()? onCancel;

  //// The current position in this menu.
  int? _position;

  /// The source to use to play sounds.
  late final DirectSource source;

  /// The generator to use for playing sounds.
  late final BufferGenerator generator;

  /// Activate the currently-focused menu item.
  void activate() {
    final item = currentMenuItem;
    if (item is MenuItem<Button>) {
      item.widget.onActivate();
    }
  }

  /// Cancel this menu.
  ///
  /// If [onCancel] is `null`, nothing will happen.
  void cancel() {
    final cancelFunc = onCancel;
    if (cancelFunc != null) {
      cancelFunc();
    }
  }

  /// Output a message.
  void outputMessage(Message message) {
    final text = message.text;
    if (text != null) {
      outputText(text);
    }
    final sound = message.sound;
    if (sound != null) {
      generator.setBuffer(bufferStore.getBuffer(sound.name, sound.type));
      source.gain = message.gain;
    }
  }

  /// Get the currently focussed menu item.
  MenuItem? get currentMenuItem {
    final position = _position;
    if (position != null) {
      return menuItems.elementAt(position);
    }
  }

  /// Move up in this menu.
  void up() {
    var position = _position;
    final Message message;
    if (position == null || position == 0) {
      message = title;
      _position = null;
    } else {
      position--;
      _position = position;
      message = menuItems.elementAt(position).message;
    }
    outputMessage(message);
  }

  /// Move down in this menu.
  void down() {
    var position = _position;
    if (position == null) {
      position = 0;
    } else {
      position = min(position + 1, menuItems.length - 1);
    }
    final item = menuItems.elementAt(position);
    outputMessage(item.message);
  }
}
