import 'dart:math';

/// Return an angle between 0 and 359 degrees.
double normaliseAngle(final double angle) {
  if (angle < 0) {
    return angle + 360;
  } else if (angle > 359) {
    return angle - 360;
  }
  return angle;
}

/// Convert an [angle] to radians.
///
/// Formula taken from
/// [this link](https://synthizer.github.io/tutorials/python.html).
double angleToRad(final double angle) => angle * pi / 180.0;

/// Convert [radians] to degrees.
///
/// Function provided by Chat GPT.
double radsToDegrees(final double radians) => radians * (180 / pi);

/// Return coordinates in a given direction.
Point<double> coordinatesInDirection(
  final Point<double> start,
  final double bearing,
  final double distance,
) {
  final rad = angleToRad(bearing);
  final x = start.x + (distance * sin(rad));
  final y = start.y + (distance * cos(rad));
  return Point<double>(x, y);
}
