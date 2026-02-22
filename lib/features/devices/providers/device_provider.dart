import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/device_model.dart';
import 'package:smart_home_ai/core/services/device_service.dart';
import 'package:smart_home_ai/core/services/mqtt_service.dart';

class DeviceProvider extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  MqttService? _mqttService;
  StreamSubscription? _mqttDeviceSub;

  List<SmartDevice> _devices = [];
  List<Room> _rooms = [];
  String _selectedRoom = 'All';
  bool _isLoading = true;
  bool _demoMode = false;

  List<SmartDevice> get devices => _selectedRoom == 'All'
      ? _devices
      : _devices.where((d) => d.room == _selectedRoom).toList();
  List<SmartDevice> get allDevices => _devices;
  List<Room> get rooms => _rooms;
  String get selectedRoom => _selectedRoom;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _demoMode;

  /// Whether there is any data to show
  bool get hasData => _devices.isNotEmpty;

  int get activeCount => _devices.where((d) => d.isOn).length;
  int get totalCount => _devices.length;

  DeviceProvider();

  /// Link the MQTT service for live device data.
  void setMqttService(MqttService service) {
    _mqttService = service;
    _mqttDeviceSub?.cancel();
    _mqttDeviceSub = service.deviceStatusStream.listen((_) {
      if (!_demoMode) {
        _devices = service.liveDevices;
        _rooms = _buildRoomsFromDevices();
        notifyListeners();
      }
    });
  }

  List<Room> _buildRoomsFromDevices() {
    final roomNames = _devices.map((d) => d.room).toSet();
    return roomNames.map((name) => Room(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      icon: Icons.room,
      color: Colors.blueAccent,
      deviceIds: _devices.where((d) => d.room == name).map((d) => d.id).toList(),
    )).toList();
  }

  /// Called when demo mode changes.
  void setDemoMode(bool value) {
    _demoMode = value;
    _deviceService.setDemoMode(value);
    if (value) {
      loadDevices();
    } else {
      // In live mode, load from MQTT if available
      if (_mqttService != null && _mqttService!.liveDevices.isNotEmpty) {
        _devices = _mqttService!.liveDevices;
        _rooms = _buildRoomsFromDevices();
      } else {
        _devices = [];
        _rooms = [];
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDevices() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (_demoMode) {
      _devices = _deviceService.getDevices();
      _rooms = _deviceService.getRooms();
    } else {
      // Live mode: no simulated devices
      _devices = [];
      _rooms = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedRoom(String room) {
    _selectedRoom = room;
    notifyListeners();
  }

  void toggleDevice(String deviceId) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].isOn = !_devices[index].isOn;
      // Send command via MQTT in live mode
      if (!_demoMode && _mqttService != null) {
        final name = _devices[index].name.toLowerCase().replaceAll(' ', '_');
        _mqttService!.toggleDevice(name);
      }
      notifyListeners();
    }
  }

  void updateBrightness(String deviceId, double value) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].brightness = value;
      if (!_demoMode && _mqttService != null) {
        _mqttService!.setLightBrightness(value.toInt());
      }
      notifyListeners();
    }
  }

  void updateSpeed(String deviceId, double value) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].speed = value;
      if (!_demoMode && _mqttService != null) {
        _mqttService!.setFanSpeed(value.toInt());
      }
      notifyListeners();
    }
  }

  void updateTemperature(String deviceId, double value) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index].temperature = value;
      notifyListeners();
    }
  }

  List<String> get roomNames {
    final names = _devices.map((d) => d.room).toSet().toList();
    names.insert(0, 'All');
    return names;
  }
}
