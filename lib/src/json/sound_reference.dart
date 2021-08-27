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
  SoundReference(this.name, this.type);

  /// Create an instance from a JSON object.
  factory SoundReference.fromJson(Map<String, dynamic> json) =>
      _$SoundReferenceFromJson(json);

  /// Create an instance with its [type] set to [SoundType.file].
  factory SoundReference.file(String name) =>
      SoundReference(name, SoundType.file);

  /// Create an instance with its [type] set to [SoundType.collection].
  factory SoundReference.collection(String name) =>
      SoundReference(name, SoundType.collection);

  /// The name of this sound.
  final String name;

  /// The type of the sound.
  final SoundType type;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$SoundReferenceToJson(this);
}
