// ignore_for_file: avoid_print
/// Provides the [BasicInterface] class.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_synthizer/dart_synthizer.dart';

import 'src/extensions.dart';
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
          final t = runner.currentBox;
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
          runner.turn(180);
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
