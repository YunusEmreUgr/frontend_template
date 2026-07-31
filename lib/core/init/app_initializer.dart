import 'package:flutter/material.dart';
import '../storage/cache_storage.dart';
import 'service_locator.dart';

class AppInitializer {
  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    WidgetsFlutterBinding.ensureInitialized();
    await CacheStorage.init();
    ServiceLocator.setup(navigatorKey);
  }
}
