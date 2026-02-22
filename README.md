# Smart Home AI - IoT Home Automation Platform

A comprehensive AI-powered IoT Smart Home application built with **Flutter** (iOS, Android, Web) and **ESP32** microcontroller firmware.

## Features

### Sensor Monitoring
- **Temperature & Humidity** — DHT22 sensor with real-time charts
- **Voltage & Current** — PZEM-004T AC power monitoring (V, A, W, kWh, PF, Hz)
- **Water Tank Level** — HC-SR04 ultrasonic sensor with animated wave visualization
- **Gas Detection** — MQ-2/MQ-5 analog gas sensor with auto-safety shutoff
- **Motion Detection** — PIR sensor for security
- **Light Level** — LDR ambient light sensing

### Device Control
- 4-channel relay control (Light, Fan, AC, Water Pump)
- Buzzer alarm system (beep, siren patterns)
- Brightness dimming & fan speed control
- Room-based device organization
- Device scheduling

### AI Analytics
- **Trend Prediction** — Linear regression forecasting
- **Anomaly Detection** — Standard deviation-based outlier detection
- **Energy Analysis** — Consumption reports, efficiency scoring, carbon footprint
- **Smart Insights** — Comfort, safety, maintenance, and savings suggestions
- **Usage Patterns** — Peak hours, daily/weekly/monthly trends

### Admin Dashboard
- System health monitoring (CPU, memory, disk, network)
- User activity tracking
- Device network status (online/offline pie chart)
- System logs with severity filtering
- Quick actions (firmware update, backup, restart)

### UI/UX
- Dark & Light theme with Material 3
- Custom animated painters (water tank waves, gauge arcs, sparklines)
- Staggered entry animations throughout
- Glassmorphism card design
- Responsive layout for mobile & web

## Architecture

```
SmartHome-Ai/
├── lib/                          # Flutter Application
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── theme/                # Theme system
│   │   ├── models/               # Data models
│   │   ├── services/             # Business logic
│   │   └── providers/            # Provider registration
│   ├── features/
│   │   ├── auth/                 # Login, Register, Splash
│   │   ├── home/                 # Navigation shell
│   │   ├── dashboard/            # Main dashboard + widgets
│   │   ├── sensors/              # Sensor monitoring
│   │   ├── devices/              # Device control
│   │   ├── analytics/            # AI analytics
│   │   ├── admin/                # Admin dashboard
│   │   ├── settings/             # App settings
│   │   └── notifications/        # Alert notifications
│   └── shared/                   # Shared widgets & painters
├── esp32/                        # ESP32 Firmware
│   ├── smart_home_esp32/
│   │   ├── smart_home_esp32.ino  # Main firmware
│   │   └── config.h              # Configuration
│   ├── platformio.ini            # PlatformIO config
│   └── README.md                 # Hardware setup guide
└── pubspec.yaml                  # Flutter dependencies
```

## Getting Started

### Flutter App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

### ESP32 Firmware

1. Install **Arduino IDE** or **PlatformIO**
2. Install required libraries (see [esp32/README.md](esp32/README.md))
3. Edit `esp32/smart_home_esp32/config.h` with your WiFi and MQTT settings
4. Upload to ESP32

### MQTT Broker

Install Mosquitto or use a cloud MQTT broker:

```bash
# Ubuntu/Debian
sudo apt install mosquitto mosquitto-clients

# Start broker
sudo systemctl start mosquitto
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile/Web | Flutter 3.x + Dart |
| State Management | Provider |
| Charts | fl_chart |
| IoT Device | ESP32 (Arduino/C++) |
| Communication | MQTT (PubSubClient) |
| Sensors | DHT22, PZEM-004T, HC-SR04, PIR, MQ-2, LDR |
| Actuators | 4-channel relay, piezo buzzer |

## Dependencies

### Flutter
- `provider` — State management
- `fl_chart` — Charts & graphs
- `google_fonts` — Typography
- `flutter_animate` — Declarative animations
- `lottie` — Lottie animations
- `shimmer` — Loading effects
- `syncfusion_flutter_gauges` — Gauge widgets
- `mqtt_client` — MQTT connectivity
- `web_socket_channel` — WebSocket support
- `rxdart` — Reactive streams

### ESP32
- `PubSubClient` — MQTT client
- `ArduinoJson` — JSON serialization
- `DHT sensor library` — Temperature/humidity
- `PZEM-004T-v30` — AC power monitoring
- `ArduinoOTA` — Over-the-air updates

## Company

**Circuvent Technologies Pvt Ltd**
Hyderabad, India

## License

MIT License
