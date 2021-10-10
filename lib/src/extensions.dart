/// Provides various extensions used by Ziggurat.
import 'dart:io';
import 'dart:math';

import 'error.dart';

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
extension DirectoryMethods on Directory {
  /// Return a random file from a directory.
  ///
  /// If this entity is already a file, it will be returned.
  File randomFile(Random random) {
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
  File ensureFile(Random random) {
    if (this is File) {
      return this as File;
    } else if (this is Directory) {
      return (this as Directory).randomFile(random);
    }
    throw InvalidEntityError(this);
  }
}
