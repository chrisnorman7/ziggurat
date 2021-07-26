/// Provides various extensions used by Ziggurat.
import 'dart:io';
import 'dart:math';

import 'error.dart';
import 'runner.dart';

/// An extension for returning a `Point<int>` from a `Point<double>`.
extension RunnerDoubleMethods on Point<double> {
  /// Return a floored version of this point.
  Point<int> floor() => Point<int>(x.floor(), y.floor());
}

/// An extension for returning a `Point<double>` from a `Point<int>`.
extension RunnerIntMethods on Point<int> {
  /// Return a version of this point with the points converted to doubles.
  Point<double> toDouble() => Point<double>(x.toDouble(), y.toDouble());
}

/// An extension for getting random files from directories.
extension RunnerMethods on Directory {
  /// Return a random file from a directory.
  ///
  /// If this entity is already a file, it will be returned.
  File randomFile(Random random) {
    final files = listSync();
    if (files.isEmpty) {
      throw NoFilesError(this);
    }
    final f = files[random.nextInt(files.length)];
    if (f is File) {
      return f;
    } else if (f is Directory) {
      return f.randomFile(random);
    } else {
      throw InvalidEntityError(f);
    }
  }
}

/// Adds a method for always returning a file.
extension RunnerFileMethods on FileSystemEntity {
  /// Always return a file.
  File ensureFile(Random random) {
    if (this is File) {
      return this as File;
    } else if (this is Directory) {
      return (this as Directory).randomFile(random);
    }
    throw InvalidEntityError(this);
  }
}

/// Various extension methods mainly used when setting [Runner.ziggurat].
extension VariousMethods on List<int> {
  /// Get the sum of this list.
  int get sum => reduce((a, b) => a + b);

  /// Get the average number in this list.
  double get average => sum / length;
}
