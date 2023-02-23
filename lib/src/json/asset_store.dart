/// Provides classes relating to asset stores.
import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;

import '../../util.dart';
import 'asset_reference.dart';
import 'asset_reference_reference.dart';
import 'common.dart';

part 'asset_store.g.dart';

/// A class for storing references to assets.
@JsonSerializable()
class AssetStore with DumpLoadMixin {
  /// Create an instance.
  const AssetStore({
    required this.filename,
    required this.destination,
    required this.assets,
    this.comment,
  });

  /// Create an instance from a JSON object.
  factory AssetStore.fromJson(final Map<String, dynamic> json) =>
      _$AssetStoreFromJson(json);

  /// Create an instance from [file].
  factory AssetStore.fromFile(final File file) {
    final dynamic json = jsonDecode(file.readAsStringSync());
    return AssetStore.fromJson(json as Map<String, dynamic>);
  }

  /// The dart filename for this store.
  final String filename;

  /// The directory where all files will end up.
  final String destination;

  /// The directory where assets will reside.
  Directory get directory => Directory(destination);

  /// Get an absolute version of [directory], relative to [relativeTo].
  Directory getAbsoluteDirectory(final Directory relativeTo) => Directory(
        path.join(relativeTo.path, destination),
      );

  /// The comment at the top of the resulting dart file.
  final String? comment;

  /// All the assets in this store.
  final List<AssetReferenceReference> assets;

  /// Convert an instance to JSON.
  @override
  Map<String, dynamic> toJson() => _$AssetStoreToJson(this);

  /// Get an unused filename.
  String getNextFilename({
    final String suffix = '',
    final Directory? relativeTo,
  }) {
    final Directory d;
    if (relativeTo != null) {
      d = getAbsoluteDirectory(relativeTo);
    } else {
      d = directory;
    }
    var i = 0;
    while (true) {
      var fname = path.join(d.path, '$i$suffix');
      if (File(fname).existsSync() == false &&
          Directory(fname).existsSync() == false) {
        if (relativeTo != null) {
          fname = path.relative(fname, from: relativeTo.path);
        }
        return fname.replaceAll(r'\', '/');
      }
      i++;
    }
  }

  /// Import a single file.
  ///
  /// This method will encrypt [source], and place it in [destination].
  ///
  /// If this asset store is located in a directory other than the current one,
  /// use the [relativeTo] argument to ensure paths still work.
  AssetReferenceReference importFile({
    required final File source,
    required final String variableName,
    final String? comment,
    final Directory? relativeTo,
  }) {
    final Directory d;
    if (relativeTo != null) {
      d = getAbsoluteDirectory(relativeTo);
    } else {
      d = directory;
    }
    if (d.existsSync() == false) {
      d.createSync();
    }
    final fname = getNextFilename(suffix: '.encrypted', relativeTo: relativeTo);
    var filename = fname;
    if (relativeTo != null) {
      filename = path.join(relativeTo.path, filename);
    }
    final encryptionKey = encryptFile(
      inputFile: source,
      outputFile: File(filename),
    );
    final reference = AssetReference.file(fname, encryptionKey: encryptionKey);
    final assetReferenceReference = AssetReferenceReference(
      variableName: variableName,
      reference: reference,
      comment: comment,
    );
    assets.add(assetReferenceReference);
    return assetReferenceReference;
  }

  /// Import a directory.
  ///
  /// This method will copy an encrypted version of every file from [directory]
  /// to [destination].
  ///
  /// If this asset store is located in a directory other than the current one,
  /// use the [relativeTo] argument to ensure paths still work.
  AssetReferenceReference importDirectory({
    required final Directory source,
    required final String variableName,
    final String? comment,
    final Directory? relativeTo,
  }) {
    final Directory d;
    if (relativeTo != null) {
      d = getAbsoluteDirectory(relativeTo);
    } else {
      d = directory;
    }
    if (d.existsSync() == false) {
      d.createSync();
    }
    final directoryName = getNextFilename(relativeTo: relativeTo);
    var absoluteDirectoryName = directoryName;
    if (relativeTo != null) {
      absoluteDirectoryName = path.join(relativeTo.path, absoluteDirectoryName);
    }
    Directory(absoluteDirectoryName).createSync();
    final encryptionKey = SecureRandom(32).base64;
    final key = Key.fromBase64(encryptionKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    for (final entity in source.listSync().whereType<File>()) {
      final filename = '${path.basename(entity.path)}.encrypted';
      final data =
          encrypter.encryptBytes(entity.readAsBytesSync(), iv: iv).bytes;
      File(path.join(absoluteDirectoryName, filename)).writeAsBytesSync(data);
    }
    final reference = AssetReference.collection(
      directoryName,
      encryptionKey: encryptionKey,
    );
    final assetReferenceReference = AssetReferenceReference(
      variableName: variableName,
      reference: reference,
      comment: comment,
    );
    assets.add(assetReferenceReference);
    return assetReferenceReference;
  }
}
