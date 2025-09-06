import 'package:flutter/material.dart';
import '../../presentation/admin_login.dart';
import '../../presentation/admin_dashboard/admin_dashboard.dart';

class AdminRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static final Map<String, Widget Function(BuildContext)> routes = {
    login: (context) => const AdminLoginPage(),
    dashboard: (context) => const AdminDashboard(),
  };
}
