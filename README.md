# 🚨 Smart Route Alert — Adaptive Location-Based Destination Alarm

[![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue.svg?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Hosting-FFCA28.svg?logo=firebase)](https://firebase.google.com)
[![OpenStreetMap](https://img.shields.io/badge/Map-OpenStreetMap%20%7C%20CartoDB-7E57C2.svg?logo=openstreetmap)](https://www.openstreetmap.org)
[![Live Demo](https://img.shields.io/badge/Live%20Demo-smart--location--alaram.web.app-brightgreen.svg)](https://smart-location-alaram.web.app)

**Smart Route Alert** is a complete, production-ready Flutter mobile and web application designed for commuters, transit travelers, and long-distance passengers. It intelligently predicts arrival times and triggers high-urgency alarms (sound, vibration, and persistent notifications) before you reach your destination, ensuring you never miss your stop.

Live Application URL: **[https://smart-location-alaram.web.app](https://smart-location-alaram.web.app)**

---

## 🌟 Key Features

### 1. 🎨 Stitch UI Visual Source of Truth
- Built directly from Google Stitch designs (`15343939883169592414`).
- Custom linear gradients (`from-[#4F46E5] to-[#3525CD]`), glowing indigo box shadows, glassmorphism, responsive bottom sheets, and radial alarm emergency glows.

### 2. 🗺️ OpenStreetMap & CartoDB Engine (100% Free)
- Zero Google Maps API keys required!
- **Interactive Map Themes**: Toggle seamlessly between **Vibrant Light Mode** (`rastertiles/voyager`) and **Sleek Night Mode** (`dark_all`).
- **Worldwide Geocoding Search**: Powered by Nominatim OpenStreetMap search for instant location autocompletion anywhere on Earth.

### 3. 🧠 Smart Adaptive Lead-Time Prediction Engine
- **Haversine Geodesic Distance Engine**: Calculates accurate distance to target coordinates.
- **Rolling Window Speed Spike Filter**: Filters out sudden GPS speed spikes to prevent false alarms.
- **Directional Bearing & Trajectory Detector**: Verifies if the user is approaching or moving away from the destination.
- **Escalating Alarm System**: Audio volume & vibration frequency increase automatically if unacknowledged after 20 seconds.

### 4. 🔑 Google Authentication & Cloud Firestore
- **Google Sign-In**: Cross-platform OAuth login with reactive state stream.
- **User-Centric Database**: Cloud Firestore (`users/{uid}/journeys` & `users/{uid}/saved_places`) isolates each user's data securely.
- **Firestore Security Rules**: Rules locked to `request.auth.uid == userId`.

### 5. 📍 User-Defined Custom Places
- Set custom **Home**, **Work / Office**, **College**, or **Custom Locations** by searching or tapping anywhere on the interactive map via the location pin picker.

---

## 🏗️ Architecture & Project Structure

Clean Architecture built with **Flutter Riverpod** state management:

```
lib/
├── core/
│   ├── constants/       # App Colors, Typography, Spacing, Gradients
│   ├── routing/         # GoRouter declaration & screen routes
│   └── theme/           # Light & Dark Material3 themes
├── features/
│   ├── alarm/           # Emergency full-screen alarm overlay screen
│   ├── alarm_setup/     # Lead-time calibration & destination details
│   ├── arrival/         # Journey completion & feedback collection
│   ├── destination_search/ # Worldwide Nominatim location search
│   ├── history/         # Journey logs & historical travel statistics
│   ├── home/            # Discovery dashboard & interactive map view
│   ├── journey/         # Active tracking & real-time bottom sheet
│   ├── onboarding/      # 3-slide Stitch visual carousel & permissions setup
│   ├── profile/         # User profile, Google Auth & Firestore sync status
│   ├── saved_places/    # Custom Home/Work map location picker modal
│   └── simulation/      # Journey route simulator & speed controls
├── services/
│   ├── alarm/           # AudioPlayer & Vibration escalation service
│   ├── auth/            # Firebase Auth & Google Sign-In service
│   ├── database/        # Cloud Firestore user database manager
│   ├── location/        # Geolocator GPS stream & permission handling
│   ├── search/          # Nominatim OpenStreetMap geocoding API
│   ├── smart_alert/     # Haversine distance, Eta, & SmartAlertEngine
│   └── storage/         # Shared Preferences local storage service
├── shared/
│   ├── models/          # Destination, Journey, LocationSample, SavedPlace
│   ├── providers/       # Riverpod Notifier & State Providers
│   └── widgets/         # App buttons, status chips, bottom sheets
└── firebase_options.dart # Firebase multi-platform options configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.41.6` or stable channel)
- [Dart SDK](https://dart.dev/get-started/sdk) (`^3.11.4`)
- Node.js & npm (optional, for Firebase CLI commands)

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Rajkishore08/Location-Based-Alarm--Flutter-app.git
   cd Location-Based-Alarm--Flutter-app
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

4. **Run Static Analysis**:
   ```bash
   flutter analyze
   ```

5. **Launch Application**:
   ```bash
   # Run on Web (Chrome)
   flutter run -d chrome

   # Run on Desktop (macOS)
   flutter run -d macos
   ```

---

## 📦 Building & Deploying

### Build Web Release Bundle
```bash
flutter build web --release
```

### Build Android Release APK
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Deploy to Firebase Hosting
```bash
npx -y firebase-tools@latest deploy --only hosting --project smart-location-alaram
```

---

## 🛡️ License & Author

Developed with ❤️ by **Rajkishore** for smart transit safety.
