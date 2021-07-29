// ignore_for_file: avoid_print
/// Provides the [BasicInterface] class.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_synthizer/dart_synthizer.dart';

import 'src/directions.dart';
import 'src/extensions.dart';
import 'src/math.dart';
import 'src/runner.dart';

/// A basic command line interface for working with a single runner.
class BasicInterface {
  /// Create an interface.
  BasicInterface(this.synthizer, this.runner, this.echoSound);

  /// The synthizer object to work with.
  final Synthizer synthizer;

  /// The ziggurat to work with.
  final Runner runner;

  /// The sound to play as an echo sound with the z key.
  final File echoSound;

  /// Run the interface.
  Future<void> run() async {
    stdin
      ..echoMode = false
      ..lineMode = false;
    await for (final event in stdin) {
      final key = utf8.decode(event);
      switch (key) {
        case 'q':
          print('Goodbye.');
          runner.stop();
          runner.context.destroy();
          synthizer.shutdown();
          return;
        case 'c':
          final c = runner.coordinates.floor();
          print('${c.x}, ${c.y}');
          break;
        case 'x':
          final b = runner.currentBox;
          if (b != null) {
            final x =
                (100 / b.width * (runner.coordinates.x - b.start.x)).round();
            final y =
                (100 / b.height * (runner.coordinates.y - b.start.y)).round();
            print('${b.name} ($x%, $y%)');
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
          final index = (((runner.heading % 360) < 0
                          ? runner.heading + 360
                          : runner.heading) /
                      45)
                  .round() %
              directions.length;
          print(directions[index]);
          break;
        case 'w':
          runner.move();
          break;
        case 'd':
          runner.turn(45);
          break;
        case 'a':
          runner.turn(-45);
          break;
        case 's':
          runner.move(
              bearing: normaliseAngle(runner.heading + Directions.south),
              distance: 0.5);
          break;
        case 'z':
          final source = runner.playSound(echoSound, reverb: false);
          runner.playWallEchoes(source);
          break;
        default:
          break;
      }
    }
  }
}
