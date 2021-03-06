// ignore_for_file: avoid_print

import 'package:dart_sdl/dart_sdl.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/src/sound/backend/silent/silent_sound_backend.dart';
import 'package:ziggurat/ziggurat.dart';

Future<void> main() async {
  final sdl = Sdl()..init();
  final game = Game(
    title: 'Editor Example',
    sdl: sdl,
    soundBackend: SilentSoundBackend(),
  );
  final editor = Editor(
    game: game,
    onDone: (final value) {
      game.stop();
      print('Final value was $value.');
    },
    onCancel: () {
      game.stop();
      print('Cancelled.');
    },
  );
  game.pushLevel(editor);
  await game.run();
  sdl.quit();
}
