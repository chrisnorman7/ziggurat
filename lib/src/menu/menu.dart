/// Provides the [Menu] class.
import 'package:dart_sdl/dart_sdl.dart';

import '../../sound.dart';
import '../controller_axis_dispatcher.dart';
import '../game.dart';
import '../json/asset_reference.dart';
import '../json/message.dart';
import '../levels/level.dart';
import '../tasks/task.dart';
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
  ///
  /// If [position] is `null`, then the menu title will be selected. Otherwise,
  /// the menu item at the given position (starting at 0) in the [menuItems]
  /// list will be selected.
  ///
  /// You can either specify a list of menu items as the [items] argument, or
  /// use the provided [addButton], and [addLabel] methods afterwards.
  ///
  /// Please note: Whether or not you provide an [items] list, you can still
  /// pass a [position] value, as this only affects the [currentMenuItem]
  /// getter.
  ///
  /// The list of [ambiances] and [randomSounds] are passed to the [Level]
  /// constructor.
  ///
  /// The [controllerAxisSensitivity] value defines how sensitive an axis is to
  /// controlling this instance. The higher this value, the further the
  /// controller axis has to be pushed before anything happens. The lower the
  /// value, the easier it is to accidentally do things in the menu.
  ///
  /// The [controllerMovementSpeed] value controls how often the player can use
  /// a controller in this menu.
  ///
  /// The [activateAxis] value is the axis which can be used to call the
  /// [activate] method.
  ///
  /// The [cancelAxis] value is the axis which can be used to call the [cancel]
  /// method.
  ///
  /// The [movementAxis] value is the axis which can be used to move within this
  /// menu.
  Menu({
    required Game game,
    required this.title,
    List<MenuItem>? items,
    this.position,
    this.onCancel,
    this.upScanCode = ScanCode.SCANCODE_UP,
    this.upButton = GameControllerButton.dpadUp,
    this.downScanCode = ScanCode.SCANCODE_DOWN,
    this.downButton = GameControllerButton.dpadDown,
    this.activateScanCode = ScanCode.SCANCODE_SPACE,
    this.activateButton = GameControllerButton.dpadRight,
    this.cancelScanCode = ScanCode.SCANCODE_ESCAPE,
    this.cancelButton = GameControllerButton.dpadLeft,
    GameControllerAxis movementAxis = GameControllerAxis.lefty,
    GameControllerAxis activateAxis = GameControllerAxis.triggerright,
    GameControllerAxis cancelAxis = GameControllerAxis.triggerleft,
    int controllerMovementSpeed = 500,
    double controllerAxisSensitivity = 0.5,
    this.searchEnabled = true,
    this.searchInterval = 500,
    this.soundChannel,
    Music? music,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  })  : menuItems = items ?? [],
        searchString = '',
        searchTime = 0,
        super(
          game: game,
          music: music,
          ambiances: ambiances,
          randomSounds: randomSounds,
        ) {
    controllerAxisDispatcher = ControllerAxisDispatcher({
      movementAxis: (double value) {
        if (value < 0) {
          up();
        } else {
          down();
        }
      },
      activateAxis: (double value) => activate(),
      cancelAxis: (double value) => cancel()
    },
        axisSensitivity: controllerAxisSensitivity,
        functionInterval: controllerMovementSpeed);
  }

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
  int? position;

  /// The axis dispatcher used for controller movements.
  late final ControllerAxisDispatcher controllerAxisDispatcher;

  /// Whether or not it will be possible to search this menu.
  final bool searchEnabled;

  /// How many milliseconds must elapse before searches clear [searchString].
  final int searchInterval;

  /// The sound channel to play sounds through.
  ///
  /// This value is used by the [showCurrentItem] method.
  final SoundChannel? soundChannel;

  /// The last sound played by this menu.
  PlaySound? oldSound;

  /// The most recent search string.
  String searchString;

  /// The last time a search was performed.
  int searchTime;

  /// Show the current item.
  void showCurrentItem() {
    final pos = position;
    if (pos == null) {
      oldSound = game.outputMessage(
        title,
        oldSound: oldSound,
        soundChannel: soundChannel,
      );
    } else {
      menuItems.elementAt(pos).onFocus(this);
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

  @override
  void onPop(double? fadeLength) {
    super.onPop(fadeLength);
    final sound = oldSound;
    if (sound != null && sound.keepAlive == true) {
      sound.destroy();
    }
    oldSound = null;
  }

  /// Activate the currently-focused menu item.
  void activate() {
    final item = currentMenuItem;
    final widget = item?.widget;
    if (item == null || widget == null) {
      return;
    } else {
      widget.activate(this);
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
    final pos = position;
    if (pos != null) {
      return menuItems.elementAt(pos);
    }
    return null;
  }

  /// Move up in this menu.
  void up() {
    final pos = position;
    if (pos == null) {
      return;
    } else if (pos == 0) {
      position = null;
    } else {
      position = pos - 1;
    }
    showCurrentItem();
  }

  /// Move down in this menu.
  void down() {
    final pos = position;
    if (pos == null) {
      if (menuItems.isNotEmpty) {
        position = 0;
      }
    } else {
      if (pos == (menuItems.length - 1)) {
        return;
      }
      position = pos + 1;
    }
    showCurrentItem();
  }

  /// Add a button to this menu.
  MenuItem addButton(TaskFunction onActivate,
      {String? label,
      AssetReference? selectSound,
      AssetReference? activateSound}) {
    final item = MenuItem(Message(sound: selectSound, text: label),
        Button(onActivate, activateSound: activateSound));
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
        (event.key.modifiers.isEmpty ||
            (event.key.modifiers.length == 1 &&
                event.key.modifiers.contains(KeyMod.num)))) {
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
    } else if (event is ControllerAxisEvent) {
      controllerAxisDispatcher.handleAxisValue(event.axis, event.smallValue);
    } else if (event is TextInputEvent &&
        searchEnabled == true &&
        event.text.isNotEmpty) {
      if ((event.timestamp - searchTime) >= searchInterval) {
        searchString = '';
      }
      searchString += event.text.toLowerCase();
      searchTime = event.timestamp;
      for (var i = 0; i < menuItems.length; i++) {
        final item = menuItems.elementAt(i);
        final text = item.label.text;
        if (text != null && text.toLowerCase().startsWith(searchString)) {
          position = i;
          showCurrentItem();
          break;
        }
      }
    }
  }
}
