import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/staff/screens/staff_home_screen.dart';
import '../features/staff/screens/customer_detail_screen.dart';
import '../features/owner/screens/owner_dashboard_screen.dart';
import '../features/owner/screens/import_excel_screen.dart';
import '../features/owner/screens/customer_list_screen.dart';
import '../features/owner/screens/owner_customer_detail_screen.dart';
import '../features/owner/screens/staff_management_screen.dart';
import '../features/owner/screens/history_report_screen.dart';
import '../features/owner/screens/owner_shell.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/splash';
  static const String login = '/login';
  static const String staffHome = '/staff';
  static const String staffCustomerDetail = '/staff/customer/:id';
  static const String ownerDashboard = '/owner';
  static const String ownerImport = '/owner/import/:storeId';
  static const String ownerCustomers = '/owner/customers';
  static const String ownerCustomerDetail = '/owner/customer/:id';
  static const String ownerStaff = '/owner/staff';
  static const String ownerHistory = '/owner/history';
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() { _subscription.cancel(); super.dispose(); }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      final isAuthenticated = authState.isAuthenticated || FirebaseAuth.instance.currentUser != null;
      final isLoginPage = currentPath == AppRoutes.login;
      final isSplashPage = currentPath == AppRoutes.splash;

      // If unauthenticated and not on public splash or login, go to login
      if (!isAuthenticated && !isLoginPage && !isSplashPage) {
        return AppRoutes.login;
      }

      // If authenticated and on login or splash, redirect to appropriate home
      if (isAuthenticated && (isLoginPage || isSplashPage)) {
        final role = authState.user?.role ?? KmtRole.owner;
        if (role == KmtRole.owner) {
          return AppRoutes.ownerDashboard;
        } else {
          return AppRoutes.staffHome;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      // Staff routes
      GoRoute(
        path: AppRoutes.staffHome,
        builder: (_, __) => const StaffHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffCustomerDetail,
        builder: (_, state) => CustomerDetailScreen(
          customerId: state.pathParameters['id']!,
        ),
      ),
      // Owner routes with shell (sidebar)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => OwnerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.ownerDashboard,
            builder: (_, __) => const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.ownerImport,
            builder: (_, state) => ImportExcelScreen(
              storeId: state.pathParameters['storeId']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.ownerCustomers,
            builder: (_, __) => const CustomerListScreen(),
          ),
          GoRoute(
            path: AppRoutes.ownerCustomerDetail,
            builder: (_, state) => OwnerCustomerDetailScreen(
              customerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.ownerStaff,
            builder: (_, __) => const StaffManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.ownerHistory,
            builder: (_, __) => const HistoryReportScreen(),
          ),
        ],
      ),
    ],
  );
});
