// ignore_for_file: avoid_print

import 'package:dart_sdl/dart_sdl.dart';
import 'package:ziggurat/ziggurat.dart';

Future<void> main() async {
  final sdl = Sdl()..init();
  final game = Game('Editor Example');
  final editor = Editor(game, text: 'Hello, ziggurat');
  game.pushLevel(editor);
  await game.run(sdl);
  print('Final text was: ${editor.text}');
  sdl.quit();
}
