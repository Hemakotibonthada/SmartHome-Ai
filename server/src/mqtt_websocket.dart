part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WebSocket Transport — MQTT over WebSocket (for Flutter Web & browsers)
// ──────────────────────────────────────────────────────────────────────────────

extension MqttWebSocket on MqttBroker {
  /// Start an HTTP server that upgrades /mqtt to WebSocket for MQTT traffic.
  Future<void> startWebSocket(int port) async {
    _wsServer = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _wsServer!.listen(_handleWsRequest);
  }

  void _handleWsRequest(HttpRequest request) async {
    // CORS headers for Flutter web
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..set('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      request.response
        ..statusCode = HttpStatus.ok
        ..close();
      return;
    }

    // REST endpoint: GET /status
    if (request.uri.path == '/status' && request.method == 'GET') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(getStatus()))
        ..close();
      return;
    }

    // REST endpoint: POST /publish (broker-initiated publish)
    if (request.uri.path == '/publish' && request.method == 'POST') {
      try {
        final body = await utf8.decodeStream(request);
        final data = jsonDecode(body) as Map<String, dynamic>;
        brokerPublish(
          data['topic'] as String,
          data['payload'] as Map<String, dynamic>,
          retain: data['retain'] == true,
        );
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'status': 'published'}))
          ..close();
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write(jsonEncode({'error': e.toString()}))
          ..close();
      }
      return;
    }

    // WebSocket upgrade for /mqtt path
    if (request.uri.path == '/mqtt' || request.uri.path == '/') {
      try {
        final ws = await WebSocketTransformer.upgrade(
          request,
          protocolSelector: (protocols) {
            if (protocols.contains('mqtt')) return 'mqtt';
            if (protocols.contains('mqttv3.1')) return 'mqttv3.1';
            return null;
          },
        );
        _handleWsConnection(ws, request);
      } catch (e) {
        _log.warning('WebSocket upgrade failed: $e');
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('WebSocket upgrade required')
          ..close();
      }
      return;
    }

    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Not found')
      ..close();
  }

  void _handleWsConnection(WebSocket ws, HttpRequest request) {
    _totalConnections++;
    final remote = '${request.connectionInfo?.remoteAddress.address}:${request.connectionInfo?.remotePort}';
    _log.fine('WebSocket connection from $remote');

    final decoder = MqttPacketDecoder();
    MqttSession? session;

    ws.listen(
      (data) {
        final Uint8List bytes;
        if (data is List<int>) {
          bytes = Uint8List.fromList(data);
        } else if (data is String) {
          bytes = Uint8List.fromList(utf8.encode(data));
        } else {
          return;
        }

        final packets = decoder.add(bytes);
        for (final packet in packets) {
          session = _handlePacket(
            packet,
            session,
            send: (d) {
              if (ws.readyState == WebSocket.open) ws.add(d);
            },
            close: () => ws.close(),
            transport: 'ws',
            remote: remote,
          );
        }
      },
      onError: (e) {
        _log.warning('WebSocket error from $remote: $e');
        _removeSession(session);
      },
      onDone: () {
        _log.fine('WebSocket disconnect from $remote');
        _removeSession(session);
      },
    );
  }
}
