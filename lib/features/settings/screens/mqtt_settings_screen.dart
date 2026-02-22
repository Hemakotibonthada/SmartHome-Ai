import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/mqtt_service.dart';
import 'package:smart_home_ai/core/models/mqtt_models.dart';

/// Full-featured MQTT Settings screen — configure broker, test connection,
/// view live status, connected nodes, and recent messages.
class MqttSettingsScreen extends StatefulWidget {
  const MqttSettingsScreen({super.key});

  @override
  State<MqttSettingsScreen> createState() => _MqttSettingsScreenState();
}

class _MqttSettingsScreenState extends State<MqttSettingsScreen> {
  late TextEditingController _brokerController;
  late TextEditingController _tcpPortController;
  late TextEditingController _wsPortController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _clientIdController;
  bool _useWebSocket = false;
  bool _autoReconnect = true;
  bool _isTesting = false;
  bool? _testResult;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    final mqtt = context.read<MqttService>();
    _brokerController = TextEditingController(text: mqtt.config.broker);
    _tcpPortController = TextEditingController(text: mqtt.config.tcpPort.toString());
    _wsPortController = TextEditingController(text: mqtt.config.wsPort.toString());
    _usernameController = TextEditingController(text: mqtt.config.username);
    _passwordController = TextEditingController(text: mqtt.config.password);
    _clientIdController = TextEditingController(text: mqtt.config.clientId);
    _useWebSocket = mqtt.config.useWebSocket;
    _autoReconnect = mqtt.config.autoReconnect;
  }

  @override
  void dispose() {
    _brokerController.dispose();
    _tcpPortController.dispose();
    _wsPortController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  MqttConfig _buildConfig() => MqttConfig(
        broker: _brokerController.text.trim(),
        tcpPort: int.tryParse(_tcpPortController.text) ?? 1883,
        wsPort: int.tryParse(_wsPortController.text) ?? 8083,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        clientId: _clientIdController.text.trim(),
        useWebSocket: _useWebSocket,
        autoReconnect: _autoReconnect,
      );

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });
    final mqtt = context.read<MqttService>();
    final ok = await mqtt.testConnection(_buildConfig());
    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = ok;
      });
    }
  }

  Future<void> _saveAndConnect() async {
    final mqtt = context.read<MqttService>();
    await mqtt.saveConfig(_buildConfig());
    await mqtt.disconnect();
    await mqtt.connect();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mqtt.isConnected ? 'Connected to MQTT broker' : 'Saved. Connecting...',
          ),
          backgroundColor: mqtt.isConnected ? AppTheme.successColor : AppTheme.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'MQTT Settings',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Spacer(),
                      _buildConnectionBadge(mqtt.connectionState),
                    ],
                  ),
                ),
              ),

              // ── Connection Status Card ─────────────────────────────
              SliverToBoxAdapter(child: _buildStatusCard(mqtt)),

              // ── Broker Configuration ──────────────────────────────
              SliverToBoxAdapter(child: _buildSection('Broker Configuration', [
                _buildTextField('Broker Address', _brokerController, Icons.dns, 'e.g. 192.168.1.100'),
                const Divider(color: Colors.white10, height: 1),
                Row(
                  children: [
                    Expanded(child: _buildTextField('TCP Port', _tcpPortController, Icons.lan, '1883', isNumber: true)),
                    Container(width: 1, height: 50, color: Colors.white10),
                    Expanded(child: _buildTextField('WS Port', _wsPortController, Icons.language, '8083', isNumber: true)),
                  ],
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildTextField('Username', _usernameController, Icons.person, 'smarthome'),
                const Divider(color: Colors.white10, height: 1),
                _buildPasswordField(),
                const Divider(color: Colors.white10, height: 1),
                _buildTextField('Client ID', _clientIdController, Icons.fingerprint, 'flutter_app'),
              ])),

              // ── Connection Options ────────────────────────────────
              SliverToBoxAdapter(child: _buildSection('Connection Options', [
                _buildSwitchTile(
                  'Use WebSocket',
                  'For Flutter Web (ws:// instead of tcp://)',
                  Icons.language,
                  _useWebSocket,
                  (v) => setState(() => _useWebSocket = v),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildSwitchTile(
                  'Auto Reconnect',
                  'Reconnect on connection loss',
                  Icons.autorenew,
                  _autoReconnect,
                  (v) => setState(() => _autoReconnect = v),
                ),
              ])),

              // ── Action Buttons ────────────────────────────────────
              SliverToBoxAdapter(child: _buildActionButtons(mqtt)),

              // ── System Status (from ESP32) ────────────────────────
              if (mqtt.lastSystemStatus != null)
                SliverToBoxAdapter(child: _buildSystemStatusCard(mqtt.lastSystemStatus!)),

              // ── Recent Alerts ─────────────────────────────────────
              if (mqtt.alerts.isNotEmpty)
                SliverToBoxAdapter(child: _buildRecentAlerts(mqtt.alerts)),

              // ── Topic Info ────────────────────────────────────────
              SliverToBoxAdapter(child: _buildTopicInfo()),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildConnectionBadge(AppMqttConnectionState state) {
    final Color color;
    final IconData icon;
    switch (state) {
      case AppMqttConnectionState.connected:
        color = AppTheme.successColor;
        icon = Icons.cloud_done;
        break;
      case AppMqttConnectionState.connecting:
      case AppMqttConnectionState.reconnecting:
        color = AppTheme.warningColor;
        icon = Icons.cloud_sync;
        break;
      case AppMqttConnectionState.error:
        color = AppTheme.errorColor;
        icon = Icons.cloud_off;
        break;
      default:
        color = Colors.white38;
        icon = Icons.cloud_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            state.displayName,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(MqttService mqtt) {
    final isConnected = mqtt.isConnected;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isConnected
                ? [AppTheme.successColor.withValues(alpha: 0.15), AppTheme.successColor.withValues(alpha: 0.05)]
                : [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected ? AppTheme.successColor.withValues(alpha: 0.3) : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppTheme.successColor.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: isConnected ? AppTheme.successColor : Colors.white38,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'Broker Connected' : 'Not Connected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? AppTheme.successColor : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isConnected
                            ? 'Receiving live data from ESP32 nodes'
                            : 'Configure and connect to your MQTT broker',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isConnected && mqtt.lastSensorData != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMiniStat('Devices', '${mqtt.liveDevices.length}', Icons.devices),
                  const SizedBox(width: 12),
                  _buildMiniStat('Sensors', '${mqtt.currentReadings.length}', Icons.sensors),
                  const SizedBox(width: 12),
                  _buildMiniStat('Alerts', '${mqtt.alerts.length}', Icons.warning_amber),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 18),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.lock, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white30,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MqttService mqtt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          // Test Connection Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(
                            _testResult == null ? Icons.wifi_tethering : (_testResult! ? Icons.check_circle : Icons.error),
                            size: 18,
                          ),
                    label: Text(_isTesting ? 'Testing...' : (_testResult == null ? 'Test Connection' : (_testResult! ? 'Connection OK' : 'Failed'))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _testResult == true
                          ? AppTheme.successColor.withValues(alpha: 0.2)
                          : _testResult == false
                              ? AppTheme.errorColor.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.08),
                      foregroundColor: _testResult == true
                          ? AppTheme.successColor
                          : _testResult == false
                              ? AppTheme.errorColor
                              : Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Save & Connect / Disconnect
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saveAndConnect,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save & Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: mqtt.isConnected ? () => mqtt.disconnect() : null,
                  icon: const Icon(Icons.power_settings_new, size: 18),
                  label: const Text('Disconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor.withValues(alpha: 0.15),
                    foregroundColor: AppTheme.errorColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard(MqttSystemStatus status) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'ESP32 System Status',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInfoRow('Device ID', status.deviceId),
                _buildInfoRow('Status', status.status),
                _buildInfoRow('Uptime', status.uptimeFormatted),
                _buildInfoRow('WiFi Signal', '${status.rssi} dBm (${status.signalStrength})'),
                _buildInfoRow('Free Memory', '${(status.freeHeap / 1024).toStringAsFixed(1)} KB'),
                if (status.ip != null) _buildInfoRow('IP Address', status.ip!),
                if (status.firmware != null) _buildInfoRow('Firmware', status.firmware!),
                _buildInfoRow('Reconnects', '${status.reconnects}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts(List<MqttAlert> alerts) {
    final recent = alerts.take(5).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Recent Alerts',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: recent.map((alert) {
                final color = alert.severity == 'critical'
                    ? AppTheme.errorColor
                    : alert.severity == 'warning'
                        ? AppTheme.warningColor
                        : AppTheme.primaryColor;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                            Text(alert.message, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicInfo() {
    const topics = [
      ('smarthome/sensors/data', 'Sensor telemetry (temp, humidity, power...)'),
      ('smarthome/devices/status', 'Relay & device states (retained)'),
      ('smarthome/devices/control', 'Commands from app to ESP32'),
      ('smarthome/alerts', 'Gas, water, temperature alerts'),
      ('smarthome/system', 'Heartbeat & system info (retained)'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'MQTT Topics',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: topics.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.topic, color: AppTheme.primaryColor.withValues(alpha: 0.5), size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70, fontFamily: 'monospace')),
                          Text(t.$2, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
