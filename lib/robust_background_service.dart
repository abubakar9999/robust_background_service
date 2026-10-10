import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// Export ServiceInstance so package users don't need to import flutter_background_service
export 'package:flutter_background_service/flutter_background_service.dart' show ServiceInstance;

class RobustBackgroundService {
  static const MethodChannel _channel = MethodChannel('robust_background_service');

  /// Requests the user to disable battery optimizations for this app.
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;
    try {
      final bool ignoring = await _channel.invokeMethod('isIgnoringBatteryOptimizations') ?? false;
      if (!ignoring) {
        await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
      }
    } catch (e) {
      debugPrint("Error requesting battery optimization ignore: $e");
    }
  }

  /// Opens the OEM specific AutoStart settings for aggressive task killers
  /// like Xiaomi, Oppo, Vivo, Samsung, Huawei, etc.
  static Future<void> openOemAutostartSettings() async {
    if (!Platform.isAndroid) return;
    try {
      String manufacturer = await _channel.invokeMethod('getManufacturer') ?? "";
      manufacturer = manufacturer.toLowerCase();

      if (manufacturer.contains('xiaomi') ||
          manufacturer.contains('redmi') ||
          manufacturer.contains('poco') ||
          manufacturer.contains('oppo') ||
          manufacturer.contains('realme') ||
          manufacturer.contains('vivo') ||
          manufacturer.contains('iqoo') ||
          manufacturer.contains('samsung') ||
          manufacturer.contains('huawei') ||
          manufacturer.contains('oneplus') ||
          manufacturer.contains('tecno')) {
        await _channel.invokeMethod('openOemAutostartSettings');
      }
    } catch (e) {
      debugPrint("Error opening OEM settings: $e");
    }
  }

  /// Master method to request all required background permissions for advanced Androids.
  /// Call this during your app's onboarding or login.
  static Future<void> requestAllBackgroundPermissions() async {
    await Permission.notification.request();
    await requestIgnoreBatteryOptimizations();
    await Future.delayed(const Duration(seconds: 2));
    await openOemAutostartSettings();
  }

  /// =========================================================================
  /// INITIALIZE THE BACKGROUND SERVICE
  /// =========================================================================
  /// This is where you pass your custom logic!
  /// 
  /// The [onStart] parameter is the "block" where you put your background code.
  /// IMPORTANT: The function you pass to [onStart] MUST be a top-level function 
  /// or a static method, and it MUST have the `@pragma('vm:entry-point')` annotation.
  /// 
  /// Example Usage:
  /// ```dart
  /// await RobustBackgroundService.initialize(
  ///   onStart: myCustomBackgroundLogic, // <-- Pass your logic block here
  /// );
  /// ```
  static Future<void> initialize({
    required Function(ServiceInstance service) onStart,
    String notificationChannelId = 'robust_bg_channel',
    String notificationTitle = 'Background Service Active',
    String notificationContent = 'App is running in the background',
    int notificationId = 888,
  }) async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'robust_bg_channel',
      'Robust Background Service',
      description: 'Used for executing robust background tasks.',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: notificationTitle,
        initialNotificationContent: notificationContent,
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: _iosBackgroundProxy,
      ),
    );

    await service.startService();
  }

  /// =========================================================================
  /// ISOLATE BOILERPLATE HELPER
  /// =========================================================================
  /// Call this INSIDE your top-level [onStart] function to instantly set up
  /// a repeating background task without dealing with Timers or stop listeners!
  /// 
  /// Example:
  /// ```dart
  /// @pragma('vm:entry-point')
  /// void myBackgroundBlock(ServiceInstance service) {
  ///   RobustBackgroundService.runPeriodicTask(
  ///     service: service,
  ///     interval: const Duration(minutes: 1),
  ///     task: () async {
  ///       print("I am running in the background!");
  ///     },
  ///   );
  /// }
  /// ```
  static void runPeriodicTask({
    required ServiceInstance service,
    required Duration interval,
    required Future<void> Function() task,
  }) {
    WidgetsFlutterBinding.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    // Automatically handle stop events
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Future<void> executeTask() async {
      await task();
      // Automatically update the notification to show the service is alive
      if (service is AndroidServiceInstance) {
        final now = DateTime.now();
        final timeString = "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
        service.setForegroundNotificationInfo(
          title: 'Background Service Active',
          content: 'Last active: $timeString',
        );
      }
    }

    // Run the task immediately once
    executeTask();

    // Then run it periodically
    Timer.periodic(interval, (timer) async {
      await executeTask();
    });
  }

  /// Stops the currently running background service.
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('stopService');
    }
  }

  /// Checks if the background service is currently running.
  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}

@pragma('vm:entry-point')
Future<bool> _iosBackgroundProxy(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
