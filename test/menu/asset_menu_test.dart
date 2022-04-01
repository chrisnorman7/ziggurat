import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final game = Game('Asset Menu');
  const asset1 = AssetReference.file('sound.wav');
  const asset2 = AssetReference.collection('footsteps');
  group(
    'AssetMenu',
    () {
      final menu = AssetReferenceMenu(
        game: game,
        title: const Message(text: 'Assets'),
        assetReferences: {'Sound': asset1, 'Footsteps': asset2},
      );
      test(
        'Initialise',
        () {
          expect(menu.menuItems.length, 2);
        },
      );
      test(
        'Menu Items',
        () {
          var item = menu.menuItems.first;
          expect(item.widget, menuItemLabel);
          var message = item.label;
          expect(message.text, 'Sound');
          expect(message.keepAlive, isTrue);
          expect(message.sound, asset1);
          item = menu.menuItems.last;
          expect(item.widget, menuItemLabel);
          message = item.label;
          expect(message.keepAlive, isTrue);
          expect(message.sound, asset2);
        },
      );
    },
  );
}
