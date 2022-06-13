/// Provides the [BufferCache] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:encrypt/encrypt.dart';

import '../json/asset_reference.dart';

/// A class to get and hold buffers.
///
/// This class implements an LRU cache.
class BufferCache {
  /// Create a cache.
  BufferCache({
    required this.synthizer,
    required this.maxSize,
    required this.random,
  })  : _buffers = {},
        _files = [];

  /// The synthizer instance to use.
  final Synthizer synthizer;

  /// The maximum size of this cache.
  ///
  /// Note:
  /// * `1024` is 1 KB.
  /// * `1024 ** 2` is 1 MB.
  /// * `1024 ** 3` is 1 GB.
  final int maxSize;

  /// The random number generator used by [getBuffer].
  final Random random;

  /// The map which holds buffers.
  final Map<String, Buffer> _buffers;

  /// The most recently-accessed buffers.
  final List<String> _files;

  /// The size of this cache so far.
  int _size = 0;

  /// The current size of the cache.
  int get size => _size;

  /// Get a buffer.
  Buffer getBuffer(final AssetReference reference) {
    final file = reference.getFile(random);
    var buffer = _buffers[file.path];
    if (buffer == null) {
      final encryptionKey = reference.encryptionKey;
      if (encryptionKey == null) {
        buffer = Buffer.fromFile(synthizer, file);
      } else {
        final encrypter = Encrypter(AES(Key.fromBase64(encryptionKey)));
        final iv = IV.fromLength(16);
        final encrypted = Encrypted(file.readAsBytesSync());
        final data = encrypter.decryptBytes(encrypted, iv: iv);
        buffer = Buffer.fromBytes(synthizer, data);
      }
      _size += buffer.size;
      while (size > maxSize && _files.isNotEmpty) {
        prune();
      }
      _files.add(file.path);
      _buffers[file.path] = buffer;
    }
    return buffer;
  }

  /// Prune the cache.
  ///
  /// This method removes the oldest buffer and destroys it.
  ///
  /// It is used by [getBuffer] when [size] exceeds [maxSize].
  void prune() {
    final f = _files.removeAt(0);
    final b = _buffers.remove(f)!;
    _size -= b.size;
    b.destroy();
  }

  /// Destroy all [_buffers].
  void destroy() {
    while (size > 0) {
      prune();
    }
  }
}
