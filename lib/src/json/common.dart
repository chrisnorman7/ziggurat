/// Provides various common functions used by code in this directory.
import 'dart:convert';
import 'dart:io';

/// A mixin for providing simple dumping and loading.
mixin DumpLoadMixin {
  /// Convert this object to JSON.
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  /// Dump an instance to [file].
  void dump(File file) {
    final jsonEncoder = JsonEncoder.withIndent('  ');
    final data = toJson();
    final json = jsonEncoder.convert(data);
    file.writeAsStringSync(json);
  }
}
