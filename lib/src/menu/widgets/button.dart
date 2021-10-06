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

/// A button which can toggle through a list of items.
class ListButton<T> extends Widget {
  /// Create an instance.
  ListButton(this.items, this.onChange, {this.index = 0});

  /// The items that [changeValue] will cycle through.
  final List<T> items;

  /// The current position in [items].
  int index;

  /// The function which will be called when [changeValue] changes value.
  final void Function(T)? onChange;

  /// The function that will be called to select a new value from [items].
  void changeValue() {
    index++;
    if (index >= items.length) {
      index = 0;
    }
    final onChangeFunction = onChange;

    if (onChangeFunction != null) {
      onChangeFunction(value);
    }
  }

  /// Get the currently-focused item.
  T get value => items[index];
}

/// A checkbox.
///
/// This control can toggle between `true` and `false`.
class Checkbox extends ListButton<bool> {
  /// Create an instance.
  Checkbox(void Function(bool) onChange, {bool initialValue = true})
      : super([initialValue, !initialValue], onChange);
}
