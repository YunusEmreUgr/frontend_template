import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/products/product_list_screen.dart';
import '../features/subscription/subscription_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/products': (_) => const ProductListScreen(),
        '/subscription': (_) => const SubscriptionScreen(),
      };
}
