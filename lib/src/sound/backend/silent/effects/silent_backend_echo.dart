/// Provides the [SilentBackendEcho] class.
import '../../effects/backend_echo.dart';

/// A silent echo.
///
/// This class does nothing.
class SilentBackendEcho implements BackendEcho {
  /// Create an instance.
  const SilentBackendEcho();

  @override
  void destroy() {}

  @override
  void reset() {}

  @override
  void setTaps(final Iterable<EchoTap> taps) {}
}
