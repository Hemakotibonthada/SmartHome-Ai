part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Core MQTT Broker — manages sessions, routing, retained messages
// ──────────────────────────────────────────────────────────────────────────────

class MqttBroker {
  final MqttAuth auth;
  final MqttPersistence persistence = MqttPersistence();
  final Map<String, MqttSession> _sessions = {};
  final _uuid = const Uuid();

  ServerSocket? _tcpServer;
  HttpServer? _wsServer;

  // Metrics
  int _totalConnections = 0;
  int _totalMessages = 0;
  final DateTime _startTime = DateTime.now();

  MqttBroker({required this.auth});

  // ─── TCP Listener ─────────────────────────────────────────────────────────

  Future<void> startTcp(int port) async {
    _tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _tcpServer!.listen(_handleTcpConnection);
  }

  void _handleTcpConnection(Socket socket) {
    _totalConnections++;
    final remote = '${socket.remoteAddress.address}:${socket.remotePort}';
    _log.fine('TCP connection from $remote');

    final decoder = MqttPacketDecoder();
    MqttSession? session;

    socket.listen(
      (data) {
        final packets = decoder.add(Uint8List.fromList(data));
        for (final packet in packets) {
          session = _handlePacket(
            packet,
            session,
            send: (d) => socket.add(d),
            close: () => socket.destroy(),
            transport: 'tcp',
            remote: remote,
          );
        }
      },
      onError: (e) {
        _log.warning('TCP error from $remote: $e');
        _removeSession(session);
      },
      onDone: () {
        _log.fine('TCP disconnect from $remote');
        _removeSession(session);
      },
    );
  }

  // ─── Packet Handler (shared by TCP and WebSocket) ─────────────────────────

  MqttSession? _handlePacket(
    MqttPacket packet,
    MqttSession? session, {
    required void Function(Uint8List) send,
    required void Function() close,
    required String transport,
    required String remote,
  }) {
    switch (packet.type) {
      case MqttPacketType.connect:
        return _handleConnect(packet, send, close, transport, remote);

      case MqttPacketType.publish:
        if (session != null) _handlePublish(packet, session);
        break;

      case MqttPacketType.puback:
        session?.touch();
        break;

      case MqttPacketType.subscribe:
        if (session != null) _handleSubscribe(packet, session);
        break;

      case MqttPacketType.unsubscribe:
        if (session != null) _handleUnsubscribe(packet, session);
        break;

      case MqttPacketType.pingreq:
        session?.touch();
        send(buildPingresp());
        break;

      case MqttPacketType.disconnect:
        _log.info('[${session?.clientId ?? remote}] Clean disconnect');
        _removeSession(session);
        break;
    }
    return session;
  }

  // ─── CONNECT ──────────────────────────────────────────────────────────────

  MqttSession _handleConnect(
    MqttPacket packet,
    void Function(Uint8List) send,
    void Function() close,
    String transport,
    String remote,
  ) {
    final connect = ConnectPayload.parse(packet.payload);

    // Authenticate
    if (!auth.authenticate(connect.username, connect.password)) {
      _log.warning('Auth failed for ${connect.username ?? 'anonymous'} from $remote');
      send(buildConnack(5)); // 5 = Not authorized
      close();
      return MqttSession(clientId: '', send: send, close: close);
    }

    // Generate client ID if empty
    var clientId = connect.clientId;
    if (clientId.isEmpty) {
      clientId = 'auto_${_uuid.v4().substring(0, 8)}';
    }

    // Disconnect existing session with same client ID
    if (_sessions.containsKey(clientId)) {
      _log.info('[$clientId] Replacing existing session');
      _sessions[clientId]!.disconnect();
      _sessions.remove(clientId);
    }

    final session = MqttSession(
      clientId: clientId,
      send: send,
      close: close,
      transportLabel: transport,
    );
    session.username = connect.username;
    session.startKeepAlive(connect.keepAlive);

    _sessions[clientId] = session;
    send(buildConnack(0)); // 0 = Connection accepted

    _log.info('[$clientId] Connected via $transport from $remote '
        '(user: ${connect.username ?? "anon"}, keepAlive: ${connect.keepAlive}s)');

    // Publish will message if client has one and disconnects uncleanly
    // (handled on disconnect — stored in session)

    return session;
  }

  // ─── PUBLISH ──────────────────────────────────────────────────────────────

  void _handlePublish(MqttPacket packet, MqttSession session) {
    session.touch();
    _totalMessages++;

    final data = packet.payload;
    var offset = 0;

    // Topic
    final topicLen = (data[offset] << 8) | data[offset + 1];
    offset += 2;
    final topic = utf8.decode(data.sublist(offset, offset + topicLen));
    offset += topicLen;

    // QoS
    final qos = packet.qos;
    int? packetId;
    if (qos > 0) {
      packetId = (data[offset] << 8) | data[offset + 1];
      offset += 2;
    }

    // Message payload
    final message = data.sublist(offset);

    // ACK for QoS 1
    if (qos == 1 && packetId != null) {
      session.send(buildPuback(packetId));
    }

    // Store retained message
    if (packet.isRetain) {
      persistence.setRetained(topic, Uint8List.fromList(message), qos: qos);
    }

    // Route to matching subscribers
    _routeMessage(topic, Uint8List.fromList(message), qos: qos,
        senderClientId: session.clientId);

    _log.fine('[${session.clientId}] PUBLISH $topic (${message.length} bytes, QoS $qos)');
  }

  // ─── SUBSCRIBE ────────────────────────────────────────────────────────────

  void _handleSubscribe(MqttPacket packet, MqttSession session) {
    session.touch();
    final data = packet.payload;

    final packetId = (data[0] << 8) | data[1];
    var offset = 2;

    final grantedQos = <int>[];

    while (offset < data.length) {
      final (filter, newOffset) = readMqttString(data, offset);
      offset = newOffset;
      final requestedQos = data[offset++];

      if (isValidSubscriptionFilter(filter)) {
        session.subscriptions.add(filter);
        session.subscriptionQos[filter] = requestedQos;
        final granted = requestedQos > 1 ? 1 : requestedQos; // Cap at QoS 1
        grantedQos.add(granted);
        _log.fine('[${session.clientId}] SUBSCRIBE $filter (QoS $granted)');

        // Send retained messages for this filter
        for (final retained in persistence.getRetained(filter)) {
          session.send(buildPublish(
            retained.topic,
            retained.payload,
            qos: retained.qos > granted ? granted : retained.qos,
            retain: true,
            packetId: retained.qos > 0 ? session.nextPacketId : null,
          ));
        }
      } else {
        grantedQos.add(0x80); // Failure
      }
    }

    session.send(buildSuback(packetId, grantedQos));
  }

  // ─── UNSUBSCRIBE ──────────────────────────────────────────────────────────

  void _handleUnsubscribe(MqttPacket packet, MqttSession session) {
    session.touch();
    final data = packet.payload;

    final packetId = (data[0] << 8) | data[1];
    var offset = 2;

    while (offset < data.length) {
      final (filter, newOffset) = readMqttString(data, offset);
      offset = newOffset;
      session.subscriptions.remove(filter);
      session.subscriptionQos.remove(filter);
      _log.fine('[${session.clientId}] UNSUBSCRIBE $filter');
    }

    session.send(buildUnsuback(packetId));
  }

  // ─── Message Routing ─────────────────────────────────────────────────────

  void _routeMessage(String topic, Uint8List message,
      {int qos = 0, String? senderClientId}) {
    for (final session in _sessions.values) {
      if (!session.connected) continue;

      for (final filter in session.subscriptions) {
        if (topicMatches(filter, topic)) {
          final subQos = session.subscriptionQos[filter] ?? 0;
          final effectiveQos = qos > subQos ? subQos : qos;
          session.send(buildPublish(
            topic,
            message,
            qos: effectiveQos,
            packetId: effectiveQos > 0 ? session.nextPacketId : null,
          ));
          break; // Don't send duplicate if multiple filters match
        }
      }
    }
  }

  // ─── Session Cleanup ──────────────────────────────────────────────────────

  void _removeSession(MqttSession? session) {
    if (session == null) return;
    session.disconnect();
    _sessions.remove(session.clientId);
    _log.fine('[${session.clientId}] Session removed');
  }

  // ─── Broker Management ────────────────────────────────────────────────────

  /// Publish a message as the broker (e.g. system notifications).
  void brokerPublish(String topic, Map<String, dynamic> payload,
      {int qos = 0, bool retain = false}) {
    final message = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    if (retain) persistence.setRetained(topic, message, qos: qos);
    _routeMessage(topic, message, qos: qos);
  }

  /// Get broker status.
  Map<String, dynamic> getStatus() => {
        'uptime_seconds': DateTime.now().difference(_startTime).inSeconds,
        'connected_clients': _sessions.length,
        'total_connections': _totalConnections,
        'total_messages': _totalMessages,
        'retained_messages': persistence.count,
        'active_sessions': _sessions.values
            .where((s) => s.connected)
            .map((s) => {
                  'clientId': s.clientId,
                  'transport': s.transportLabel,
                  'subscriptions': s.subscriptions.toList(),
                  'lastActivity': s.lastActivity.toIso8601String(),
                })
            .toList(),
      };

  Future<void> stop() async {
    for (final session in _sessions.values.toList()) {
      session.disconnect();
    }
    _sessions.clear();
    await _tcpServer?.close();
    await _wsServer?.close();
    _log.info('Broker stopped.');
  }
}
