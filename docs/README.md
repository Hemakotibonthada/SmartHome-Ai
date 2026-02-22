# SmartHome AI — Documentation

Welcome to the **SmartHome AI** documentation. This guide covers everything you need to understand, set up, develop, and deploy the application.

## What is SmartHome AI?

SmartHome AI is a full-stack IoT smart home platform combining a **Flutter cross-platform app** (Android, iOS, Web) with **ESP32 microcontroller firmware**. The system provides real-time monitoring, AI-powered analytics, device automation, and comprehensive home management through an elegant, modern interface.

## Documentation Index

| Document | Description |
|---|---|
| [Architecture](ARCHITECTURE.md) | System architecture, folder structure, data flow, and design patterns |
| [Setup & Installation](SETUP.md) | Prerequisites, environment setup, and running the application |
| [Features Guide](FEATURES.md) | Detailed walkthrough of all application features and modules |
| [API & Services Reference](API_REFERENCE.md) | Core services, providers, models, and service layer documentation |
| [ESP32 Hardware Guide](ESP32_GUIDE.md) | Hardware setup, wiring, firmware flashing, and MQTT topics |
| [Firebase Setup](FIREBASE_SETUP.md) | Firebase project creation, authentication, Firestore, and messaging |
| [Deployment](DEPLOYMENT.md) | Building APKs, web deployment, and release configuration |

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Hemakotibonthada/SmartHome-Ai.git

# 2. Install dependencies
cd SmartHome-Ai
flutter pub get

# 3. Run on Chrome (web)
flutter run -d chrome

# 4. Build Android APK
flutter build apk --release
```

## Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter 3.x, Dart, Material Design 3 |
| **State Management** | Provider (14 providers) |
| **Backend** | Firebase (Auth, Firestore, Realtime Database, Cloud Messaging) |
| **IoT Hardware** | ESP32, Arduino/PlatformIO |
| **Communication** | MQTT, WebSocket, HTTP |
| **Charts & Visuals** | fl_chart, Syncfusion Gauges, Lottie, Custom Painters |
| **AI/Analytics** | On-device AI service (anomaly detection, predictions, insights) |

## Supported Platforms

- **Android** — APK / Play Store
- **iOS** — Xcode build
- **Web** — Chrome, Edge, Firefox (responsive desktop + mobile layout)

## License

This project is proprietary. See the repository for license details.

---

*SmartHome AI v1.0.0 — Built with Flutter & ESP32 by Circuvent Technologies Pvt Ltd, Hyderabad*
