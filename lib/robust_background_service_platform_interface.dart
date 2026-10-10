import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'robust_background_service_method_channel.dart';

abstract class RobustBackgroundServicePlatform extends PlatformInterface {
  /// Constructs a RobustBackgroundServicePlatform.
  RobustBackgroundServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static RobustBackgroundServicePlatform _instance = MethodChannelRobustBackgroundService();

  /// The default instance of [RobustBackgroundServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelRobustBackgroundService].
  static RobustBackgroundServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RobustBackgroundServicePlatform] when
  /// they register themselves.
  static set instance(RobustBackgroundServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
