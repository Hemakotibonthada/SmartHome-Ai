part of '../bin/server.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Simple username/password authentication for MQTT clients
// ──────────────────────────────────────────────────────────────────────────────

class MqttAuth {
  final Map<String, String> _users = {}; // username → hashed password
  bool allowAnonymous = false;

  /// Register a user. Password is stored as SHA-256 hex.
  void addUser(String username, String password) {
    _users[username] = _hashPassword(password);
  }

  /// Remove a user.
  void removeUser(String username) => _users.remove(username);

  /// Validate credentials. Returns true if login succeeds.
  bool authenticate(String? username, String? password) {
    if (username == null || password == null) return allowAnonymous;
    final hash = _users[username];
    if (hash == null) return allowAnonymous;
    return hash == _hashPassword(password);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return crypto.sha256.convert(bytes).toString();
  }

  int get userCount => _users.length;
}
