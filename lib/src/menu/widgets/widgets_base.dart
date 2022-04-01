/// Widgets for use with [Menu] instances.
library widgets;

import '../../json/asset_reference.dart';
import '../../json/message.dart';
import '../menu.dart';
import '../menu_item.dart';

/// The base class for all widgets.
class Widget {
  /// Allow subclasses to be constant.
  const Widget({this.onActivate, this.activateSound});

  /// The function which will be called when this button is activated.
  final void Function()? onActivate;

  /// The sound that should play when this widget is activated.
  final AssetReference? activateSound;

  /// Override this method to change the label that is shown when this widget's
  /// parent [MenuItem] is selected.
  Message? getLabel(final MenuItem menuItem) => null;

  /// Override this function to change what happens when this widget is
  /// activated.
  void activate(final Menu menu) {
    final f = onActivate;
    if (f != null) {
      f();
    }
    final sound = activateSound;
    if (sound != null) {
      menu.oldSound = menu.game
          .outputSound(sound: sound, keepAlive: true, oldSound: menu.oldSound);
    }
  }
}
