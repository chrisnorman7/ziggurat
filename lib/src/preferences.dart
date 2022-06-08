import 'dart:convert';
import 'dart:io';

const _encoder = JsonEncoder.withIndent('  ');

/// The default preferences key to be used by the [Preferences] class.
const defaultPreferencesKey = '__preferences__';

/// A class to save and return items to a preferences dictionary.
class Preferences {
  /// Create an instance.
  Preferences({
    required this.file,
    this.key = defaultPreferencesKey,
  });

  /// The file where preferences should be stored.
  final File file;

  /// The key where preferences will be saved and accessed from.
  final String key;

  /// The cached data.
  Map<String, Object?>? _cachedData;

  /// Get cached data.
  Map<String, Object?> get cache {
    var c = _cachedData;
    if (c == null) {
      if (file.existsSync()) {
        final data = file.readAsStringSync();
        c = jsonDecode(data) as Map<String, Object>;
      } else {
        c = <String, Object>{};
      }
      _cachedData = c;
    }
    return c;
  }

  /// Save the preferences.
  void save() {
    final json = _encoder.convert({key: cache});
    file.writeAsStringSync(json);
  }

  /// Set the given [name] to the given [value].
  void set(final String name, final Object value) {
    cache[name] = value;
    save();
  }

  /// Get the given [name] from the [cache].
  ///
  /// If [name] is not found in the [cache], [defaultValue] or `null` will be
  /// returned.
  T? get<T>(final String name, [final T? defaultValue]) {
    final c = cache;
    if (c.containsKey(name)) {
      return c[name] as T?;
    }
    return defaultValue;
  }

  /// Get [name] as a `String`.
  String? getString(final String name, [final String? defaultValue]) =>
      get<String>(name, defaultValue);

  /// Set the given key [name] to the given [value].
  void setString(final String name, final String value) => set(name, value);

  /// Get [name] as a `int`.
  int? getInt(final String name, [final int? defaultValue]) =>
      get<int>(name, defaultValue);

  /// Set the given key [name] to the given [value].
  void setInt(final String name, final int value) => set(name, value);

  /// Get [name] as a `double`.
  double? getDouble(final String name, [final double? defaultValue]) =>
      get<double>(name, defaultValue);

  /// Set the given key [name] to the given [value].
  void setDouble(final String name, final double value) => set(name, value);

  /// Get [name] as a `bool`.
  bool? getBool(
    final String name, [
    // ignore: avoid_positional_boolean_parameters
    final bool? defaultValue,
  ]) =>
      get<bool>(name, defaultValue);

  /// Set the given key [name] to the given [value].
  void setBool(
    final String name,
    // ignore: avoid_positional_boolean_parameters
    final bool value,
  ) =>
      set(name, value);
}
