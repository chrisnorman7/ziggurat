import 'package:json_annotation/json_annotation.dart';

import 'asset_reference.dart';

part 'asset_reference_reference.g.dart';

/// A class to hold an [AssetReference], as well as other meta data required to
/// generate Dart code.
@JsonSerializable()
class AssetReferenceReference {
  /// Create an instance.
  const AssetReferenceReference({
    required this.variableName,
    required this.reference,
    this.comment,
  });

  /// Create an instance from a JSON object.
  factory AssetReferenceReference.fromJson(final Map<String, dynamic> json) =>
      _$AssetReferenceReferenceFromJson(json);

  /// The name of the resulting variable.
  final String variableName;

  /// The comment to write above the variable declaration.
  final String? comment;

  /// The asset reference to use.
  final AssetReference reference;

  /// Convert an instance to JSON.
  ///
  /// /// resulting
  Map<String, dynamic> toJson() => _$AssetReferenceReferenceToJson(this);
}
