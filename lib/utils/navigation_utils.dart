import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../services/auth_service.dart';

class NavigationUtils {
  static Future<void> navigateToReports(BuildContext context) async {
    final user = await AuthService.getCurrentUser();
    if (!context.mounted) return;

    final route = (user?.isAdmin ?? false)
        ? AppRoutes.viewReportsAdmin
        : AppRoutes.viewReports;

    Navigator.pushNamed(context, route);
  }

  static void navigateAndClearStack(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (_) => false,
      arguments: arguments,
    );
  }

  static Future<T?> navigateForResult<T>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, route, arguments: arguments);
  }
}
