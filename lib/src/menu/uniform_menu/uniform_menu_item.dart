/// Provides the [UniformMenuItem] class.
import '../../tasks/task.dart';
import '../widgets/label.dart';
import 'uniform_menu.dart';

/// An item in a [UniformMenu] instance.
class UniformMenuItem {
  /// Create an instance.
  const UniformMenuItem({
    this.label,
    this.onActivate,
  });

  /// The label for this menu item.
  final String? label;

  /// The function to call when this menu item is activated.
  ///
  /// If this value is `null`, then this menu item will be a [menuItemLabel].
  final TaskFunction? onActivate;
}
