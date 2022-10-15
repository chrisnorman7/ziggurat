import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group(
    'UniformMenu class',
    () {
      final menuItem1 = UniformMenuItem(
        label: 'Play',
        onActivate: () {},
      );
      const menuItem2 = UniformMenuItem(
        label: 'Exit Label',
      );
      final game = Game(
        title: 'Uniform Menu',
        sdl: Sdl(),
        soundBackend: SilentSoundBackend(),
      );
      const activateSound = AssetReference.file('activate.wav');
      const selectSound = AssetReference.file('select.wav');
      test(
        'Initialise',
        () {
          final menu = UniformMenu(
            game: game,
            title: const Message(text: 'Test Uniform Menu'),
            items: [menuItem1, menuItem2],
            activateSound: activateSound,
            selectSound: selectSound,
          );
          expect(menu.activateSound, activateSound);
          expect(menu.selectSound, selectSound);
          final menuItems = menu.menuItems;
          expect(menuItems.length, 2);
          final mi1 = menuItems.first;
          expect(mi1.label.sound, selectSound);
          expect(mi1.label.text, menuItem1.label);
          expect(
            mi1.widget,
            predicate(
              (final value) =>
                  value is Button &&
                  value.activateSound == activateSound &&
                  value.onActivate == menuItem1.onActivate,
            ),
          );
          final mi2 = menuItems.last;
          expect(mi2.label.sound, selectSound);
          expect(mi2.widget, menuItemLabel);
        },
      );
    },
  );
}
