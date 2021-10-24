/// Provides the [Button] class.
import '../../json/asset_reference.dart';
import '../../json/message.dart';
import '../menu_item.dart';
import 'widgets_base.dart';

/// A button that can be activated.
class Button extends Widget {
  /// Create a button.
  const Button(void Function() onActivate, {AssetReference? activateSound})
      : super(onActivate: onActivate, activateSound: activateSound);
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

  /// Get a label that shows the current state of this button.
  @override
  Message getLabel(MenuItem menuItem) {
    final label = menuItem.label;
    return Message(
        text: '${label.text} ($value)',
        gain: label.gain,
        keepAlive: label.keepAlive,
        sound: label.sound);
  }
}

/// A checkbox.
///
/// This control can toggle between `true` and `false`.
class Checkbox extends ListButton<bool> {
  /// Create an instance.
  Checkbox(void Function(bool) onChange,
      {bool initialValue = true, this.checkedSound, this.uncheckedSound})
      : super([initialValue, !initialValue], onChange);

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
  Message getLabel(MenuItem menuItem) {
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
        sound: sound);
  }
}
