import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/models/device_model.dart';

class DeviceCard extends StatefulWidget {
  final SmartDevice device;
  final int index;
  final VoidCallback onToggle;
  final ValueChanged<double>? onBrightnessChange;
  final ValueChanged<double>? onSpeedChange;
  final ValueChanged<double>? onTemperatureChange;

  const DeviceCard({
    super.key,
    required this.device,
    required this.index,
    required this.onToggle,
    this.onBrightnessChange,
    this.onSpeedChange,
    this.onTemperatureChange,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + widget.index * 80),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final color = device.type.color;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () => _showDeviceDetail(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: device.isOn
                ? color.withOpacity(0.1)
                : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: device.isOn
                  ? color.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: device.isOn
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: device.isOn
                          ? color.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      device.type.icon,
                      color: device.isOn ? color : Colors.white30,
                      size: 24,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 28,
                      decoration: BoxDecoration(
                        color: device.isOn
                            ? color
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: device.isOn
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Device Name
              Text(
                device.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: device.isOn ? Colors.white : Colors.white54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Room
              Text(
                device.room,
                style: TextStyle(
                  fontSize: 11,
                  color: device.isOn
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white.withOpacity(0.3),
                ),
              ),

              const SizedBox(height: 8),

              // Slider for controllable devices
              if (device.type.hasSlider && device.isOn) ...[
                _buildControlSlider(device, color),
              ] else ...[
                // Status indicator
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: device.isOn
                            ? AppTheme.successColor
                            : Colors.white24,
                        shape: BoxShape.circle,
                        boxShadow: device.isOn
                            ? [
                                BoxShadow(
                                  color: AppTheme.successColor.withOpacity(0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      device.isOn ? 'Active' : 'Off',
                      style: TextStyle(
                        fontSize: 11,
                        color: device.isOn
                            ? AppTheme.successColor
                            : Colors.white24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlSlider(SmartDevice device, Color color) {
    double value;
    double min, max;
    String label;

    switch (device.type) {
      case DeviceType.light:
        value = device.brightness ?? 50;
        min = 0;
        max = 100;
        label = '${value.toInt()}%';
        break;
      case DeviceType.fan:
        value = device.speed ?? 1;
        min = 1;
        max = 5;
        label = 'Speed ${value.toInt()}';
        break;
      case DeviceType.ac:
      case DeviceType.thermostat:
        value = device.temperature ?? 24;
        min = 16;
        max = 30;
        label = '${value.toInt()}°C';
        break;
      case DeviceType.speaker:
        value = device.brightness ?? 50;
        min = 0;
        max = 100;
        label = '${value.toInt()}%';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.1),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: (v) {
              switch (device.type) {
                case DeviceType.light:
                case DeviceType.speaker:
                  widget.onBrightnessChange?.call(v);
                  break;
                case DeviceType.fan:
                  widget.onSpeedChange?.call(v);
                  break;
                case DeviceType.ac:
                case DeviceType.thermostat:
                  widget.onTemperatureChange?.call(v);
                  break;
                default:
                  break;
              }
            },
          ),
        ),
      ],
    );
  }

  void _showDeviceDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _DeviceDetailSheet(device: widget.device),
    );
  }
}

class _DeviceDetailSheet extends StatelessWidget {
  final SmartDevice device;

  const _DeviceDetailSheet({required this.device});

  @override
  Widget build(BuildContext context) {
    final color = device.type.color;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Device Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(device.type.icon, color: color, size: 40),
          ),
          const SizedBox(height: 16),

          Text(
            device.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${device.room} • ${device.type.displayName}',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
          ),

          const SizedBox(height: 30),

          // Device Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildInfoRow('Status', device.isOn ? 'Active' : 'Inactive',
                    device.isOn ? AppTheme.successColor : Colors.white38),
                _buildInfoRow('Connection', device.isOnline ? 'Online' : 'Offline',
                    device.isOnline ? AppTheme.successColor : AppTheme.errorColor),
                _buildInfoRow('Last Updated', _formatTime(device.lastUpdated), Colors.white54),
                if (device.brightness != null)
                  _buildInfoRow('Brightness', '${device.brightness!.toInt()}%', color),
                if (device.speed != null)
                  _buildInfoRow('Speed', 'Level ${device.speed!.toInt()}', color),
                if (device.temperature != null)
                  _buildInfoRow('Temperature', '${device.temperature!.toInt()}°C', color),
              ],
            ),
          ),

          const Spacer(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkCard,
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
