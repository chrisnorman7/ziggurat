/// Provides the [Menu] class.
import 'dart:math';

import '../command.dart';
import '../game.dart';
import '../json/message.dart';
import '../levels/level.dart';
import 'menu_item.dart';
import 'widgets/button.dart';
import 'widgets/label.dart';

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
class Menu extends Level {
  /// Create a menu.
  Menu({required Game game, required this.title, List<MenuItem>? items})
      : menuItems = items ?? [],
        super(game);

  /// The title of this menu.
  final Message title;

  /// The menu items contained by this menu.
  final List<MenuItem> menuItems;

  //// The current position in this menu.
  int? _position;

  /// Register default commands.
  ///
  /// If any of the arguments are `null`, then that command will not be
  /// registered.
  void registerCommands(
      {String? upCommandName,
      String? downCommandName,
      String? activateCommandName,
      String? cancelCommandName}) {
    if (upCommandName != null) {
      registerCommand(upCommandName, Command(onStart: up));
    }
    if (downCommandName != null) {
      registerCommand(downCommandName, Command(onStart: down));
    }
    if (activateCommandName != null) {
      registerCommand(activateCommandName, Command(onStart: activate));
    }
    if (cancelCommandName != null) {
      registerCommand(cancelCommandName, Command(onStart: cancel));
    }
  }

  /// Activate the currently-focused menu item.
  void activate() {
    final item = currentMenuItem;
    final widget = item?.widget;
    if (widget is Label) {
      return;
    } else if (widget is Button) {
      widget.onActivate();
    } else {
      throw Exception('Need to handle $widget widgets.');
    }
  }

  /// What happens when this menu is cancelled.
  void cancel() {}

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
    if (position == null || position == 0) {
      game.outputMessage(title);
      _position = null;
    } else {
      position--;
      _position = position;
      menuItems.elementAt(position).onFocus(this);
    }
  }

  /// Move down in this menu.
  void down() {
    var position = _position;
    if (position == null) {
      position = 0;
    } else {
      position = min(position + 1, menuItems.length - 1);
    }
    _position = position;
    menuItems.elementAt(position).onFocus(this);
  }
}
