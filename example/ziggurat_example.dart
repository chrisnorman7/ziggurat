// ignore_for_file: avoid_print
/// An example map.
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/basic_interface.dart';
import 'package:ziggurat/ziggurat.dart';

/// A custom map.
///
/// All setup is done in the constructor.
class Temple extends Ziggurat {
  Temple() : super('Temple') {
    final defaultReverb = ReverbPreset('Default');
    final wallSound = File('sounds/249618__vincentm400__invalid.mp3');
    final mainFloor = Tile<Surface>(
        'Main floor',
        Point<int>(0, 0),
        Point<int>(10, 20),
        Surface(reverbPreset: ReverbPreset('Main Floor Reverb', t60: 5.0)),
        sound: Directory('sounds/footsteps/concrete'));
    final dividingWall = Tile<Wall>(
        'Dividing Wall',
        mainFloor.start - Point<int>(1, 0),
        mainFloor.cornerNw - Point<int>(1, 3),
        Wall(),
        sound: wallSound);
    final storageRoom = Tile<Surface>(
        'Storage room',
        dividingWall.start - Point<int>(7, 0),
        mainFloor.cornerNw - Point<int>(dividingWall.width + 1, 0),
        Surface(reverbPreset: defaultReverb),
        sound: Directory('sounds/footsteps/wood'));
    final doorway = Tile<Surface>(
        'Doorway',
        dividingWall.cornerNw + Point<int>(0, 1),
        mainFloor.cornerNw - Point<int>(1, 0),
        Surface(reverbPreset: defaultReverb),
        sound: Directory('sounds/footsteps/metal'));
    final northWall = Tile<Wall>(
        'North Wall',
        storageRoom.cornerNw + Point<int>(-1, 1),
        mainFloor.end + Point<int>(1, 1),
        Wall(),
        sound: wallSound);
    final eastWall = Tile<Wall>(
        'East Wall',
        mainFloor.cornerSe + Point<int>(1, 0),
        mainFloor.end + Point<int>(1, 0),
        Wall(),
        sound: wallSound);
    final southWall = Tile<Wall>(
        'South Wall',
        storageRoom.start - Point<int>(1, 1),
        mainFloor.cornerSe + Point<int>(1, -1),
        Wall(),
        sound: wallSound);
    tiles.addAll([
      mainFloor,
      storageRoom,
      doorway,
      northWall,
      eastWall,
      southWall,
      dividingWall,
      Tile<Wall>('West Wall', storageRoom.start - Point<int>(1, 0),
          storageRoom.cornerNw - Point<int>(1, 0), Wall(),
          sound: wallSound)
    ]);
    randomSounds.addAll([
      RandomSound(Directory('sounds/random'), mainFloor.start.toDouble(),
          mainFloor.end.toDouble(), 5000, 15000,
          minGain: 0.1, maxGain: 0.5)
    ]);
    ambiances.addAll([
      Ambiance(File('sounds/ambiances/546153__ssssrt__buzzing-lights.wav'),
          Point<double>(storageRoom.end.x.toDouble(), doorway.centre.y),
          gain: 2.0),
      Ambiance(File('sounds/ambiances/546153__ssssrt__buzzing-lights.wav'),
          Point<double>(mainFloor.cornerNw.x.toDouble(), doorway.centre.y),
          gain: 2.0),
      Ambiance(
          File(
              'sounds/ambiances/325647__shadydave__expressions-of-the-mind-piano-loop.mp3'),
          null,
          gain: 0.25)
    ]);
  }
}

/// Game state to keep track of progress.
class GameState {}

/// The runner for this example.
class ExampleRunner extends Runner<GameState> {
  /// Create an instance.
  ExampleRunner(Context ctx, BufferCache cache, Ziggurat z)
      : super(ctx, cache, GameState()) {
    ziggurat = z;
  }
  @override
  void onTileChange(Tile t) {
    print(t.name);
  }
}

/// Run the example.
void main() {
  final synthizer = Synthizer()..initialize();
  final bufferCache = BufferCache(synthizer, pow(1024, 3).floor());
  final ctx = synthizer.createContext()
    ..defaultPannerStrategy = PannerStrategies.hrtf;
  final t = Temple();
  final r = ExampleRunner(ctx, bufferCache, t);
  final interface = BasicInterface(synthizer, r,
      File('sounds/399934__old-waveplay__perc-short-click-snap-perc.wav'));
  return interface.run();
}
