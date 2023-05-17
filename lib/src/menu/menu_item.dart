import '../json/message.dart';
import 'menu.dart';
import 'menu_item_activator.dart';

/// An item in a [Menu].
class MenuItem {
  /// Create a menu item.
  const MenuItem(
    this.label, {
    this.activator,
  });

  /// The message that will be used when focusing this menu item.
  final Message label;

  /// When to do when this [MenuItem] is activated.
  final MenuItemActivator? activator;

  /// What happens when this item is focused.
  void onFocus(final Menu menu) => menu.oldSound = menu.game.outputMessage(
        label,
        oldSound: menu.oldSound,
        soundChannel: menu.soundChannel,
      );
}
