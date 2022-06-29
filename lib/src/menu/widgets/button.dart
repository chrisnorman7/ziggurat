/// Provides the [Button] class.
import '../../json/asset_reference.dart';
import '../../json/message.dart';
import '../menu.dart';
import '../menu_item.dart';
import 'widgets_base.dart';

/// A button that can be activated.
class Button extends Widget {
  /// Create a button.
  const Button(
    final void Function() onActivate, {
    super.activateSound,
  }) : super(onActivate: onActivate);
}

/// A button which can toggle through a list of items.
class ListButton<T> extends Widget {
  /// Create an instance.
  ListButton(this.items, this.onChange, {this.index = 0});

  /// The items that [activate] will cycle through.
  final List<T> items;

  /// The current position in [items].
  int index;

  /// The function which will be called when [activate] changes value.
  final void Function(T value)? onChange;

  @override
  void activate(final Menu menu) {
    index++;
    if (index >= items.length) {
      index = 0;
    }
    final onChangeFunction = onChange;
    if (onChangeFunction != null) {
      onChangeFunction(value);
    }
    super.activate(menu);
  }

  /// Get the currently-focused item.
  T get value => items[index];

  /// Get a label that shows the current state of this button.
  @override
  Message getLabel(final MenuItem menuItem) {
    final label = menuItem.label;
    return Message(
      text: '${label.text} ($value)',
      gain: label.gain,
      keepAlive: label.keepAlive,
      sound: label.sound,
    );
  }
}

/// A checkbox.
///
/// This control can toggle between `true` and `false`.
class Checkbox extends ListButton<bool> {
  /// Create an instance.
  Checkbox(
    final void Function(bool) onChange, {
    final bool initialValue = true,
    this.checkedSound,
    this.uncheckedSound,
  }) : super([initialValue, !initialValue], onChange);

  /// The sound that will be played when this checkbox is selected if [value] is
  /// `true`.
  ///
  /// If this value is `null`, the sound will default to the sound of the
  /// [MenuItem] label for this checkbox. If no sound is desired, ensure the
  /// menu item sound is also `null`.
  final AssetReference? checkedSound;

  /// The sound that will be played when this checkbox is selected if [value] is
  /// `false`.
  ///
  /// If this value is `null`, the sound will default to the sound of the
  /// [MenuItem] label for this checkbox. If no sound is desired, ensure the
  /// menu item sound is also `null`.
  final AssetReference? uncheckedSound;

  @override
  Message getLabel(final MenuItem menuItem) {
    final label = menuItem.label;
    AssetReference? sound;
    if (value) {
      sound = checkedSound;
    } else {
      sound = uncheckedSound;
    }
    sound ??= label.sound;
    return Message(
      text: '${label.text} (${value == true ? "checked" : "unchecked"})',
      gain: label.gain,
      keepAlive: label.keepAlive,
      sound: sound,
    );
  }
}
