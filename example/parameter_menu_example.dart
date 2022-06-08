/// Demonstrates the use of a parameter menu.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/ziggurat.dart';

Future<void> main() async {
  final sdl = Sdl()..init();
  final game = Game(
    title: 'Parameter Menu',
    sdl: sdl,
  );
  var power = true;
  var speed = 5;
  final menu = ParameterMenu(
    game: game,
    title: const Message(text: 'Engine Parameters'),
    parameters: <ParameterMenuParameter>[],
    onCancel: () => game
      ..outputText('Quitting.')
      ..popLevel(ambianceFadeTime: 1.0)
      ..callAfter(runAfter: 1000, func: game.stop),
  );
  final powerMenuItem = ParameterMenuParameter(
    getLabel: () => Message(text: 'Power ${power ? "on" : "off"}'),
    increaseValue: () {
      power = true;
      menu.showCurrentItem();
    },
    decreaseValue: () {
      power = false;
      menu.showCurrentItem();
    },
  );
  final speedMenuItem = ParameterMenuParameter(
    getLabel: () => Message(text: 'Speed: $speed'),
    increaseValue: () {
      speed = min(speed + 1, 10);
      menu.showCurrentItem();
    },
    decreaseValue: () {
      speed = max(0, speed - 1);
      menu.showCurrentItem();
    },
  );
  menu.menuItems.addAll(<ParameterMenuParameter>[powerMenuItem, speedMenuItem]);
  await game.run(
    sdl,
    onStart: () => game.pushLevel(menu),
  );
}
