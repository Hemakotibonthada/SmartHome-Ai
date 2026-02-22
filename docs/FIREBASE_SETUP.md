# Firebase Setup

This guide walks through creating and configuring a Firebase project for SmartHome AI.

## Overview

SmartHome AI uses the following Firebase services:

| Service | Purpose |
|---|---|
| **Firebase Authentication** | User login (email/password, Google) |
| **Cloud Firestore** | Structured data (users, devices, settings) |
| **Realtime Database** | Live sensor data & device state |
| **Cloud Messaging (FCM)** | Push notifications & alerts |

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**
3. Enter project name: `SmartHome-AI`
4. Enable Google Analytics (optional)
5. Click **Create project**

## Step 2: Add Flutter App

### Android
1. In Firebase Console, click **Add app** → **Android**
2. Package name: `com.example.smart_home_ai` (from `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### iOS
1. Click **Add app** → **iOS**
2. Bundle ID: `com.example.smartHomeAi`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### Web
1. Click **Add app** → **Web**
2. App nickname: `SmartHome AI Web`
3. Copy the Firebase config object
4. Update `web/index.html` with the config:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.x.x/firebase-app.js";

  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "your-project.firebaseapp.com",
    databaseURL: "https://your-project-default-rtdb.firebaseio.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef"
  };

  initializeApp(firebaseConfig);
</script>
```

## Step 3: Configure Authentication

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable providers:
   - **Email/Password** — Enable
   - **Google** — Enable (add support email)
3. (Optional) Set up **authorized domains** for web

### User Roles

The app supports three roles stored in Firestore user documents:

| Role | Access Level |
|---|---|
| `admin` | Full access: admin panel, user management, AI models, security logs |
| `user` | Standard access: dashboard, devices, analytics, settings |
| `guest` | Limited access: view-only dashboard, basic device info |

## Step 4: Set Up Cloud Firestore

1. Go to **Firestore Database** → **Create database**
2. Start in **test mode** (for development)
3. Select your preferred region

### Collections Schema

```
firestore/
├── users/                    # User profiles
│   └── {userId}/
│       ├── name: string
│       ├── email: string
│       ├── role: string        # "admin" | "user" | "guest"
│       ├── createdAt: timestamp
│       └── preferences: map
│           ├── theme: string
│           ├── notifications: boolean
│           └── temperatureUnit: string
│
├── devices/                  # Device registry
│   └── {deviceId}/
│       ├── name: string
│       ├── type: string
│       ├── room: string
│       ├── isOnline: boolean
│       ├── isOn: boolean
│       ├── value: number
│       ├── properties: map
│       └── lastUpdated: timestamp
│
├── rooms/                    # Room configs
│   └── {roomId}/
│       ├── name: string
│       ├── icon: string
│       ├── temperature: number
│       ├── humidity: number
│       └── deviceCount: number
│
├── scenes/                   # Automation scenes
│   └── {sceneId}/
│       ├── name: string
│       ├── icon: string
│       ├── actions: array
│       └── isActive: boolean
│
├── notifications/            # Notification history
│   └── {notifId}/
│       ├── title: string
│       ├── body: string
│       ├── type: string
│       ├── priority: string
│       ├── isRead: boolean
│       └── timestamp: timestamp
│
└── settings/                 # Global settings
    └── system/
        ├── safetyMode: string
        ├── geofenceEnabled: boolean
        └── maintenanceMode: boolean
```

### Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Authenticated users can read devices
    match /devices/{deviceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'user'];
    }

    // Admin-only collections
    match /settings/{doc} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Notifications - users see their own
    match /notifications/{notifId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 5: Set Up Realtime Database

1. Go to **Realtime Database** → **Create Database**
2. Start in **test mode**
3. Select region

### Data Structure

```json
{
  "sensors": {
    "esp32_node_01": {
      "temperature": { "value": 25.5, "unit": "°C", "timestamp": 1708617600 },
      "humidity": { "value": 65.2, "unit": "%", "timestamp": 1708617600 },
      "voltage": { "value": 228.5, "unit": "V", "timestamp": 1708617600 },
      "current": { "value": 4.2, "unit": "A", "timestamp": 1708617600 },
      "power": { "value": 957.0, "unit": "W", "timestamp": 1708617600 },
      "water_level": { "value": 72.5, "unit": "%", "timestamp": 1708617600 },
      "motion": { "detected": false, "timestamp": 1708617600 },
      "gas": { "value": 350, "alert": false, "timestamp": 1708617600 },
      "light": { "value": 650, "unit": "lux", "timestamp": 1708617600 }
    }
  },
  "relays": {
    "esp32_node_01": {
      "relay_1": false,
      "relay_2": false,
      "relay_3": false,
      "relay_4": false
    }
  },
  "device_status": {
    "esp32_node_01": {
      "online": true,
      "ip": "192.168.1.42",
      "uptime": 3600,
      "firmware": "1.0.0",
      "lastSeen": 1708617600
    }
  }
}
```

### Security Rules

```json
{
  "rules": {
    "sensors": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "relays": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "device_status": {
      ".read": "auth != null",
      ".write": true
    }
  }
}
```

## Step 6: Cloud Messaging (FCM)

1. Go to **Cloud Messaging** in Firebase Console
2. For Web, generate a **VAPID key** under Web Push certificates
3. Add the VAPID key to your web app configuration

### Notification Channels

| Channel | Priority | Description |
|---|---|---|
| `alerts` | High | Safety alerts (gas, water, intrusion) |
| `devices` | Default | Device state changes |
| `energy` | Low | Energy reports and tips |
| `system` | Default | System status updates |

## Step 7: Android Gradle Configuration

Ensure `android/app/build.gradle.kts` includes:

```kotlin
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.x.x"))
}
```

And `android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

## Step 8: Initialize in Flutter

Firebase is initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (when using Firebase)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const SmartHomeApp());
}
```

> **Note:** The current version uses simulated data for demonstration. Uncomment Firebase initialization and add `google-services.json` / `GoogleService-Info.plist` when connecting to a real Firebase project.

## Testing Firebase Connection

```bash
# Verify Firebase CLI is installed
firebase --version

# Login to Firebase
firebase login

# Initialize Firebase in the project
firebase init

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Realtime Database rules
firebase deploy --only database
```

---

*See [ESP32 Guide](ESP32_GUIDE.md) for hardware setup that sends data to Firebase.*
