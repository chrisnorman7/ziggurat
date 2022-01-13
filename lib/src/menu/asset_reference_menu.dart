/// Provides the [AssetReferenceMenu] class.
import '../../menus.dart';
import '../game.dart';
import '../json/ambiance.dart';
import '../json/asset_reference.dart';
import '../json/message.dart';
import '../json/random_sound.dart';

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
    required Game game,
    required Message title,
    required Map<String, AssetReference> assetReferences,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  }) : super(
          game: game,
          title: title,
          items: [
            for (final entry in assetReferences.entries)
              MenuItem(
                  Message(
                    text: entry.key,
                    sound: entry.value,
                    keepAlive: true,
                  ),
                  menuItemLabel)
          ],
          ambiances: ambiances,
          randomSounds: randomSounds,
        );
}
