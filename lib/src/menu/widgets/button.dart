/// Provides the [Button] class.
import '../../json/asset_reference.dart';
import 'widgets_base.dart';

/// A button that can be activated.
class Button extends Widget {
  /// Create a button.
  Button(this.onActivate, {this.sound});

  /// The function which will be called when this button is activated.
  final void Function() onActivate;

  /// The sound that should play when this widget is activated.
  final AssetReference? sound;
}
