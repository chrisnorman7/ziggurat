/// Provides the [Button] class.
import 'widgets_base.dart';

/// A button that can be activated.
class Button extends Widget {
  /// Create a button.
  Button(this.onActivate);

  /// The function which will be called when this button is activated.
  final void Function() onActivate;
}
