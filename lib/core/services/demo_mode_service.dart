import 'package:flutter/foundation.dart';

/// Central service that controls whether the application runs in demo mode.
///
/// In DEMO mode:
///   - All services generate and display simulated/dummy data
///   - Timers run to animate sensor values, device states, etc.
///   - A "DEMO" badge is shown in the UI
///
/// In LIVE mode:
///   - Services attempt to connect to real backends (Firebase, MQTT, ESP32)
///   - If no real data is available, empty states are shown
///   - No simulated data is generated
class DemoModeService extends ChangeNotifier {
  bool _isDemoMode = false;

  /// Whether the app is currently in demo mode.
  bool get isDemoMode => _isDemoMode;

  /// Whether the app is in live (non-demo) mode.
  bool get isLiveMode => !_isDemoMode;

  /// Activate demo mode — enables simulated data across all services.
  void enableDemoMode() {
    if (_isDemoMode) return;
    _isDemoMode = true;
    notifyListeners();
  }

  /// Deactivate demo mode — switches to live data (or empty states).
  void disableDemoMode() {
    if (!_isDemoMode) return;
    _isDemoMode = false;
    notifyListeners();
  }

  /// Toggle between demo and live mode.
  void toggleDemoMode() {
    _isDemoMode = !_isDemoMode;
    notifyListeners();
  }

  /// Set demo mode explicitly.
  void setDemoMode(bool value) {
    if (_isDemoMode == value) return;
    _isDemoMode = value;
    notifyListeners();
  }
}
