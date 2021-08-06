/// Provides the [BufferStore] class, and other related machinery.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';

import '../error.dart';
import '../json/sound_reference.dart';
import '../json/vault_file.dart';

/// The possible sound types.
enum SoundType {
  /// A single sound file.
  file,

  /// A list of buffers.
  collection,
}

/// A class for storing [Buffer] instances.
class BufferStore {
  /// Create an instance.
  BufferStore(this.random, this.synthizer)
      : _bufferFiles = {},
        _bufferCollections = {},
        _protectedBufferFiles = [],
        _protectedBufferCollections = [];

  /// The random number generator to be used by [getBuffer].
  final Random random;

  /// The synthizer instance to use.
  final Synthizer synthizer;

  /// The single buffer entries.
  final Map<String, Buffer> _bufferFiles;

  /// A list of all file entries in this store.
  List<String> get bufferFiles => _bufferFiles.keys.toList();

  /// The buffer collections.
  final Map<String, List<Buffer>> _bufferCollections;

  /// A list of buffer collections in this store.
  List<String> get bufferCollections => _bufferCollections.keys.toList();

  /// A list of buffer files that should be protected from the [clear] method.
  final List<String> _protectedBufferFiles;

  /// A list of collections which should be protected from [clear].
  final List<String> _protectedBufferCollections;

  /// add a buffer from a file.
  Future<SoundReference> addFile(File file,
      {String? name, bool protected = false}) async {
    final buffer = Buffer.fromBytes(synthizer, await file.readAsBytes());
    name ??= file.path;
    _bufferFiles[name] = buffer;
    if (protected) {
      _protectedBufferFiles.add(name);
    }
    return SoundReference.file(name);
  }

  /// Add a directory of files as a collection.
  Future<SoundReference> addDirectory(Directory directory,
      {String? name, bool protected = false}) async {
    final buffers = <Buffer>[];
    for (final file in directory.listSync()) {
      if (file is File) {
        buffers.add(Buffer.fromBytes(synthizer, await file.readAsBytes()));
      }
    }
    name ??= directory.path;
    _bufferCollections[name] = buffers;
    if (protected) {
      _protectedBufferCollections.add(name);
    }
    return SoundReference.collection(name);
  }

  /// Add the contents of a vault file.
  ///
  /// If [protected] is `true`, then each entry will be protected from the
  /// [clear] method.
  void addVaultFile(VaultFile vaultFile, {bool protected = false}) {
    for (final entry in vaultFile.files.entries) {
      final name = entry.key;
      if (_bufferFiles.containsKey(name)) {
        throw DuplicateEntryError(this, name, SoundType.file);
      }
      _bufferFiles[name] =
          Buffer.fromBytes(synthizer, base64Decode(entry.value));
      if (protected) {
        _protectedBufferFiles.add(name);
      }
    }
    for (final entry in vaultFile.folders.entries) {
      final name = entry.key;
      if (_bufferCollections.containsKey(name)) {
        throw DuplicateEntryError(this, name, SoundType.collection);
      }
      final buffers = <Buffer>[];
      for (final data in entry.value) {
        buffers.add(Buffer.fromBytes(synthizer, base64Decode(data)));
      }
      _bufferCollections[name] = buffers;
      if (protected) {
        _protectedBufferCollections.add(name);
      }
    }
  }

  /// Remove a buffer file.
  void removeBufferFile(String name) {
    final buffer = _bufferFiles.remove(name);
    if (buffer != null) {
      buffer.destroy();
    }
    if (_protectedBufferFiles.contains(name)) {
      _protectedBufferFiles.remove(name);
    }
  }

  /// Remove a buffer collection.
  void removeBufferCollection(String name) {
    final buffers = _bufferCollections.remove(name);
    if (buffers != null) {
      for (final buffer in buffers) {
        buffer.destroy();
      }
      if (_protectedBufferCollections.contains(name)) {
        _protectedBufferCollections.remove(name);
      }
    }
  }

  /// Clear buffers from this instance.
  void clear({bool includeProtected = false}) {
    for (final name in _bufferFiles.keys.toList()) {
      if (_protectedBufferFiles.contains(name) == false ||
          includeProtected == true) {
        removeBufferFile(name);
      }
    }
    for (final name in _bufferCollections.keys.toList()) {
      if (_protectedBufferCollections.contains(name) == false ||
          includeProtected == true) {
        removeBufferCollection(name);
      }
    }
  }

  /// Get a buffer.
  Buffer getBuffer(String name, SoundType type) {
    switch (type) {
      case SoundType.file:
        final buffer = _bufferFiles[name];
        if (buffer == null) {
          throw NoSuchBufferError(name, type: type);
        }
        return buffer;
      case SoundType.collection:
        final buffers = _bufferCollections[name];
        if (buffers != null) {
          return buffers[random.nextInt(buffers.length)];
        }
        throw NoSuchBufferError(name, type: type);
    }
  }

  /// Get a sound reference you can use with various objects in the library.
  ///
  /// This method will run through all files and collections to find a
  /// reference.
  ///
  /// If nothing is found, [NoSuchBufferError] will be thrown.
  SoundReference getSoundReference(String name) {
    if (_bufferFiles.containsKey(name)) {
      return SoundReference(name, SoundType.file);
    } else if (_bufferCollections.containsKey(name)) {
      return SoundReference(name, SoundType.collection);
    } else {
      throw NoSuchBufferError(name);
    }
  }
}
