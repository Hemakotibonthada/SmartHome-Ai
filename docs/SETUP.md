# Setup & Installation

## Prerequisites

### Required Software

| Tool | Version | Purpose |
|---|---|---|
| **Flutter SDK** | 3.x (Dart ≥3.2.0) | Cross-platform framework |
| **Android Studio** or **VS Code** | Latest | IDE with Flutter plugin |
| **Chrome** | Latest | Web development & debugging |
| **Git** | Latest | Version control |
| **Java JDK** | 17 | Android build toolchain |
| **Android SDK** | API 34+ | Android compilation |

### Optional (for ESP32 hardware)

| Tool | Version | Purpose |
|---|---|---|
| **PlatformIO** or **Arduino IDE** | Latest | ESP32 firmware development |
| **MQTT Broker** (Mosquitto) | Latest | Message broker for IoT |
| **CP2102 / CH340 Driver** | Latest | USB-to-serial for ESP32 |

## Flutter Environment Setup

### 1. Install Flutter SDK

```bash
# Download Flutter SDK
# https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor -v
```

Ensure `flutter doctor` shows no critical issues:
```
[✓] Flutter (Channel stable)
[✓] Android toolchain
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device
```

### 2. Set JAVA_HOME (Windows)

```powershell
# Find your JDK installation
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot"
$env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH

# Verify
java -version
```

To set permanently:
1. Open **System Properties** → **Environment Variables**
2. Add `JAVA_HOME` pointing to your JDK directory
3. Add `%JAVA_HOME%\bin` to `PATH`

### 3. Clone & Install Dependencies

```bash
# Clone the repository
git clone https://github.com/Hemakotibonthada/SmartHome-Ai.git
cd SmartHome-Ai

# Install Flutter dependencies
flutter pub get
```

## Running the Application

### Web (Chrome)

```bash
flutter run -d chrome
```

### Android Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run on the emulator
flutter run
```

### Android Device (USB)

1. Enable **Developer Options** and **USB Debugging** on your phone
2. Connect via USB
3. Run:
```bash
flutter devices          # Verify device appears
flutter run -d <device_id>
```

### iOS (macOS only)

```bash
cd ios && pod install && cd ..
flutter run -d <ios_simulator_or_device>
```

## Project Dependencies

The app uses the following packages (from `pubspec.yaml`):

### Core
| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management |
| `firebase_core` | ^2.24.2 | Firebase initialization |
| `firebase_auth` | ^4.16.0 | User authentication |
| `cloud_firestore` | ^4.14.0 | Cloud database |
| `firebase_database` | ^10.4.0 | Realtime database |
| `firebase_messaging` | ^14.7.9 | Push notifications |

### UI & Visualization
| Package | Version | Purpose |
|---|---|---|
| `fl_chart` | ^0.66.0 | Line, bar, pie charts |
| `syncfusion_flutter_gauges` | ^24.1.41 | Radial & linear gauges |
| `google_fonts` | ^6.1.0 | Custom typography |
| `shimmer` | ^3.0.0 | Loading skeleton animations |
| `animated_text_kit` | ^4.2.2 | Text animations |
| `lottie` | ^3.0.0 | Lottie animations |
| `flutter_staggered_animations` | ^1.1.1 | List animations |
| `percent_indicator` | ^4.2.3 | Circular/linear progress |
| `flutter_svg` | ^2.0.9 | SVG rendering |
| `flutter_animate` | ^4.3.0 | Declarative animations |
| `flutter_spinkit` | ^5.2.1 | Loading spinners |

### IoT & Communication
| Package | Version | Purpose |
|---|---|---|
| `mqtt_client` | ^10.2.0 | MQTT protocol client |
| `web_socket_channel` | ^2.4.0 | WebSocket connections |
| `http` | ^1.2.0 | HTTP requests |

### Utilities
| Package | Version | Purpose |
|---|---|---|
| `intl` | ^0.19.0 | Date/number formatting |
| `shared_preferences` | ^2.2.2 | Local key-value storage |
| `uuid` | ^4.2.1 | Unique ID generation |
| `rxdart` | ^0.27.7 | Reactive extensions |
| `path_provider` | ^2.1.1 | File system paths |
| `flutter_local_notifications` | ^17.0.0 | Local notifications |

## IDE Setup

### VS Code
1. Install extensions: **Flutter**, **Dart**
2. Open the project folder
3. Press `F5` or run `flutter run` in terminal

### Android Studio
1. Install plugins: **Flutter**, **Dart**
2. Open the project
3. Select target device from toolbar
4. Click **Run** (▶)

## Troubleshooting

### Common Issues

| Issue | Solution |
|---|---|
| `JAVA_HOME is not set` | Set `JAVA_HOME` environment variable to your JDK path |
| `flutter: command not found` | Add Flutter SDK `bin/` to your system `PATH` |
| `Gradle build failed` | Run `cd android && ./gradlew clean && cd ..` |
| `pub get failed` | Delete `pubspec.lock` and run `flutter pub get` again |
| `Chrome not found` | Install Chrome or set `CHROME_EXECUTABLE` env variable |
| `Android license not accepted` | Run `flutter doctor --android-licenses` |

### Clean Build

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

*See [Deployment](DEPLOYMENT.md) for production build instructions.*
