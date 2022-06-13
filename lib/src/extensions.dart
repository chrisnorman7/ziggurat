/// Provides various extensions used by Ziggurat.
import 'dart:io';
import 'dart:math';

import 'error.dart';
import 'math.dart';

/// An extension for returning a `Point<int>` from a `Point<double>`.
extension RunnerDoubleMethods on Point<double> {
  /// Return a floored version of this point.
  Point<int> floor() => Point<int>(x.floor(), y.floor());

  /// Return the angle between `this` and [other].
  double angleBetween(final Point<double> other) {
    // Check if the points are on top of each other and output something
    // reasonable.
    if (x == other.x && y == other.y) {
      return 0.0;
    }
    // If y1 and y2 are the same, we'll end up dividing by 0, and that's bad.
    if (y == other.y) {
      if (other.x > x) {
        return 90.0;
      } else {
        return 270.0;
      }
    }
    final angle = atan2(other.x - x, other.y - y);
    // Convert result from radians to degrees. If you want minutes and seconds
    // as well it's tough.
    final degrees = angle * 180 / pi;
    // Ensure the angle is between 0 and 360.
    return normaliseAngle(degrees);
  }
}

/// An extension for returning a `Point<double>` from a `Point<int>`.
extension RunnerIntMethods on Point<int> {
  /// Return a version of this point with the points converted to doubles.
  Point<double> toDouble() => Point<double>(x.toDouble(), y.toDouble());
}

/// An extension for getting random files from directories.
extension DirectoryMethods on Directory {
  /// Return a random file from a directory.
  ///
  /// If this entity is already a file, it will be returned.
  File randomFile(final Random random) {
    final files = <File>[
      for (final file in listSync())
        if (file is File) file
    ];
    if (files.isEmpty) {
      throw NoFilesError(this);
    }
    return files[random.nextInt(files.length)];
  }
}

/// Adds a method for always returning a file.
extension FileSystemEntityMethods on FileSystemEntity {
  /// Always return a file.
  File ensureFile(final Random random) {
    if (this is File) {
      return this as File;
    } else if (this is Directory) {
      return (this as Directory).randomFile(random);
    }
    throw InvalidEntityError(this);
  }
}

/// Size conversions.
extension SizeExtensions on int {
  /// Return the number of bytes in this value as kilobytes.
  int get kb => this * 1024;

  /// Return the number of bytes in this value as megabytes.
  int get mb => this * 1048576;

  /// Return the number of bytes in this value as gigabytes.
  int get gb => this * 1048576;

  /// Return the number of bytes in this value as terabytes.
  int get tb => this * pow(1024, 4).floor();
}
