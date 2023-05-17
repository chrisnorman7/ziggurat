import '../../constants.dart';
import '../../menus.dart';
import '../../ziggurat.dart';

/// A class to describe what happens when a [MenuItem] is activated.
class MenuItemActivator {
  /// Create an instance.
  const MenuItemActivator({
    required this.onActivate,
    this.sound,
  });

  /// The function to call.
  final TaskFunction onActivate;

  /// The sound to play when [onActivate] is called.
  final AssetReference? sound;
}
