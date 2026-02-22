# Deployment Guide

Instructions for building, releasing, and deploying SmartHome AI across all platforms.

---

## Android APK

### Debug Build
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build
```bash
# Set JAVA_HOME if not configured
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot"

flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk` (~54 MB)

### Split APKs (Smaller Downloads)
```bash
flutter build apk --split-per-abi --release
```
Output:
- `app-armeabi-v7a-release.apk` — 32-bit ARM
- `app-arm64-v8a-release.apk` — 64-bit ARM (most devices)
- `app-x86_64-release.apk` — x86 emulators

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Install on Device
```bash
# Via Flutter
flutter install

# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Web Deployment

### Build for Web
```bash
flutter build web --release
```
Output: `build/web/` directory

### Build with Custom Base Path
```bash
flutter build web --release --base-href "/smart-home/"
```

### Serve Locally (Testing)
```bash
# Using Python
cd build/web && python -m http.server 8080

# Using dhttpd (Dart)
dart pub global activate dhttpd
dhttpd --path build/web --port 8080
```

### Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize hosting
firebase init hosting
# Select: build/web as public directory
# Configure as single-page app: Yes

# Deploy
firebase deploy --only hosting
```

### Deploy to GitHub Pages

```bash
# Build with correct base href
flutter build web --release --base-href "/SmartHome-Ai/"

# Option 1: Manual push to gh-pages branch
cd build/web
git init
git add .
git commit -m "Deploy SmartHome AI web"
git remote add origin https://github.com/Hemakotibonthada/SmartHome-Ai.git
git push -f origin main:gh-pages

# Option 2: Use peanut package
dart pub global activate peanut
peanut --directory build/web
```

Then enable GitHub Pages in repository Settings → Pages → Source: `gh-pages` branch.

### Deploy to Netlify

1. Build the web app: `flutter build web --release`
2. Go to [Netlify](https://app.netlify.com/)
3. Drag and drop the `build/web/` folder
4. Configure custom domain (optional)

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd build/web
vercel --prod
```

---

## iOS Build (macOS Required)

### Prerequisites
- macOS with Xcode 15+
- Apple Developer account
- CocoaPods installed

### Build
```bash
cd ios && pod install && cd ..

# Simulator
flutter build ios --debug --simulator

# Device (requires signing)
flutter build ios --release
```

### Archive for App Store
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Any iOS Device** target
3. Product → Archive
4. Upload to App Store Connect via Organizer

### Code Signing
1. In Xcode → Runner → Signing & Capabilities
2. Select your team
3. Set Bundle Identifier: `com.example.smartHomeAi`
4. Xcode will auto-manage provisioning profiles

---

## App Configuration

### Android (`android/app/build.gradle.kts`)

| Setting | Value | Description |
|---|---|---|
| `applicationId` | `com.example.smart_home_ai` | Unique app identifier |
| `minSdk` | 21 | Android 5.0+ |
| `targetSdk` | 34 | Android 14 |
| `versionCode` | 1 | Internal version number |
| `versionName` | `1.0.0` | User-visible version |

### Change App Name

**Android:** Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="SmartHome AI" ...>
```

**iOS:** Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>SmartHome AI</string>
```

**Web:** Edit `web/index.html`:
```html
<title>SmartHome AI</title>
```

### Change App Icon

Use the `flutter_launcher_icons` package:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
  image_path: "assets/icons/app_icon.png"
```

```bash
flutter pub run flutter_launcher_icons
```

---

## Environment Configuration

### Production Checklist

- [ ] Update `applicationId` / bundle ID for your organization
- [ ] Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] Configure Firebase Authentication providers
- [ ] Set Firestore security rules (see [Firebase Setup](FIREBASE_SETUP.md))
- [ ] Generate and configure signing keys
- [ ] Update app name and icons
- [ ] Set `version` in `pubspec.yaml`
- [ ] Remove `debugShowCheckedModeBanner: false` is already set
- [ ] Test on all target platforms
- [ ] Enable ProGuard/R8 for Android release (auto-enabled)

### Signing Key (Android)

```bash
# Generate keystore
keytool -genkey -v -keystore smart-home-ai.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smarthome

# Create key.properties in android/
storePassword=<password>
keyPassword=<password>
keyAlias=smarthome
storeFile=../smart-home-ai.jks
```

Reference in `android/app/build.gradle.kts`:
```kotlin
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(rootProject.file("key.properties")))

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## Performance Optimization

### Web
```bash
# Build with HTML renderer (smaller size)
flutter build web --web-renderer html --release

# Build with CanvasKit (better fidelity)
flutter build web --web-renderer canvaskit --release

# Tree-shake icons
flutter build web --release --tree-shake-icons
```

### Android
```bash
# Obfuscate & minify
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Analyze APK size
flutter build apk --analyze-size
```

---

## CI/CD (GitHub Actions Example)

Create `.github/workflows/build.yml`:

```yaml
name: Build & Deploy

on:
  push:
    branches: [main]

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build web --release
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web

  build-apk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## Versioning

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^^^^^  ^ 
#        |      Build number (increment per release)
#        Semantic version (major.minor.patch)
```

---

*See [Setup](SETUP.md) for development environment configuration.*
