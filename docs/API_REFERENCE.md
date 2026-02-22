# API & Services Reference

This document covers all core services, data models, and providers in SmartHome AI.

---

## Data Models

### SmartDevice (`lib/core/models/device_model.dart`)

Represents a controllable smart home device.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique device identifier |
| `name` | `String` | Display name |
| `type` | `String` | Device type (light, fan, ac, etc.) |
| `room` | `String` | Room location |
| `isOnline` | `bool` | Online/offline status |
| `isOn` | `bool` | Power state |
| `value` | `double` | Current value (brightness, speed, temp) |
| `properties` | `Map<String, dynamic>` | Device-specific metadata |
| `lastUpdated` | `DateTime` | Last state change timestamp |

**DeviceType enum:** `light`, `fan`, `ac`, `thermostat`, `camera`, `lock`, `sensor`, `waterPump`, `plug`, `speaker`, `tv`, `blinds`

**Room model:**

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Room identifier |
| `name` | `String` | Room name |
| `icon` | `IconData` | Display icon |
| `deviceCount` | `int` | Number of devices |
| `temperature` | `double` | Current room temperature |
| `humidity` | `double` | Current humidity |

### SensorData (`lib/core/models/sensor_data.dart`)

Represents a single sensor reading.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Reading identifier |
| `deviceId` | `String` | Source device |
| `sensorType` | `String` | Type of measurement |
| `value` | `double` | Measured value |
| `unit` | `String` | Unit of measurement |
| `timestamp` | `DateTime` | Reading timestamp |

**SensorType enum:** `temperature`, `humidity`, `voltage`, `current`, `power`, `waterLevel`, `motion`, `gasLevel`, `lightLevel`

### AppUser (`lib/core/models/user_model.dart`)

Represents an authenticated user.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | User UID |
| `name` | `String` | Full name |
| `email` | `String` | Email address |
| `role` | `UserRole` | Permission level |
| `insights` | `List<AIInsight>` | AI-generated insights |

**UserRole enum:** `admin`, `user`, `guest`

**AIInsight model:**

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Insight identifier |
| `title` | `String` | Short title |
| `description` | `String` | Detailed description |
| `type` | `String` | Category (energy, security, comfort) |
| `confidence` | `double` | AI confidence score (0–1) |
| `timestamp` | `DateTime` | Generation time |

---

## Core Services

### DeviceService (`lib/core/services/device_service.dart`)

Manages device state, sensor data simulation, and device CRUD operations.

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `initialize()` | `void` | Seeds default devices and starts data simulation |
| `getDevices()` | `List<SmartDevice>` | Returns all registered devices |
| `getDevicesByRoom(room)` | `List<SmartDevice>` | Filter devices by room |
| `toggleDevice(deviceId)` | `void` | Toggle device on/off |
| `updateDeviceValue(id, value)` | `void` | Update device value (brightness, speed, etc.) |
| `getSensorData()` | `List<SensorData>` | Returns latest sensor readings |
| `getSensorHistory(type)` | `List<SensorData>` | Historical data for charts |

**Simulated Sensors:**
- Temperature (20–35°C, DHT22)
- Humidity (40–80%, DHT22)
- Voltage (210–240V, PZEM-004T)
- Current (0.5–15A)
- Power (100–3500W)
- Water Level (0–100%)
- Motion detection (boolean)
- Gas level (0–5000 ADC)
- Light level (0–1000 lux)

---

### AIService (`lib/core/services/ai_service.dart`)

Provides AI-powered analytics, anomaly detection, pattern recognition, and predictive insights.

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `generateInsights(data)` | `List<AIInsight>` | Analyze data and produce insights |
| `detectAnomalies(readings)` | `List<Anomaly>` | Flag abnormal sensor values |
| `predictUsage(deviceId)` | `UsagePrediction` | Forecast energy consumption |
| `getEnergyScore()` | `double` | Overall energy efficiency (0–100) |
| `getComfortIndex()` | `double` | Home comfort score |
| `getSuggestions()` | `List<Suggestion>` | AI recommendations |

**Analytics Capabilities:**
- Energy consumption pattern analysis
- Temperature anomaly detection
- Usage prediction (hourly/daily/weekly)
- Comfort index calculation
- Smart scheduling recommendations
- Cost optimization suggestions

---

### AdvancedHomeService (`lib/core/services/advanced_home_service.dart`)

Manages 11 categories of smart home devices with detailed state and controls.

**Device Categories:**

| Category | Key Features |
|---|---|
| **Robot Vacuum** | Status, battery, cleaned area, schedule, zones |
| **Smart Blinds** | Position (0–100%), tilt angle, auto sun tracking |
| **Smart Kitchen** | Oven temp, coffee maker schedule, fridge inventory |
| **Garage** | Door open/close, vehicle detection, temperature |
| **Sprinkler System** | Zone control, moisture-based scheduling |
| **Pet Feeder** | Schedule, portion size, feeding history |
| **Baby Monitor** | Audio level, temperature, humidity, alerts |
| **EV Charger** | Charge level, rate, cost, scheduled charging |
| **Air Purifier** | Air quality index, filter life, fan speed |
| **Pool** | Temperature, pH, chlorine, pump, heater |
| **Doorbell** | Motion zones, visitor log, two-way audio |

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `getRobotVacuumStatus()` | `Map` | Current vacuum state |
| `startVacuum(zone)` | `void` | Start cleaning a zone |
| `setBlindsPosition(id, pos)` | `void` | Set blind position 0–100% |
| `getKitchenStatus()` | `Map` | Oven, coffee, fridge status |
| `toggleGarageDoor()` | `void` | Open/close garage |
| `setEVChargeSchedule(...)` | `void` | Schedule EV charging |
| `getPoolChemistry()` | `Map` | pH, chlorine, temperature |

---

### SmartFeaturesService (`lib/core/services/smart_features_service.dart`)

Handles automation, scenes, routines, and smart home intelligence features.

**Feature Modules:**

| Module | Description |
|---|---|
| **Scenes** | One-tap presets (Movie Night, Good Morning, Away, etc.) |
| **Routines** | Time/trigger-based automation sequences |
| **Schedules** | Calendar-based device scheduling |
| **Comfort** | Adaptive temperature & lighting preferences |
| **Air Quality** | Indoor AQI monitoring and alerts |
| **Occupancy** | Room presence detection |
| **Safety Modes** | Home, Away, Night, Vacation modes |
| **Geofencing** | Location-based automation triggers |
| **Guest Access** | Temporary access controls |
| **Parental Controls** | Usage limits and content restrictions |
| **Maintenance** | Scheduled maintenance task tracking |
| **Activity Log** | System-wide event audit trail |

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `getScenes()` | `List<Scene>` | Available scene presets |
| `activateScene(sceneId)` | `void` | Apply a scene |
| `getRoutines()` | `List<Routine>` | Automation routines |
| `toggleRoutine(id)` | `void` | Enable/disable routine |
| `getSchedules()` | `List<Schedule>` | Device schedules |
| `setSafetyMode(mode)` | `void` | Change safety mode |
| `getActivityLog()` | `List<Activity>` | Recent system events |
| `getAirQualityIndex()` | `double` | Current indoor AQI |

---

### SecurityLifestyleService (`lib/core/services/security_lifestyle_service.dart`)

Manages security systems, lifestyle metrics, and environmental automation.

**Security Features:**

| Feature | Description |
|---|---|
| **Security Cameras** | Live feeds, recording status, motion zones |
| **Panic Button** | Emergency alert system |
| **Face Recognition** | Known/unknown person identification |
| **Perimeter Zones** | Virtual security boundaries |
| **Package Tracking** | Delivery detection and alerts |

**Lifestyle Features:**

| Feature | Description |
|---|---|
| **Sleep Quality** | Sleep score, duration, environment tracking |
| **Weather Automation** | Auto-adjust based on weather forecast |
| **HVAC Zones** | Multi-zone heating/cooling control |
| **Plant Care** | Watering schedules, soil moisture, light tracking |

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `getCameras()` | `List<Camera>` | Security camera list |
| `triggerPanic()` | `void` | Activate panic mode |
| `getSleepScore()` | `double` | Last night's sleep quality |
| `getWeatherAutomation()` | `Map` | Weather-triggered rules |
| `getHVACZones()` | `List<Zone>` | HVAC zone configurations |
| `getPlantStatus()` | `List<Plant>` | Plant health overview |

---

### EnergyAnalyticsService (`lib/core/services/energy_analytics_service.dart`)

Tracks energy costs, consumption, solar generation, and device health.

**Analytics Modules:**

| Module | Description |
|---|---|
| **Cost Tracking** | Real-time and historical energy costs |
| **Bill Estimation** | Projected monthly bills |
| **Solar** | Solar panel generation & savings |
| **Water Usage** | Water consumption monitoring |
| **Leaderboard** | Neighborhood efficiency comparison |
| **Device Health** | Component health scores & alerts |
| **Appliance Fingerprinting** | Per-appliance energy identification |

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `getCurrentCost()` | `double` | Current period energy cost |
| `getMonthlyBill()` | `BillEstimate` | Projected monthly bill |
| `getSolarGeneration()` | `SolarData` | Solar panel output |
| `getWaterUsage()` | `WaterData` | Water consumption stats |
| `getDeviceHealth()` | `List<HealthScore>` | Device health metrics |
| `getEnergyHistory(period)` | `List<EnergyEntry>` | Historical consumption |

---

### NotificationService (`lib/core/services/notification_service.dart`)

Manages push notifications and in-app notification display.

**Notification Types:** `alert`, `info`, `warning`, `success`, `emergency`

**Priority Levels:** `low`, `medium`, `high`, `critical`

**Key Methods:**

| Method | Returns | Description |
|---|---|---|
| `initialize()` | `void` | Set up notification channels |
| `showNotification(title, body, type)` | `void` | Display a notification |
| `getNotifications()` | `List<Notification>` | All notifications |
| `markAsRead(id)` | `void` | Mark notification read |
| `clearAll()` | `void` | Dismiss all notifications |

---

## Feature Providers

### AuthProvider (`lib/features/auth/providers/auth_provider.dart`)

| Method | Description |
|---|---|
| `login(email, password)` | Authenticate user |
| `logout()` | Sign out |
| `isAuthenticated` | Login state getter |
| `currentUser` | Current `AppUser` getter |

### DashboardProvider (`lib/features/dashboard/providers/dashboard_provider.dart`)

| Method | Description |
|---|---|
| `refreshData()` | Reload dashboard data |
| `sensorSummary` | Aggregated sensor readings |
| `quickActions` | Available quick-action buttons |
| `recentInsights` | Latest AI insights |

### DeviceProvider (`lib/features/devices/providers/device_provider.dart`)

| Method | Description |
|---|---|
| `devices` | All devices list |
| `filterByRoom(room)` | Room-filtered devices |
| `toggleDevice(id)` | Toggle on/off |
| `updateValue(id, val)` | Change device value |

### SensorProvider (`lib/features/sensors/providers/sensor_provider.dart`)

| Method | Description |
|---|---|
| `latestReadings` | Current sensor values |
| `getHistory(type, range)` | Historical chart data |
| `alerts` | Active sensor alerts |

### AnalyticsProvider (`lib/features/analytics/providers/analytics_provider.dart`)

| Method | Description |
|---|---|
| `energyData` | Energy consumption data |
| `aiInsights` | AI-generated insights |
| `predictions` | Usage predictions |
| `anomalies` | Detected anomalies |

### AdminProvider (`lib/features/admin/providers/admin_provider.dart`)

| Method | Description |
|---|---|
| `users` | All registered users |
| `systemLogs` | System event logs |
| `aiModels` | AI model status |
| `securityEvents` | Security audit log |
| `systemStats` | CPU, memory, uptime |

---

## Shared Utilities

### Responsive (`lib/core/utils/responsive.dart`)

```dart
class Responsive {
  static bool isMobile(context)  → width < 600
  static bool isTablet(context)  → 600 ≤ width < 1200
  static bool isDesktop(context) → width ≥ 1200
}
```

### ThemeProvider (`lib/core/theme/app_theme.dart`)

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;
  void toggleTheme();        // Switch dark/light
  bool get isDarkMode;
}
```

### Custom Painters (`lib/shared/painters/custom_painters.dart`)

| Painter | Description |
|---|---|
| `CircularGaugePainter` | Animated radial gauge with gradient arc |
| `WavePainter` | Animated wave effect for water level display |

### Common Widgets (`lib/shared/widgets/common_widgets.dart`)

| Widget | Description |
|---|---|
| `ShimmerLoading` | Skeleton loading placeholder |
| `GlassCard` | Frosted glass-effect card container |
| `GradientText` | Text with gradient color fill |
| `SensorsGrid` | Responsive grid of sensor cards |

---

*See [Architecture](ARCHITECTURE.md) for system design and data flow diagrams.*
