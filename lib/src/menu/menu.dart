/// Provides the [Menu] class.
import 'package:dart_sdl/dart_sdl.dart';

import '../game.dart';
import '../json/asset_reference.dart';
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

      /// The position within the menu.
      ///
      /// If this value is `null`, then the title will be focused.
      int? position,
      this.onCancel,
      List<Ambiance>? ambiances,
      this.upScanCode = ScanCode.SCANCODE_UP,
      this.upButton = GameControllerButton.dpadUp,
      this.downScanCode = ScanCode.SCANCODE_DOWN,
      this.downButton = GameControllerButton.dpadDown,
      this.activateScanCode = ScanCode.SCANCODE_RIGHT,
      this.activateButton = GameControllerButton.dpadRight,
      this.cancelScanCode = ScanCode.SCANCODE_LEFT,
      this.cancelButton = GameControllerButton.dpadLeft})
      : menuItems = items ?? [],
        _position = position,
        super(game, ambiances: ambiances ?? []);

  /// The title of this menu.
  final Message title;

  /// The menu items contained by this menu.
  final List<MenuItem> menuItems;

  /// The function that will be called by [cancel].
  ///
  /// If this value is `null`, nothing will happen when the [cancel] method is
  /// called.
  final void Function()? onCancel;

  /// The scancode that will call the [up] method.
  final ScanCode upScanCode;

  /// The scancode that will call the [down] method.
  final ScanCode downScanCode;

  /// The scancode that will call the [activate] method.
  final ScanCode activateScanCode;

  /// The scancode that will call the [cancel] method.
  final ScanCode cancelScanCode;

  /// The button that will call the [up] method.
  final GameControllerButton upButton;

  /// The button that will call the [down] method.
  final GameControllerButton downButton;

  /// The button that will call the [activate] method.
  final GameControllerButton activateButton;

  /// The button that will call the [cancel] method.
  final GameControllerButton cancelButton;

  //// The current position in this menu.
  int? _position;

  /// The last sound played by this menu.
  PlaySound? oldSound;

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
    } else if (widget == menuItemLabel) {
      return;
    } else if (widget is Button) {
      widget.onActivate();
      final sound = widget.sound;
      if (sound != null) {
        oldSound =
            game.outputMessage(Message(sound: sound), oldSound: oldSound);
      }
    } else if (widget is ListButton) {
      widget.changeValue();
    } else {
      throw Exception('Need to handle $widget widgets.');
    }
  }

  /// What happens when this menu is cancelled.
  void cancel() {
    final f = onCancel;
    if (f != null) {
      f();
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
  MenuItem addLabel({String? text, AssetReference? selectSound}) {
    final item =
        MenuItem(Message(sound: selectSound, text: text), menuItemLabel);
    menuItems.add(item);
    return item;
  }

  /// Handle SDL events.
  @override
  void handleSdlEvent(Event event) {
    if (event is KeyboardEvent &&
        event.repeat == false &&
        event.state == PressedState.pressed &&
        event.key.modifiers.isEmpty) {
      final scanCode = event.key.scancode;
      if (scanCode == upScanCode) {
        up();
      } else if (scanCode == downScanCode) {
        down();
      } else if (scanCode == activateScanCode) {
        activate();
      } else if (scanCode == cancelScanCode) {
        cancel();
      }
    } else if (event is ControllerButtonEvent &&
        event.state == PressedState.pressed) {
      final button = event.button;
      if (button == upButton) {
        up();
      } else if (button == downButton) {
        down();
      } else if (button == activateButton) {
        activate();
      } else if (button == cancelButton) {
        cancel();
      }
    }
  }
}
