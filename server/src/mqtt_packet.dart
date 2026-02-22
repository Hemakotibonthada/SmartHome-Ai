part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MQTT v3.1.1 Packet Parser / Builder
// ──────────────────────────────────────────────────────────────────────────────

/// Control packet types (upper 4 bits of byte 0).
class MqttPacketType {
  static const int connect     = 1;
  static const int connack     = 2;
  static const int publish     = 3;
  static const int puback      = 4;
  static const int pubrec      = 5;
  static const int pubrel      = 6;
  static const int pubcomp     = 7;
  static const int subscribe   = 8;
  static const int suback      = 9;
  static const int unsubscribe = 10;
  static const int unsuback    = 11;
  static const int pingreq     = 12;
  static const int pingresp    = 13;
  static const int disconnect  = 14;
}

/// A parsed MQTT packet.
class MqttPacket {
  final int type;
  final int flags;
  final Uint8List payload;

  MqttPacket(this.type, this.flags, this.payload);

  bool get isDup     => (flags & 0x08) != 0;
  int  get qos       => (flags >> 1) & 0x03;
  bool get isRetain  => (flags & 0x01) != 0;

  @override
  String toString() => 'MqttPacket(type=$type, flags=$flags, len=${payload.length})';
}

/// Accumulates bytes from a socket and yields complete [MqttPacket]s.
class MqttPacketDecoder {
  final _buffer = BytesBuilder(copy: false);

  /// Feed raw bytes; returns zero or more complete packets.
  List<MqttPacket> add(Uint8List data) {
    _buffer.add(data);
    final packets = <MqttPacket>[];

    while (true) {
      final bytes = _buffer.toBytes();
      if (bytes.isEmpty) break;

      // Need at least 2 bytes (fixed header)
      if (bytes.length < 2) break;

      final byte0 = bytes[0];
      final type = (byte0 >> 4) & 0x0F;
      final flags = byte0 & 0x0F;

      // Decode remaining length (variable-length encoding)
      int multiplier = 1;
      int value = 0;
      int index = 1;
      bool complete = false;

      while (index < bytes.length) {
        final encodedByte = bytes[index];
        value += (encodedByte & 0x7F) * multiplier;
        multiplier *= 128;
        index++;
        if ((encodedByte & 0x80) == 0) {
          complete = true;
          break;
        }
        if (multiplier > 128 * 128 * 128) break; // malformed
      }

      if (!complete) break; // incomplete length
      if (bytes.length < index + value) break; // incomplete payload

      final payload = Uint8List.fromList(bytes.sublist(index, index + value));
      packets.add(MqttPacket(type, flags, payload));

      // Remove consumed bytes
      final remaining = bytes.sublist(index + value);
      _buffer.clear();
      if (remaining.isNotEmpty) _buffer.add(remaining);
    }

    return packets;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Packet builders (broker → client)
// ──────────────────────────────────────────────────────────────────────────────

Uint8List _buildFixedHeader(int type, int flags, int remainingLength) {
  final header = <int>[((type & 0x0F) << 4) | (flags & 0x0F)];
  var len = remainingLength;
  do {
    var encodedByte = len % 128;
    len = len ~/ 128;
    if (len > 0) encodedByte |= 0x80;
    header.add(encodedByte);
  } while (len > 0);
  return Uint8List.fromList(header);
}

Uint8List buildConnack(int returnCode, {bool sessionPresent = false}) {
  final payload = Uint8List.fromList([sessionPresent ? 0x01 : 0x00, returnCode]);
  return Uint8List.fromList([
    ..._buildFixedHeader(MqttPacketType.connack, 0, payload.length),
    ...payload,
  ]);
}

Uint8List buildSuback(int packetId, List<int> grantedQos) {
  final payload = <int>[
    (packetId >> 8) & 0xFF,
    packetId & 0xFF,
    ...grantedQos,
  ];
  return Uint8List.fromList([
    ..._buildFixedHeader(MqttPacketType.suback, 0, payload.length),
    ...payload,
  ]);
}

Uint8List buildUnsuback(int packetId) {
  final payload = Uint8List.fromList([
    (packetId >> 8) & 0xFF,
    packetId & 0xFF,
  ]);
  return Uint8List.fromList([
    ..._buildFixedHeader(MqttPacketType.unsuback, 0, payload.length),
    ...payload,
  ]);
}

Uint8List buildPublish(String topic, Uint8List message,
    {int qos = 0, bool retain = false, int? packetId}) {
  final topicBytes = utf8.encode(topic);
  final payload = BytesBuilder();
  payload.addByte((topicBytes.length >> 8) & 0xFF);
  payload.addByte(topicBytes.length & 0xFF);
  payload.add(topicBytes);
  if (qos > 0 && packetId != null) {
    payload.addByte((packetId >> 8) & 0xFF);
    payload.addByte(packetId & 0xFF);
  }
  payload.add(message);

  int flags = 0;
  if (retain) flags |= 0x01;
  flags |= ((qos & 0x03) << 1);

  final body = payload.toBytes();
  return Uint8List.fromList([
    ..._buildFixedHeader(MqttPacketType.publish, flags, body.length),
    ...body,
  ]);
}

Uint8List buildPuback(int packetId) {
  return Uint8List.fromList([
    ..._buildFixedHeader(MqttPacketType.puback, 0, 2),
    (packetId >> 8) & 0xFF,
    packetId & 0xFF,
  ]);
}

Uint8List buildPingresp() {
  return Uint8List.fromList([
    ..._buildFixedHeader(MqttPacketType.pingresp, 0, 0),
  ]);
}

// ──────────────────────────────────────────────────────────────────────────────
// Payload readers
// ──────────────────────────────────────────────────────────────────────────────

/// Read a UTF-8 string from payload at [offset]. Returns (string, newOffset).
(String, int) readMqttString(Uint8List data, int offset) {
  final len = (data[offset] << 8) | data[offset + 1];
  final str = utf8.decode(data.sublist(offset + 2, offset + 2 + len));
  return (str, offset + 2 + len);
}

/// Parse a CONNECT packet payload.
class ConnectPayload {
  final String protocolName;
  final int protocolLevel;
  final int connectFlags;
  final int keepAlive;
  final String clientId;
  final String? willTopic;
  final Uint8List? willMessage;
  final String? username;
  final String? password;

  ConnectPayload._({
    required this.protocolName,
    required this.protocolLevel,
    required this.connectFlags,
    required this.keepAlive,
    required this.clientId,
    this.willTopic,
    this.willMessage,
    this.username,
    this.password,
  });

  bool get hasUsername  => (connectFlags & 0x80) != 0;
  bool get hasPassword  => (connectFlags & 0x40) != 0;
  bool get willRetain   => (connectFlags & 0x20) != 0;
  int  get willQos      => (connectFlags >> 3) & 0x03;
  bool get hasWill      => (connectFlags & 0x04) != 0;
  bool get cleanSession => (connectFlags & 0x02) != 0;

  factory ConnectPayload.parse(Uint8List data) {
    var offset = 0;
    final (protocolName, o1) = readMqttString(data, offset);
    offset = o1;
    final protocolLevel = data[offset++];
    final connectFlags = data[offset++];
    final keepAlive = (data[offset] << 8) | data[offset + 1];
    offset += 2;

    final (clientId, o2) = readMqttString(data, offset);
    offset = o2;

    String? willTopic;
    Uint8List? willMessage;
    if ((connectFlags & 0x04) != 0) {
      final (wt, o3) = readMqttString(data, offset);
      willTopic = wt;
      offset = o3;
      final wmLen = (data[offset] << 8) | data[offset + 1];
      offset += 2;
      willMessage = data.sublist(offset, offset + wmLen);
      offset += wmLen;
    }

    String? username;
    if ((connectFlags & 0x80) != 0) {
      final (u, o4) = readMqttString(data, offset);
      username = u;
      offset = o4;
    }

    String? password;
    if ((connectFlags & 0x40) != 0) {
      final (p, o5) = readMqttString(data, offset);
      password = p;
      offset = o5;
    }

    return ConnectPayload._(
      protocolName: protocolName,
      protocolLevel: protocolLevel,
      connectFlags: connectFlags,
      keepAlive: keepAlive,
      clientId: clientId,
      willTopic: willTopic,
      willMessage: willMessage,
      username: username,
      password: password,
    );
  }
}
