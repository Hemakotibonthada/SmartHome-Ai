part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Retained Message Persistence — stores retained messages in memory
// (can be extended to file-based or database persistence)
// ──────────────────────────────────────────────────────────────────────────────

class RetainedMessage {
  final String topic;
  final Uint8List payload;
  final int qos;
  final DateTime timestamp;

  RetainedMessage({
    required this.topic,
    required this.payload,
    this.qos = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class MqttPersistence {
  final Map<String, RetainedMessage> _retained = {};

  /// Store a retained message. Empty payload clears retention.
  void setRetained(String topic, Uint8List payload, {int qos = 0}) {
    if (payload.isEmpty) {
      _retained.remove(topic);
    } else {
      _retained[topic] = RetainedMessage(topic: topic, payload: payload, qos: qos);
    }
  }

  /// Get all retained messages matching a subscription filter.
  List<RetainedMessage> getRetained(String filter) {
    return _retained.values
        .where((msg) => topicMatches(filter, msg.topic))
        .toList();
  }

  /// Get a specific retained message.
  RetainedMessage? getRetainedTopic(String topic) => _retained[topic];

  int get count => _retained.length;
}
