# 👁 Eye Sentinel

**Real-time blink detection using your device camera.**  
Built with Flutter + Google ML Kit. Green when eyes are open, red when closed.

---

## Overview

Eye Sentinel uses **Google ML Kit Face Detection** to analyze your camera feed frame by frame, extracting the probability that each eye is open or closed. No internet connection required — all processing runs fully on-device.

| State | Indicator |
|---|---|
| Eyes Open | 🟢 Green glow + EYES OPEN |
| Eyes Closed | 🔴 Red glow + EYES CLOSED |
| No Face | ⚫ Grey + NO FACE DETECTED |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── theme/
│   └── app_theme.dart               # Colors, typography, dark theme
├── screens/
│   ├── splash_screen.dart           # Animated intro screen
│   └── detector_screen.dart         # Main camera + detection UI
├── services/
│   ├── camera_service.dart          # Camera init, stream, switch
│   └── face_detection_service.dart  # ML Kit wrapper, eye state logic
└── widgets/
    ├── status_indicator.dart        # Green/red animated status card
    ├── eye_probability_bar.dart     # Per-eye confidence bars
    ├── camera_overlay.dart          # Corner frame overlay
    ├── scan_line.dart               # Animated scan effect
    └── stats_panel.dart             # Blink count, open %, frame count
```

---

## Setup

### Prerequisites
- Flutter `>=3.13.0`
- Dart `>=3.1.0`
- Android SDK 21+ / iOS 12+
- Physical device (camera required; emulators won't work)

### Steps

```bash
# 1. Clone / extract the project
cd eye_sentinel

# 2. Install dependencies
flutter pub get

# 3. Run on connected device
flutter run
```

### Android — No extra config needed
The `AndroidManifest.xml` already declares `CAMERA` permission and the ML Kit dependency.

### iOS — Add to Info.plist
Open `ios/Runner/Info.plist` and add inside the `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>Eye Sentinel needs camera access to detect and analyze your eye state in real time.</string>
```

---

## How It Works

```
Camera Frame (NV21/YUV)
        ↓
  InputImage builder
        ↓
  ML Kit FaceDetector
  (enableClassification: true)
        ↓
  face.leftEyeOpenProbability   ← float 0.0–1.0
  face.rightEyeOpenProbability  ← float 0.0–1.0
        ↓
  Threshold: >= 0.5 → OPEN
             <  0.5 → CLOSED
        ↓
  Both open → Green
  Either closed → Red
```

ML Kit's `leftEyeOpenProbability` returns a confidence score from 0 (definitely closed) to 1 (definitely open). The 0.5 threshold is adjustable in `face_detection_service.dart`.

---

## Customization

### Change the blink threshold
In `lib/services/face_detection_service.dart`:
```dart
static const double _eyeOpenThreshold = 0.5; // Increase for stricter detection
```

### Change accent colors
In `lib/theme/app_theme.dart`:
```dart
static const Color eyeOpen = Color(0xFF00E57A);   // Green
static const Color eyeClosed = Color(0xFFFF3B5C); // Red
static const Color accent = Color(0xFF00CFFF);    // Cyan
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `camera` | Camera preview + image streaming |
| `google_mlkit_face_detection` | On-device face + eye detection |
| `flutter_animate` | Declarative animations |
| `google_fonts` | JetBrains Mono + Space Grotesk |

---

## Notes

- **Front camera** is selected by default for self-facing use; tap the camera switch icon to toggle.
- Frame drops are intentional — the detection pipeline skips frames while busy to prevent lag.
- Blink counting increments when the system sees an `open → closed` transition per session.
- Stats reset on app restart.

---

## Portfolio Note

Built to demonstrate:
- Device hardware integration (camera streaming)
- On-device ML inference (no API calls)
- Real-time UI updates with animated state transitions
- Clean MVVM-style service/screen separation in Flutter
