// ignore_for_file: avoid_print
/// An example map.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/ziggurat.dart';

/// A custom map.
///
/// All setup is done in the constructor.
class Temple extends Ziggurat {
  Temple() : super('Temple') {
    final mainFloor = Tile<Surface>(
        'Main floor',
        Point<int>(0, 0),
        Point<int>(10, 20),
        Surface(reverbPreset: ReverbPreset('Main Floor Reverb', t60: 5.0)));
    final dividingWall = Tile<Wall>(
        'Dividing Wall',
        mainFloor.start - Point<int>(1, 0),
        mainFloor.cornerNw - Point<int>(1, 3),
        Wall());
    final storageRoom = Tile<Surface>(
        'Storage room',
        dividingWall.start - Point<int>(7, 0),
        mainFloor.cornerNw - Point<int>(dividingWall.width + 1, 0),
        Surface());
    final doorway = Tile<Surface>(
        'Doorway',
        dividingWall.cornerNw + Point<int>(0, 1),
        mainFloor.cornerNw - Point<int>(1, 0),
        Surface());
    final northWall = Tile<Wall>(
        'North Wall',
        storageRoom.cornerNw + Point<int>(-1, 1),
        mainFloor.end + Point<int>(1, 1),
        Wall());
    final eastWall = Tile<Wall>(
        'East Wall',
        mainFloor.cornerSe + Point<int>(1, 0),
        mainFloor.end + Point<int>(1, 0),
        Wall());
    final southWall = Tile<Wall>(
        'South Wall',
        storageRoom.start - Point<int>(1, 1),
        mainFloor.cornerSe + Point<int>(1, -1),
        Wall());
    tiles.addAll([
      mainFloor,
      storageRoom,
      doorway,
      northWall,
      eastWall,
      southWall,
      dividingWall,
      Tile<Wall>('West Wall', storageRoom.start - Point<int>(1, 0),
          storageRoom.cornerNw - Point<int>(1, 0), Wall())
    ]);
    randomSounds.addAll([
      RandomSound(Directory('sounds/random'), mainFloor.start.toDouble(),
          mainFloor.end.toDouble(), 5000, 15000,
          minGain: 0.1, maxGain: 0.5)
    ]);
    ambiances.addAll([
      Ambiance(File('sounds/ambiances/546153__ssssrt__buzzing-lights.wav'),
          doorway.centre,
          gain: 3.0),
      Ambiance(
          File(
              'sounds/ambiances/325647__shadydave__expressions-of-the-mind-piano-loop.mp3'),
          null,
          gain: 0.25)
    ]);
  }
}

/// Run the example.
void main() {
  final synthizer = Synthizer()..initialize();
  final bufferCache = BufferCache(synthizer, pow(1024, 3).floor());
  final ctx = synthizer.createContext()
    ..defaultPannerStrategy = PannerStrategies.hrtf;
  final t = Temple();
  final r = Runner(ctx, bufferCache)..ziggurat = t;
  stdin
    ..echoMode = false
    ..lineMode = false;
  StreamSubscription<List<int>>? stdinListener;
  stdinListener = stdin.listen((event) {
    final key = utf8.decode(event);
    switch (key) {
      case 'q':
        print('Goodbye.');
        r.stop();
        stdinListener?.cancel();
        ctx.destroy();
        synthizer.shutdown();
        break;
      case 'c':
        final c = r.coordinates.floor();
        print('${c.x}, ${c.y}');
        break;
      case 'x':
        final t = r.currentTile;
        if (t != null) {
          print(t.name);
        }
        break;
      case 'f':
        final directions = <String>[
          'north',
          'northeast',
          'east',
          'southeast',
          'south',
          'southwest',
          'west',
          'northwest'
        ];
        final index =
            (((r.heading % 360) < 0 ? r.heading + 360 : r.heading) / 45)
                    .round() %
                directions.length;
        print(directions[index]);
        break;
      case 'w':
        r.move();
        break;
      case 'd':
        r.turn(45);
        break;
      case 'a':
        r.turn(-45);
        break;
      case 's':
        r.turn(180);
        break;
      default:
        break;
    }
  });
}
