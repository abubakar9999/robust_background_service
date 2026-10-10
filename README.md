# Robust Background Service 🚀

A highly robust, simplified, and powerful Flutter plugin for running Dart code in the background. Built on top of `flutter_background_service`, this package removes all boilerplate and handles device-specific OEM restrictions (like Xiaomi, Samsung, Oppo aggressive task killers) automatically.

## ✨ Features

- **Boilerplate-Free Background Tasks:** Run your Dart code periodically in the background with a single ultra-simple method.
- **Beat OEM Task Killers:** Automatically detects tricky devices (Xiaomi, Redmi, Poco, Samsung, Oppo, Vivo, etc.) and seamlessly routes users to their specific Autostart settings to prevent your app from being killed.
- **All-in-One Permissions:** Request battery optimization ignores and notifications in one single line of code.
- **Cross-Platform:** Works flawlessly on both Android and iOS.

## 📦 Installation

Add `robust_background_service` to your `pubspec.yaml`:

```yaml
dependencies:
  robust_background_service: ^0.0.1
```

## 🛠️ Usage

### 1. Define your background logic
Create a top-level function annotated with `@pragma('vm:entry-point')`. Use the provided `runPeriodicTask` for a frictionless setup.

```dart
import 'package:robust_background_service/robust_background_service.dart';

@pragma('vm:entry-point')
void myBackgroundLogicBlock(ServiceInstance service) {
  RobustBackgroundService.runPeriodicTask(
    service: service,
    interval: const Duration(minutes: 15),
    task: () async {
      // ---> PUT YOUR API CALLS OR LOCATION LOGIC HERE <---
      print("RobustBackgroundService: Task executed flawlessly!");
    },
  );
}
```

### 2. Request Permissions (Android)
Before starting the service, request the necessary OEM and battery optimization permissions:

```dart
await RobustBackgroundService.requestAllBackgroundPermissions();
```

### 3. Start the Service
Initialize the background service and pass your logic block:

```dart
await RobustBackgroundService.initialize(
  notificationTitle: "App Running",
  notificationContent: "Tracking is running in the background",
  onStart: myBackgroundLogicBlock, 
);
```

### Stop the Service
```dart
await RobustBackgroundService.stop();
```

## 📱 OEM Device Support
This package includes custom method channels that intelligently identify the device manufacturer and deep-link the user directly to the hidden Autostart settings page for:
- Xiaomi / Redmi / Poco
- Samsung
- Oppo / Realme
- Vivo / iQOO
- Huawei / Honor
- OnePlus
- Tecno

Check out the `example` folder for a complete runnable app!
