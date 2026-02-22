/// Smart Home AI — MQTT Broker Server
/// A lightweight, self-hosted MQTT v3.1.1 broker written in Dart.
/// Supports TCP (port 1883) and WebSocket (port 8083) connections.
///
/// © 2026 Circuvent Technologies Pvt Ltd, Hyderabad
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart' as crypto;

part '../src/mqtt_packet.dart';
part '../src/mqtt_session.dart';
part '../src/mqtt_topic.dart';
part '../src/mqtt_auth.dart';
part '../src/mqtt_broker.dart';
part '../src/mqtt_websocket.dart';
part '../src/mqtt_persistence.dart';

final _log = Logger('SmartHomeMQTT');

/// Entry point — start the broker on TCP 1883 & WS 8083.
Future<void> main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((r) {
    final time = r.time.toIso8601String().substring(11, 19);
    stderr.writeln('[$time] ${r.level.name}: ${r.message}');
  });

  final tcpPort = int.tryParse(_envOr('MQTT_TCP_PORT', '1883')) ?? 1883;
  final wsPort = int.tryParse(_envOr('MQTT_WS_PORT', '8083')) ?? 8083;
  final authUser = _envOr('MQTT_USER', 'smarthome');
  final authPass = _envOr('MQTT_PASSWORD', 'smarthome_password');

  final auth = MqttAuth()..addUser(authUser, authPass);
  final broker = MqttBroker(auth: auth);

  // TCP listener for native MQTT (ESP32, mobile apps)
  await broker.startTcp(tcpPort);
  _log.info('MQTT TCP broker listening on port $tcpPort');

  // WebSocket listener for browser-based Flutter web app
  await broker.startWebSocket(wsPort);
  _log.info('MQTT WebSocket broker listening on ws://0.0.0.0:$wsPort/mqtt');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    _log.info('Shutting down broker...');
    await broker.stop();
    exit(0);
  });

  _log.info('Smart Home MQTT Broker ready.');
  _log.info('  TCP  -> mqtt://0.0.0.0:$tcpPort');
  _log.info('  WS   -> ws://0.0.0.0:$wsPort/mqtt');
}

String _envOr(String key, String fallback) =>
    Platform.environment[key] ?? fallback;
