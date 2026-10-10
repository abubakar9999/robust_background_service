import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'robust_background_service_platform_interface.dart';

/// An implementation of [RobustBackgroundServicePlatform] that uses method channels.
class MethodChannelRobustBackgroundService extends RobustBackgroundServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('robust_background_service');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
