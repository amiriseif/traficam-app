# TrafficCam - Traffic Police Officer App

A Flutter application for traffic police officers to report, track, and manage traffic incidents in real-time using AI-powered image analysis and Supabase backend.

## 🚀 Project Overview

**TrafficCam** is a mobile/desktop app that enables traffic police officers to:
- Report traffic incidents with AI-powered image analysis
- Stream live incident feeds
- Track traffic congestion zones
- Receive traffic placement recommendations
- Manage officer profiles and status updates

**Tech Stack:**
- **Framework:** Flutter 3.32.7
- **Language:** Dart 3.8.1
- **Backend:** Supabase (PostgreSQL + Auth + Realtime)
- **AI Vision:** Azure Computer Vision
- **State Management:** Riverpod
- **Navigation:** Go Router

---

## ⚙️ Mock Mode Explained

The app includes **mock/demo modes** for development and testing without requiring external APIs. Here's what's mocked:

### 1. **Azure Vision Service** (Image Analysis)
📁 `lib/dashboard/core/services/azure_vision_service.dart`

**Mock Mode:** `_useMock = true`

**What it does:**
- Simulates traffic incident detection from photos
- Returns realistic mock incident descriptions in French
- Detects scenarios: collisions, traffic congestion, fires

**To enable real Azure Vision:**
```dart
static const bool _useMock = false;
static const String _endpoint = 'YOUR_AZURE_VISION_ENDPOINT';
static const String _apiKey = 'YOUR_AZURE_VISION_KEY';
```
Then sign up at [Azure Computer Vision](https://azure.microsoft.com/en-us/products/ai-services/ai-vision/)

---

### 2. **Traffic Data Service** (Zone Congestion)
📁 `lib/dashboard/core/services/traffic_data_service.dart`

**Mock Mode:** `_useMock = true`

**What it does:**
- Provides fake traffic congestion data for Tunis zones
- Returns placement recommendations for officers
- Simulates real-time traffic conditions

**To enable real traffic API:**
```dart
static const bool _useMock = false;
// Implement real API calls (HERE, TomTom, or custom)
```

---

### 3. **Feed Screen** (Incident Stream)
📁 `lib/feed/presentation/screens/feed_screen.dart`

**What it does:**
- In production, uses `StreamBuilder` with Supabase realtime
- Falls back to mock incidents if stream is empty
- Displays live incident feed with details

---

### 4. **Dashboard** (Control Orders)
📁 `lib/dashboard/presentation/screens/dashboard_screen.dart`

**What it does:**
- Shows mock traffic control orders for officers
- Simulates pending assignment management

---

## 🔄 Running the App

### Option 1: Mock Mode (Development - Current Setup)
```bash
flutter run
# Choose device: Windows or Edge
```
✅ Works out of the box
✅ No API keys needed
✅ Perfect for UI/UX testing

---

### Option 2: Real App (Production)

#### Step 1: Set up Supabase
1. Create account at [supabase.com](https://supabase.com)
2. Create a new project
3. Copy the URL and Anon Key
4. Update `lib/dashboard/core/services/supabase_service.dart`:
```dart
static const String _supabaseUrl = 'YOUR_PROJECT_URL';
static const String _supabaseAnonKey = 'YOUR_ANON_KEY';
```

#### Step 2: Set up Azure Vision (Optional)
1. Sign up at [Azure Portal](https://portal.azure.com)
2. Create Computer Vision resource
3. Get endpoint and key
4. Update `lib/dashboard/core/services/azure_vision_service.dart`:
```dart
static const bool _useMock = false;
static const String _endpoint = 'YOUR_ENDPOINT';
static const String _apiKey = 'YOUR_KEY';
```

#### Step 3: Set up Traffic Data API (Optional)
1. Choose a provider: HERE, TomTom, or build your own
2. Update `lib/dashboard/core/services/traffic_data_service.dart`:
```dart
static const bool _useMock = false;
// Implement real API calls
```

#### Step 4: Create Test User in Supabase
1. Go to Supabase Dashboard → Authentication → Users
2. Add user with email: `10234@trafficam.tn` and password `testpassword`
3. Login with:
   - **Matricule/Badge:** `10234`
   - **Mot de passe:** `testpassword`

#### Step 5: Run Real App
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point
├── dashboard/                          # Main dashboard
│   ├── core/
│   │   ├── theme/                     # App colors & theme
│   │   ├── services/                  # Supabase, Azure Vision, Traffic Data
│   │   ├── models/                    # Data models
│   │   └── utils/                     # Widgets & helpers
│   └── presentation/
│       └── screens/                   # Dashboard UI
├── features/
│   ├── auth/                          # Login screen
│   └── app_shell.dart                 # Main app navigation
└── feed/
    └── presentation/screens/          # Incident feed
```

---

## 🔐 Credentials

### Development (Mock Mode)
- No credentials needed - works immediately

### Testing (Real Supabase)
- Email: `10234@trafficam.tn`
- Password: `testpassword` (or your custom)

---

## 🛠️ Disabling Mock Mode - Quick Guide

| Service | File | Change |
|---------|------|--------|
| **Azure Vision** | `azure_vision_service.dart:16` | `_useMock = true` → `false` |
| **Traffic Data** | `traffic_data_service.dart:10` | `_useMock = true` → `false` |
| **Incidents** | `feed_screen.dart:20` | Stream already enabled |

---

## 📦 Dependencies

- `supabase_flutter: ^2.3.0` - Backend
- `flutter_riverpod: ^2.4.9` - State management
- `go_router: ^13.2.0` - Navigation
- `http: ^1.2.0` - HTTP requests
- `image_picker: ^1.0.7` - Camera & images
- `camera: ^0.10.5` - Camera access
- `speech_to_text: ^6.6.0` - Voice input
- `intl: ^0.20.2` - Localization

---

## 🚨 Troubleshooting

**Error: "Unable to locate Android SDK"**
- Set Android SDK path: `flutter config --android-sdk=YOUR_SDK_PATH`

**Error: "intl version conflict"**
- Already fixed in pubspec.yaml: `intl: ^0.20.2`

**Phone not detected?**
- Enable USB debugging on phone
- Run: `flutter devices`

---

## 📝 Notes

- App is in **French** for Tunisian traffic police
- Lat/Long coordinates default to **Tunis**
- Mock data simulates realistic scenarios
- Production requires Supabase database schema setup

---

## 📧 Support

For setup help, check:
- [Flutter Docs](https://docs.flutter.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [Azure Vision API](https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/)
