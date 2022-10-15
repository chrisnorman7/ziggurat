/// Provides the [UniformMenu] class.
import '../../json/asset_reference.dart';
import '../../json/message.dart';
import '../menu.dart';
import '../menu_item.dart';
import '../simple_menu_item.dart';
import '../widgets/label.dart';
import 'uniform_menu_item.dart';

/// A menu which uses the same [selectSound] and [activateSound] for all its
/// [menuItems].
class UniformMenu extends Menu {
  /// Create an instance.
  UniformMenu({
    required super.game,
    required super.title,
    required final List<UniformMenuItem> items,
    super.position,
    super.onCancel,
    super.music,
    this.selectSound,
    this.activateSound,
  }) : super(
          items: items.map<MenuItem>(
            (final e) {
              final onActivate = e.onActivate;
              if (onActivate == null) {
                return MenuItem(
                  Message(
                    keepAlive: true,
                    sound: selectSound,
                    text: e.label,
                  ),
                  menuItemLabel,
                );
              }
              return SimpleMenuItem(
                e.label,
                onActivate,
                activateSound: activateSound,
                selectSound: selectSound,
              );
            },
          ).toList(),
        );

  /// The sound used when a menu item is selected.
  final AssetReference? selectSound;

  /// The sound which is heard when activating a menu item.
  final AssetReference? activateSound;
}
