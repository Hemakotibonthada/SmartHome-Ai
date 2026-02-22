# Architecture

> **SmartHome AI** — A product of **Circuvent Technologies Pvt Ltd**, Hyderabad

## System Overview

SmartHome AI follows a **layered architecture** combining a cross-platform Flutter frontend with ESP32 IoT hardware, connected through Firebase and MQTT.

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │   Auth    │  │Dashboard │  │ Devices  │  │  Analytics │  │
│  │  Module   │  │  Module  │  │  Module  │  │   Module   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬──────┘  │
│       │              │             │               │         │
│  ┌────┴──────────────┴─────────────┴───────────────┴──────┐  │
│  │               Provider (State Management)              │  │
│  └────┬──────────────┬─────────────┬───────────────┬──────┘  │
│       │              │             │               │         │
│  ┌────┴──────────────┴─────────────┴───────────────┴──────┐  │
│  │                  Core Services Layer                    │  │
│  │  DeviceService │ AIService │ EnergyService │ ...       │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │ Firebase │  │   MQTT   │  │   HTTP   │
        │Auth/DB/  │  │  Broker  │  │   APIs   │
        │Messaging │  │          │  │          │
        └──────────┘  └─────┬────┘  └──────────┘
                            │
                      ┌─────┴─────┐
                      │   ESP32   │
                      │  Firmware │
                      │ (Sensors  │
                      │+ Relays)  │
                      └───────────┘
```

## Project Structure

```
SmartHome-Ai/
├── lib/                          # Flutter application source
│   ├── main.dart                 # App entry point
│   ├── core/                     # Shared core logic
│   │   ├── models/               # Data models
│   │   │   ├── device_model.dart    # SmartDevice, DeviceType, Room
│   │   │   ├── sensor_data.dart     # SensorData, SensorType
│   │   │   └── user_model.dart      # AppUser, AIInsight, UserRole
│   │   ├── providers/
│   │   │   └── app_providers.dart   # 14 providers via MultiProvider
│   │   ├── services/             # Business logic layer
│   │   │   ├── device_service.dart           # Device CRUD & simulation
│   │   │   ├── ai_service.dart               # AI analytics & predictions
│   │   │   ├── advanced_home_service.dart    # 11 smart device categories
│   │   │   ├── smart_features_service.dart   # Scenes, routines, schedules
│   │   │   ├── security_lifestyle_service.dart # Security & lifestyle
│   │   │   ├── energy_analytics_service.dart # Energy, solar, water
│   │   │   └── notification_service.dart     # Push notifications
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Material 3 dark/light themes
│   │   └── utils/
│   │       └── responsive.dart      # Responsive breakpoints
│   ├── features/                 # Feature modules
│   │   ├── activity/             # Activity timeline log
│   │   ├── admin/                # Admin panel (6 screens + provider)
│   │   ├── analytics/            # AI hub, security dashboard, system mgmt
│   │   ├── auth/                 # Login, splash, auth provider
│   │   ├── dashboard/            # Main dashboard + 5 widgets
│   │   ├── devices/              # Device management & control
│   │   ├── energy/               # Energy analytics hub
│   │   ├── export/               # Data export & reports
│   │   ├── home/                 # Home shell (web sidebar + mobile nav)
│   │   ├── landing/              # Marketing landing page
│   │   ├── maintenance/          # Maintenance task tracker
│   │   ├── notifications/        # Notification center
│   │   ├── rooms/                # Room-by-room management
│   │   ├── safety/               # Safety & emergency controls
│   │   ├── scenes/               # Scene & routine automation
│   │   ├── sensors/              # Sensor monitoring & charts
│   │   ├── settings/             # User settings & preferences
│   │   └── suggestions/          # AI-powered suggestions
│   └── shared/                   # Shared UI components
│       ├── painters/             # Custom painters (gauges, waves)
│       └── widgets/              # Reusable widgets (glass card, shimmer)
├── esp32/                        # ESP32 microcontroller firmware
│   ├── platformio.ini            # PlatformIO configuration
│   └── smart_home_esp32/
│       ├── config.h              # Hardware & network config
│       └── smart_home_esp32.ino  # Main firmware source
├── assets/                       # Static assets
│   ├── animations/               # Lottie animation files
│   ├── fonts/                    # Custom font files
│   ├── icons/                    # App icons
│   └── images/                   # Image assets
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── web/                          # Web platform files
├── docs/                         # Documentation
└── pubspec.yaml                  # Flutter dependencies
```

## Design Patterns

### 1. Provider Pattern (State Management)

The app uses **Provider** with `MultiProvider` at the root. All 14 providers are registered in `app_providers.dart`:

```dart
class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(create: (_) => DeviceProvider()),
    ChangeNotifierProvider(create: (_) => SensorProvider()),
    ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
    ChangeNotifierProvider(create: (_) => AdminProvider()),
    ChangeNotifierProvider(create: (_) => DeviceService()),
    ChangeNotifierProvider(create: (_) => AIService()),
    ChangeNotifierProvider(create: (_) => AdvancedHomeService()),
    ChangeNotifierProvider(create: (_) => SmartFeaturesService()),
    ChangeNotifierProvider(create: (_) => SecurityLifestyleService()),
    ChangeNotifierProvider(create: (_) => EnergyAnalyticsService()),
    ChangeNotifierProvider(create: (_) => NotificationService()),
  ];
}
```

### 2. Feature-First Module Structure

Each feature is self-contained with its own:
- `screens/` — UI pages
- `providers/` — State management (where needed)
- `widgets/` — Feature-specific components

### 3. Service Layer Pattern

Core services encapsulate business logic and data simulation:
- **DeviceService** — Device lifecycle, sensor data generation
- **AIService** — Anomaly detection, pattern recognition, predictions
- **AdvancedHomeService** — Smart appliance management (11 categories)
- **SmartFeaturesService** — Automation, scenes, scheduling
- **SecurityLifestyleService** — Security cameras, sleep, weather
- **EnergyAnalyticsService** — Cost tracking, solar, water usage

### 4. Responsive Design

The app adapts to three form factors using `Responsive` utility:

| Breakpoint | Layout |
|---|---|
| `< 600px` | Mobile — Bottom navigation bar |
| `600px – 1200px` | Tablet — Collapsible sidebar |
| `> 1200px` | Desktop — Full sidebar + top bar |

The `HomeScreen` uses `WebShell` for desktop/tablet and `MobileShell` for mobile.

## Data Flow

```
User Action → Widget → Provider.method()
                            │
                     Service Layer
                     (simulation / API)
                            │
                     notifyListeners()
                            │
                     Consumer<Provider>
                            │
                      Widget rebuilds
```

### ESP32 Data Flow

```
Sensor Reading → ESP32 → MQTT Publish
                              │
                    MQTT Broker (Mosquitto)
                              │
                    Flutter App subscribes
                              │
                    DeviceService updates
                              │
                    Dashboard displays
```

## Key Models

### SmartDevice
```dart
class SmartDevice {
  String id, name, type, room;
  bool isOnline, isOn;
  double value;
  Map<String, dynamic> properties;
  DateTime lastUpdated;
}
```

### SensorData
```dart
class SensorData {
  String id, deviceId, sensorType;
  double value;
  String unit;
  DateTime timestamp;
}
```

### AppUser
```dart
class AppUser {
  String id, name, email;
  UserRole role;           // admin, user, guest
  List<AIInsight> insights;
}
```

## Navigation Architecture

```
SplashScreen → LoginScreen → HomeScreen
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
              MobileShell   WebShell    LandingPage
              (BottomNav)  (Sidebar)   (Marketing)
                    │            │
              ┌─────┴─────┐     │
              │ PageView   │     │
              │ Dashboard  │     │
              │ Devices    │  Same pages
              │ Analytics  │  rendered in
              │ Settings   │  sidebar shell
              └────────────┘
```

## Security Considerations

- Firebase Authentication for user identity
- Role-based access control (Admin, User, Guest)
- MQTT credentials for ESP32 communication
- No hardcoded secrets in source (config.h template)
- OTA firmware updates with authentication

---

*See [API Reference](API_REFERENCE.md) for detailed service documentation.*
