import 'package:flutter_test/flutter_test.dart';
import 'package:robust_background_service/robust_background_service.dart';
import 'package:robust_background_service/robust_background_service_platform_interface.dart';
import 'package:robust_background_service/robust_background_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRobustBackgroundServicePlatform
    with MockPlatformInterfaceMixin
    implements RobustBackgroundServicePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RobustBackgroundServicePlatform initialPlatform = RobustBackgroundServicePlatform.instance;

  test('$MethodChannelRobustBackgroundService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRobustBackgroundService>());
  });

  test('getPlatformVersion', () async {
    RobustBackgroundService robustBackgroundServicePlugin = RobustBackgroundService();
    MockRobustBackgroundServicePlatform fakePlatform = MockRobustBackgroundServicePlatform();
    RobustBackgroundServicePlatform.instance = fakePlatform;

    expect(await robustBackgroundServicePlugin.getPlatformVersion(), '42');
  });
}
