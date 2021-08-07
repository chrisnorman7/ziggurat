/// A massive map will be created.
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/basic_interface.dart';
import 'package:ziggurat/ziggurat.dart';

/// The runner for this example.
class ExampleRunner extends Runner<Object> {
  /// Create an instance.
  ExampleRunner(Context ctx, BufferStore store, Ziggurat z)
      : super(ctx, store, Object(),
            Box('Player', Point(0, 0), Point(0, 0), Player())) {
    ziggurat = z;
  }

  @override
  void onBoxChange(
      {required Box<Agent> agent,
      required Box? newBox,
      required Box? oldBox,
      required Point<double> oldPosition,
      required Point<double> newPosition}) {
    super.onBoxChange(
        agent: agent,
        newBox: newBox,
        oldBox: oldBox,
        oldPosition: oldPosition,
        newPosition: newPosition);
    if (newBox != null) {
      // ignore: avoid_print
      print(newBox.name);
    }
  }
}

Future<void> main() async {
  final synthizer = Synthizer()..initialize();
  final ctx = synthizer.createContext();
  final z = Ziggurat('Massive Map');
  final bufferStore = BufferStore(Random(), synthizer);
  const size = 1000;
  final tileSound = await bufferStore.addFile(
      File('sounds/399934__old-waveplay__perc-short-click-snap-perc.wav'));
  for (var i = 0; i < size; i++) {
    for (var j = 0; j < size; j++) {
      final t =
          Box('Box', Point(i, j), Point(i, j), Surface(), sound: tileSound);
      z.boxes.add(t);
    }
  }
  final runner = ExampleRunner(ctx, bufferStore, z);
  final interface = BasicInterface(
      runner,
      await bufferStore.addFile(
          File('sounds/399934__old-waveplay__perc-short-click-snap-perc.wav')));
  await for (final _ in interface.run()) {}
}
