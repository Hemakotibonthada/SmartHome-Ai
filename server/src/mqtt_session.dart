part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MQTT Client Session — tracks subscriptions, queued messages, keep-alive
// ──────────────────────────────────────────────────────────────────────────────

class MqttSession {
  final String clientId;
  final void Function(Uint8List data) _send;
  final void Function() _close;
  final String transportLabel; // "tcp" or "ws"

  final Set<String> subscriptions = {};
  final Map<String, int> subscriptionQos = {};
  bool connected = true;
  DateTime lastActivity = DateTime.now();
  Timer? _keepAliveTimer;
  int _nextPacketId = 1;
  String? username;

  MqttSession({
    required this.clientId,
    required void Function(Uint8List) send,
    required void Function() close,
    this.transportLabel = 'tcp',
  })  : _send = send,
        _close = close;

  int get nextPacketId {
    final id = _nextPacketId;
    _nextPacketId = (_nextPacketId % 65535) + 1;
    return id;
  }

  void send(Uint8List data) {
    if (!connected) return;
    try {
      _send(data);
    } catch (e) {
      _log.warning('[$clientId] Send failed: $e');
      disconnect();
    }
  }

  void startKeepAlive(int keepAliveSeconds) {
    _keepAliveTimer?.cancel();
    if (keepAliveSeconds <= 0) return;
    // MQTT spec: 1.5x keep-alive before timeout
    final timeout = Duration(seconds: (keepAliveSeconds * 1.5).toInt());
    _keepAliveTimer = Timer.periodic(timeout, (_) {
      if (DateTime.now().difference(lastActivity) > timeout) {
        _log.info('[$clientId] Keep-alive timeout');
        disconnect();
      }
    });
  }

  void touch() => lastActivity = DateTime.now();

  void disconnect() {
    if (!connected) return;
    connected = false;
    _keepAliveTimer?.cancel();
    try {
      _close();
    } catch (_) {}
  }

  @override
  String toString() => 'Session($clientId via $transportLabel)';
}
