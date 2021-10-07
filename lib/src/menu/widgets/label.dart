/// Provides the [menuItemLabel] constant.
import '../menu_item.dart';
import 'widgets_base.dart';

/// A label in a menu.
///
/// This widget does nothing, but makes a [MenuItem] non-clickable.
class _Label extends Widget {
  /// Enable instances to be constant.
  const _Label();
}

/// A label for a menu item.
const menuItemLabel = _Label();
