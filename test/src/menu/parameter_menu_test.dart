import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../helpers.dart';

void main() {
  final sdl = Sdl();
  group(
    'ParameterMenu class',
    () {
      var b = true;
      var i = 10;
      final game = Game(
        title: 'ParameterMenu Tests',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final bParameter = ParameterMenuParameter(
        getLabel: () => Message(text: 'Boolean: $b'),
        increaseValue: () => b = true,
        decreaseValue: () => b = false,
      );
      final iParameter = ParameterMenuParameter(
        getLabel: () => Message(text: 'I: $i'),
        increaseValue: () => i++,
        decreaseValue: () => i--,
      );
      final menu = ParameterMenu(
        game: game,
        title: const Message(text: 'Parameters'),
        parameters: [
          bParameter,
          iParameter,
        ],
      );
      test(
        'Initialisation',
        () {
          expect(menu.menuItems.length, 2);
          expect(menu.menuItems, [bParameter, iParameter]);
          expect(menu.currentMenuItem, isNull);
          expect(menu.decreaseValueButton, GameControllerButton.dpadLeft);
          expect(menu.decreaseValueScanCode, ScanCode.left);
          expect(menu.increaseValueButton, GameControllerButton.dpadRight);
          expect(menu.increaseValueScanCode, ScanCode.right);
        },
      );
      test(
        'Move Down (Keyboard)',
        () {
          expect(menu.currentMenuItem, isNull);
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.downScanCode,
              KeyCode.down,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, bParameter);
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.downScanCode,
              KeyCode.down,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, iParameter);
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.downScanCode,
              KeyCode.down,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, iParameter);
        },
      );
      test(
        'Move Up (Keyboard)',
        () {
          while (menu.currentMenuItem != iParameter) {
            menu.down();
          }
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.upScanCode,
              KeyCode.up,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, bParameter);
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.upScanCode,
              KeyCode.up,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, isNull);
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.upScanCode,
              KeyCode.up,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, isNull);
        },
      );
      test(
        'Move Down (Controller)',
        () {
          expect(menu.currentMenuItem, isNull);
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.downButton,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, bParameter);
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.downButton,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, iParameter);
          menu.handleSdlEvent(
            makeControllerButtonEvent(sdl, menu.downButton),
          );
          expect(menu.currentMenuItem, iParameter);
        },
      );
      test(
        'Move Up (Controller)',
        () {
          while (menu.currentMenuItem != iParameter) {
            menu.down();
          }
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.upButton,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, bParameter);
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.upButton,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, isNull);
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.upButton,
              state: PressedState.pressed,
            ),
          );
          expect(menu.currentMenuItem, isNull);
        },
      );
      test(
        'Decrease Item',
        () {
          menu
            ..down()
            ..down();
          expect(menu.currentMenuItem, iParameter);
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.decreaseValueScanCode,
              KeyCode.left,
              state: PressedState.pressed,
            ),
          );
          expect(i, 9);
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.decreaseValueButton,
              state: PressedState.pressed,
            ),
          );
          expect(i, 8);
        },
      );
      test(
        'Increase Item',
        () {
          while (menu.currentMenuItem != iParameter) {
            menu.down();
          }
          menu.handleSdlEvent(
            makeKeyboardEvent(
              sdl,
              menu.increaseValueScanCode,
              KeyCode.right,
              state: PressedState.pressed,
            ),
          );
          expect(i, 9);
          menu.handleSdlEvent(
            makeControllerButtonEvent(
              sdl,
              menu.increaseValueButton,
              state: PressedState.pressed,
            ),
          );
          expect(i, 10);
        },
      );
      test(
        'Mixed Menu',
        () {
          final menu = ParameterMenu(
            game: game,
            title: const Message(),
            parameters: [
              ParameterMenuParameter(
                getLabel: () => emptyMessage,
                increaseValue: () {},
                decreaseValue: () {},
              )
            ],
          )..menuItems.add(const MenuItem(emptyMessage, menuItemLabel));
          expect(menu.menuItems.length, 2);
          expect(menu.menuItems.first, isA<ParameterMenuParameter>());
          expect(
            menu.menuItems.last,
            predicate(
              (final value) =>
                  value is MenuItem && value is! ParameterMenuParameter,
            ),
          );
        },
      );
    },
  );
}
