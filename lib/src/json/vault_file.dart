/// Provides the [VaultFile] class.
import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vault_file.g.dart';

/// The type for [VaultFile.files].
typedef FilesType = Map<String, List<int>>;

/// The type for [VaultFile.folders].
typedef FoldersType = Map<String, List<List<int>>>;

/// A collection of files and folders stored as strings.
@JsonSerializable()
class VaultFile {
  /// Create an instance.
  VaultFile({FilesType? files, FoldersType? folders})
      : files = files ?? {},
        folders = folders ?? {};

  /// Create an instance from a JSON object.
  factory VaultFile.fromJson(Map<String, dynamic> json) =>
      _$VaultFileFromJson(json);

  /// Create an instance from an encrypted string.
  factory VaultFile.fromEncryptedString(
      {required String contents, required String encryptionKey}) {
    final key = Key.fromBase64(encryptionKey);
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromLength(16);
    final encrypted = Encrypted.fromBase64(contents);
    final data = encrypter.decrypt(encrypted, iv: iv);
    final Map<String, dynamic> json = jsonDecode(data) as Map<String, dynamic>;
    return VaultFile.fromJson(json);
  }

  /// A map of filenames to contents.
  final FilesType files;

  /// A map of folder names to lists of file contents.
  final FoldersType folders;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$VaultFileToJson(this);

  /// Convert this instance to an encrypted string.
  String toEncryptedString({required String encryptionKey}) {
    final key = Key.fromBase64(encryptionKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final json = jsonEncode(toJson());
    final encrypted = encrypter.encrypt(json, iv: iv);
    return encrypted.base64;
  }
}
