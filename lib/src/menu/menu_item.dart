/// Provides the [MenuItem] class.
import '../json/message.dart';
import 'menu.dart';
import 'widgets/widgets_base.dart';

/// An item in a [Menu].
class MenuItem {
  /// Create a menu item.
  const MenuItem(this.label, this.widget);

  /// The message that will be used when focusing this menu item.
  final Message label;

  /// The widget associated with this item.
  final Widget widget;

  /// What happens when this item is focused.
  void onFocus(final Menu menu) {
    final message = widget.getLabel(this) ?? label;
    menu.oldSound = menu.game.outputMessage(
      message,
      oldSound: menu.oldSound,
      soundChannel: menu.soundChannel,
    );
  }
}
