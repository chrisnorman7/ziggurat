/// Provides the [DataFile] and [DataFileEntry] classes.
import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'data_file.g.dart';

/// An entry in a [DataFile] instance.
@JsonSerializable()
class DataFileEntry {
  /// Create an instance.
  DataFileEntry(this.variableName, this.fileName, {this.comment});

  /// Create an instance from a JSON object.
  factory DataFileEntry.fromJson(Map<String, dynamic> json) =>
      _$DataFileEntryFromJson(json);

  /// The name of the resulting dart variable.
  final String variableName;

  /// The name of the file to load.
  final String fileName;

  /// The comment to show above the entry.
  String? comment;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$DataFileEntryToJson(this);
}

/// A class which holds a list of [DataFileEntry] instances.
@JsonSerializable()
class DataFile {
  /// Create an instance.
  DataFile({this.comment, List<DataFileEntry>? entries})
      : entries = entries ?? [];

  /// Create an instance from a JSON object.
  factory DataFile.fromJson(Map<String, dynamic> json) =>
      _$DataFileFromJson(json);

  /// Create an instance from a file.
  factory DataFile.fromFile(File file) => DataFile.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);

  /// All the entries for this file.
  final List<DataFileEntry> entries;

  /// The leading comment for the resulting dart file.
  final String? comment;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$DataFileToJson(this);

  /// Dump an instance to [file].
  void dump(File file) {
    final jsonEncoder = JsonEncoder.withIndent('  ');
    final data = toJson();
    final json = jsonEncoder.convert(data);
    file.writeAsStringSync(json);
  }
}
