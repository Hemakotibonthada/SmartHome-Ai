part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MQTT Topic Matching — supports +/# wildcards per MQTT v3.1.1 spec
// ──────────────────────────────────────────────────────────────────────────────

/// Returns true if [topic] matches [filter] (which may contain + and #).
bool topicMatches(String filter, String topic) {
  final filterParts = filter.split('/');
  final topicParts = topic.split('/');

  for (var i = 0; i < filterParts.length; i++) {
    final f = filterParts[i];

    if (f == '#') return true; // matches everything from here on
    if (i >= topicParts.length) return false;
    if (f == '+') continue; // single-level wildcard
    if (f != topicParts[i]) return false;
  }

  return filterParts.length == topicParts.length;
}

/// Returns true if [topic] is a valid publish topic (no wildcards).
bool isValidPublishTopic(String topic) {
  return topic.isNotEmpty && !topic.contains('+') && !topic.contains('#');
}

/// Returns true if [filter] is a valid subscription filter.
bool isValidSubscriptionFilter(String filter) {
  if (filter.isEmpty) return false;
  final parts = filter.split('/');
  for (var i = 0; i < parts.length; i++) {
    final p = parts[i];
    if (p == '#' && i != parts.length - 1) return false; // # must be last
    if (p.contains('+') && p.length > 1) return false;   // + must be alone
    if (p.contains('#') && p.length > 1) return false;
  }
  return true;
}
