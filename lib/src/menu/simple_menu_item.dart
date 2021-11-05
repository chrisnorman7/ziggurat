/// Provides the [SimpleMenuItem] class.
import '../json/asset_reference.dart';
import '../json/message.dart';
import 'menu_item.dart';
import 'widgets/button.dart';

/// A simple menu item.
///
/// In many cases, all that is needed for a menu item is a label and a button.
///
/// This class combines syntactic sugar for creating such a menu item with
/// minimal code.
class SimpleMenuItem extends MenuItem {
  /// Create an instance.
  SimpleMenuItem(String label, void Function() onActivate,
      {AssetReference? selectSound, AssetReference? activateSound})
      : super(Message(text: label, sound: selectSound, keepAlive: true),
            Button(onActivate, activateSound: activateSound));
}
