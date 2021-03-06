/// Provides the [AssetReferenceMenu] class.
import '../../menus.dart';
import '../json/asset_reference.dart';
import '../json/message.dart';

/// A menu for showing [AssetReference] instances.
class AssetReferenceMenu extends Menu {
  /// Create an instance.
  ///
  /// The [assetReferences] map should look like:
  ///
  /// `{'Asset 1 title': asset1, 'Asset 2 Title': asset2}`
  ///
  /// The title will most likely be gleaned from a [AssetReferenceReference](https://pub.dev/documentation/ziggurat_sounds/latest/ziggurat_sounds/AssetReferenceReference-class.html)
  /// instance.
  AssetReferenceMenu({
    required super.game,
    required super.title,
    required final Map<String, AssetReference> assetReferences,
    super.music,
    super.ambiances,
    super.randomSounds,
    super.onCancel,
    super.activateAxis,
    super.activateButton,
    super.activateScanCode,
    super.cancelAxis,
    super.cancelButton,
    super.cancelScanCode,
    super.commands,
    super.controllerAxisSensitivity,
    super.controllerMovementSpeed,
    super.downButton,
    super.downScanCode,
    super.movementAxis,
    super.position,
    super.searchEnabled,
    super.searchInterval,
    super.soundChannel,
    super.upButton,
    super.upScanCode,
  }) : super(
          items: [
            for (final entry in assetReferences.entries)
              MenuItem(
                Message(
                  text: entry.key,
                  sound: entry.value,
                  keepAlive: true,
                ),
                menuItemLabel,
              )
          ],
        );
}
