/// A massive map will be created.
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/basic_interface.dart';
import 'package:ziggurat/ziggurat.dart';

/// The runner for this example.
class ExampleRunner extends Runner<Object> {
  /// Create an instance.
  ExampleRunner(Context ctx, BufferCache cache, Ziggurat z)
      : super(ctx, cache, Object()) {
    ziggurat = z;
  }
  @override
  void onTileChange(Tile t) {
    // ignore: avoid_print
    print(t.name);
  }
}

void main() {
  final synthizer = Synthizer()..initialize();
  final ctx = synthizer.createContext();
  final z = Ziggurat('Massive Map');
  const size = 1000;
  final tileSound =
      File('sounds/399934__old-waveplay__perc-short-click-snap-perc.wav');
  for (var i = 0; i < size; i++) {
    for (var j = 0; j < size; j++) {
      final t = Tile('Tile', Point<int>(i, j), Point<int>(i, j), Surface(),
          sound: tileSound);
      z.tiles.add(t);
    }
  }
  final runner = ExampleRunner(ctx, BufferCache(synthizer, 1024 ^ 3), z);
  final interface = BasicInterface(synthizer, runner,
      File('sounds/399934__old-waveplay__perc-short-click-snap-perc.wav'));
  return interface.run();
}
