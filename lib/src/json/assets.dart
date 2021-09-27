/// Provides classes relating to assets.
import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;

import '../extensions.dart';

part 'assets.g.dart';

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
  AssetReference(this.name, this.type, {this.encryptionKey});

  /// Create an instance from a JSON object.
  factory AssetReference.fromJson(Map<String, dynamic> json) =>
      _$AssetReferenceFromJson(json);

  /// Create an instance with its [type] set to [AssetType.file].
  AssetReference.file(this.name, {this.encryptionKey}) : type = AssetType.file;

  /// Create an instance with its [type] set to [AssetType.collection].
  AssetReference.collection(this.name, {this.encryptionKey})
      : type = AssetType.collection;

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

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AssetReferenceToJson(this);

  /// Load the contents of this asset.
  ///
  /// If [type] is [AssetType.collection], a random file will be loaded,
  /// selected with [random].
  List<int> load(Random random) {
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
      final encrypter = Encrypter(AES(Key.fromBase64(key)));
      final iv = IV.fromLength(16);
      final encrypted = Encrypted(file.readAsBytesSync());
      return encrypter.decryptBytes(encrypted, iv: iv);
    }
  }
}

/// A class to hold an [AssetReference], as well as other meta data required to
/// generate Dart code.
@JsonSerializable()
class AssetReferenceReference {
  /// Create an instance.
  AssetReferenceReference(
      {required this.variableName, required this.reference, this.comment});

  /// Create an instance from a JSON object.
  factory AssetReferenceReference.fromJson(Map<String, dynamic> json) =>
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

/// The resulting
/// A class for storing references to encrypted assets.
///
/// /// resulting
@JsonSerializable()
class AssetStore {
  /// Create an instance.
  ///
  /// /// resulting
  AssetStore(this.filename,
      {this.comment, List<AssetReferenceReference>? assets})
      : assets = assets ?? [];

  /// Create an instance from a JSON object.
  factory AssetStore.fromJson(Map<String, dynamic> json) =>
      _$AssetStoreFromJson(json);

  /// The dart filename for this store.
  final String filename;

  /// The comment at the top of the resulting dart file.
  final String? comment;

  /// All the assets in this store.
  final List<AssetReferenceReference> assets;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AssetStoreToJson(this);

  /// Import a single file.
  ///
  /// This method will encrypt [file], and place it in [directory].
  AssetReferenceReference importFile(
      {required File file,
      required Directory directory,
      required String variableName,
      String? comment}) {
    final filename = path.basename(file.path) + '.encrypted';
    final encryptionKey = SecureRandom(32).base64;
    final key = Key.fromBase64(encryptionKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final data = encrypter.encryptBytes(file.readAsBytesSync(), iv: iv).bytes;
    final destination = File(path.join(directory.path, filename))
      ..writeAsBytesSync(data);
    final reference =
        AssetReference.file(destination.path, encryptionKey: encryptionKey);
    final assetReferenceReference = AssetReferenceReference(
        variableName: variableName, reference: reference, comment: comment);
    assets.add(assetReferenceReference);
    return assetReferenceReference;
  }

  /// Import a directory.
  ///
  /// This method will copy an encrypted version of every file from [directory]
  /// to [destination].
  AssetReferenceReference importDirectory(
      {required Directory directory,
      required Directory destination,
      required String variableName,
      String? comment}) {
    final encryptionKey = SecureRandom(32).base64;
    final key = Key.fromBase64(encryptionKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    for (final entity in directory.listSync()) {
      if (entity is File) {
        final filename = path.basename(entity.path) + '.encrypted';
        final data =
            encrypter.encryptBytes(entity.readAsBytesSync(), iv: iv).bytes;
        File(path.join(destination.path, filename)).writeAsBytesSync(data);
      }
    }
    final reference = AssetReference.collection(destination.path,
        encryptionKey: encryptionKey);
    final assetReferenceReference = AssetReferenceReference(
        variableName: variableName, reference: reference, comment: comment);
    assets.add(assetReferenceReference);
    return assetReferenceReference;
  }
}
