import 'package:flutter/material.dart';

import 'dart:async';

import 'package:robust_background_service/robust_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// =========================================================================
// 1. THIS IS THE USER'S CUSTOM BACKGROUND LOGIC BLOCK
// =========================================================================
// This MUST be a top-level function annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
void myBackgroundLogicBlock(ServiceInstance service) {
  int executionCount = 0;

  // 💥 NEW: Ultra-simple implementation!
  // No need for Timers, stop listeners, or WidgetsFlutterBinding boilerplate!
  RobustBackgroundService.runPeriodicTask(
    service: service,
    interval: const Duration(seconds: 30),
    task: () async {
      executionCount++;
      // ---> PUT YOUR API CALLS OR LOCATION LOGIC HERE <---
      debugPrint("RobustBackgroundService: Background task executed $executionCount time(s) flawlessly!");
    },
  );
}
// =========================================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    bool running = await RobustBackgroundService.isRunning();
    setState(() {
      isRunning = running;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Robust Background Service')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isRunning ? "Service is RUNNING" : "Service is STOPPED",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isRunning ? Colors.green : Colors.red),
              ),
              const SizedBox(height: 40),

              // Button 1: Request OEM Permissions
              ElevatedButton.icon(
                onPressed: () async {
                  // This requests Battery Optimization ignore AND AutoStart for Xiaomi/Samsung/Oppo
                  await RobustBackgroundService.requestAllBackgroundPermissions();
                },
                icon: const Icon(Icons.security),
                label: const Text('Request OEM Background Permissions'),
              ),

              const SizedBox(height: 20),

              // Button 2: Start the Logic Block
              ElevatedButton.icon(
                onPressed: () async {
                  if (isRunning) {
                    await RobustBackgroundService.stop();
                  } else {
                    // Initialize and pass the top-level block
                    await RobustBackgroundService.initialize(
                      notificationTitle: "My Example App",
                      notificationContent: "Tracking is running in the background",
                      onStart: myBackgroundLogicBlock, // <--- PASSING THE LOGIC BLOCK HERE
                    );
                  }

                  // Wait a moment for service to start/stop
                  await Future.delayed(const Duration(seconds: 1));
                  _checkServiceStatus();
                },
                icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(isRunning ? 'Stop Service' : 'Start Background Logic Block'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
