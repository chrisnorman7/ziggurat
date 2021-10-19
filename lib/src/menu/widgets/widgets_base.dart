/// Widgets for use with [Menu] instances.
library widgets;

import '../../json/message.dart';
import '../menu.dart';
import '../menu_item.dart';

/// The base class for all widgets.
class Widget {
  /// Allow subclasses to be constant.
  const Widget();

  /// Override this method to change the label that is shown when this widget's
  /// parent [MenuItem] is selected.
  Message? getLabel(MenuItem menuItem) {}
}
