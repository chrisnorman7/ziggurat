/// Provides the [SoundReference] class.
import 'package:json_annotation/json_annotation.dart';

part 'sound_reference.g.dart';

/// The possible sound types.
enum SoundType {
  /// A single sound file.
  file,

  /// A list of buffers.
  collection,
}

/// A reference to a sound.
@JsonSerializable()
class SoundReference {
  /// Create an instance.
  SoundReference(this.name, this.type, {this.encryptionKey});

  /// Create an instance from a JSON object.
  factory SoundReference.fromJson(Map<String, dynamic> json) =>
      _$SoundReferenceFromJson(json);

  /// Create an instance with its [type] set to [SoundType.file].
  factory SoundReference.file(String name, {String? encryptionKey}) =>
      SoundReference(name, SoundType.file, encryptionKey: encryptionKey);

  /// Create an instance with its [type] set to [SoundType.collection].
  factory SoundReference.collection(String name, {String? encryptionKey}) =>
      SoundReference(name, SoundType.collection, encryptionKey: encryptionKey);

  /// The name of this sound.
  ///
  /// This the [type] is [SoundType.collection], [name] will be the name of the
  /// directory to load a random file from. Otherwise, [name] will be the
  /// filename.
  final String name;

  /// The type of the sound.
  final SoundType type;

  /// The encryption key, if any.
  ///
  /// If this value is `null`, the file or contents of the folder is assumed to
  /// be unencrypted.
  final String? encryptionKey;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$SoundReferenceToJson(this);
}
