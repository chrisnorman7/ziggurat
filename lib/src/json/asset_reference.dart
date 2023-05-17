/// Provides classes relating to assets.
import 'dart:io';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../../util.dart';
import '../extensions.dart';

part 'asset_reference.g.dart';

/// The default gain to use.
const defaultGain = 0.7;

/// The possible asset types.
enum AssetType {
  /// A single file.
  file,

  /// A list of files.
  collection,
}

/// A reference to an asset on disk.
@JsonSerializable()
class AssetReference {
  /// Create an instance.
  const AssetReference(
    this.name,
    this.type, {
    this.encryptionKey,
    this.gain = defaultGain,
  });

  /// Create an instance from a JSON object.
  factory AssetReference.fromJson(final Map<String, dynamic> json) =>
      _$AssetReferenceFromJson(json);

  /// Create an instance with its [type] set to [AssetType.file].
  const AssetReference.file(
    this.name, {
    this.encryptionKey,
    this.gain = defaultGain,
  }) : type = AssetType.file;

  /// Create an instance with its [type] set to [AssetType.collection].
  const AssetReference.collection(
    this.name, {
    this.encryptionKey,
    this.gain = defaultGain,
  }) : type = AssetType.collection;

  /// The name of this sound.
  ///
  /// This the [type] is [AssetType.collection], [name] will be the name of the
  /// directory to load a random file from. Otherwise, [name] will be the
  /// filename.
  final String name;

  /// The type of the sound.
  final AssetType type;

  /// The encryption key, if any.
  ///
  /// If this value is `null`, the file or contents of the folder is assumed to
  /// be unencrypted.
  final String? encryptionKey;

  /// The gain to play this sound at.
  final double gain;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AssetReferenceToJson(this);

  /// Load the contents of this asset.
  ///
  /// If [type] is [AssetType.collection], a random file will be loaded,
  /// selected with [random].
  List<int> load(final Random random) {
    final File file;
    if (type == AssetType.file) {
      file = File(name);
    } else {
      file = Directory(name).randomFile(random);
    }
    final key = encryptionKey;
    if (key == null) {
      return file.readAsBytesSync();
    } else {
      return decryptFileBytes(file: file, encryptionKey: key);
    }
  }

  /// Get a file from this reference.
  ///
  /// If [type] is [AssetType.file], just return a [File] with its path set to
  /// [name]. Otherwise, use the [FileSystemEntityMethods] extension to
  /// return a random file from a [Directory] with [name] as the path.
  File getFile(final Random random) {
    if (type == AssetType.file) {
      return File(name);
    }
    return Directory(name).randomFile(random);
  }

  /// Return a copy of this object with a new [gain] value.
  AssetReference copy(final double gain) => AssetReference(
        name,
        type,
        encryptionKey: encryptionKey,
        gain: gain,
      );

  /// Return a version of this [AssetReference] with [gain] set to `0.0`.
  AssetReference silent() => copy(0.0);
}
