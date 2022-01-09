/// Provides functions which are used by all JSON classes.
import 'dart:math';

/// The separator for [Point] values.
const pointSeparator = ':';

/// Convert the provided [point] to a String.
String? pointDoubleToString(Point<double>? point) =>
    point == null ? null : '${point.x}$pointSeparator${point.y}';

/// Convert the given [string] to a nullable point.
Point<double>? stringToPointDoubleNullable(dynamic string) {
  if (string == null) {
    return null;
  } else if (string is String) {
    final parts = string.split(pointSeparator);
    if (parts.length != 2) {
      throw RangeError('Invalid value: $string');
    }
    final x = double.parse(parts.first);
    final y = double.parse(parts.last);
    return Point<double>(x, y);
  } else {
    throw UnimplementedError('Cannot handle $string.');
  }
}

/// Convert the given [string] to a non-nullable point.
Point<double> stringToPointDouble(dynamic string) {
  if (string is String) {
    final parts = string.split(pointSeparator);
    if (parts.length != 2) {
      throw RangeError('Invalid value: $string');
    }
    final x = double.parse(parts.first);
    final y = double.parse(parts.last);
    return Point<double>(x, y);
  } else {
    throw UnimplementedError('Cannot handle $string.');
  }
}
