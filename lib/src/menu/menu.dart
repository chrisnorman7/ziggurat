/// Provides the [Menu] class.
import '../command.dart';
import '../game.dart';
import '../json/assets.dart';
import '../json/message.dart';
import '../levels/level.dart';
import '../sound/ambiance.dart';
import '../sound/events/events_base.dart';
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
  Menu(
      {required Game game,
      required this.title,
      List<MenuItem>? items,
      List<Ambiance>? ambiances})
      : menuItems = items ?? [],
        super(game, ambiances: ambiances ?? []);

  /// The title of this menu.
  final Message title;

  /// The menu items contained by this menu.
  final List<MenuItem> menuItems;

  //// The current position in this menu.
  int? _position;

  /// The last sound played by this menu.
  PlaySound? oldSound;

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

  /// Show the current item.
  void showCurrentItem() {
    final position = _position;
    if (position == null) {
      oldSound = game.outputMessage(title, oldSound: oldSound);
    } else {
      menuItems.elementAt(position).onFocus(this);
    }
  }

  /// Show the current item in this menu when it is pushed.
  @override
  void onPush() {
    super.onPush();
    showCurrentItem();
  }

  @override
  void onReveal(Level old) => showCurrentItem();

  /// Activate the currently-focused menu item.
  void activate() {
    final item = currentMenuItem;
    final widget = item?.widget;
    if (widget == null) {
      return;
    } else if (widget is Label) {
      return;
    } else if (widget is Button) {
      widget.onActivate();
      final sound = widget.sound;
      if (sound != null) {
        oldSound =
            game.outputMessage(Message(sound: sound), oldSound: oldSound);
      }
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
    final position = _position;
    if (position == null) {
      return;
    } else if (position == 0) {
      _position = null;
    } else {
      _position = position - 1;
    }
    showCurrentItem();
  }

  /// Move down in this menu.
  void down() {
    final position = _position;
    if (position == null) {
      _position = 0;
    } else {
      if (position == (menuItems.length - 1)) {
        return;
      }
      _position = position + 1;
    }
    showCurrentItem();
  }

  /// Add a button to this menu.
  MenuItem<Button> addButton(void Function() onActivate,
      {String? label,
      AssetReference? selectSound,
      AssetReference? activateSound}) {
    final item = MenuItem(Message(sound: selectSound, text: label),
        Button(onActivate, sound: activateSound));
    menuItems.add(item);
    return item;
  }

  /// Add a label.
  MenuItem<Label> addLabel({String? label, AssetReference? selectSound}) {
    final item = MenuItem(Message(sound: selectSound, text: label), Label());
    menuItems.add(item);
    return item;
  }
}
