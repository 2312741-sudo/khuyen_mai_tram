import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../providers/auth_provider.dart';
import '../../../app/router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Safety fallback timer: force navigation after 2.5s maximum
    _timeoutTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!_hasNavigated && mounted) {
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser != null) {
          final role = ref.read(authProvider).user?.role ?? KmtRole.owner;
          _navigateTo(role == KmtRole.owner ? AppRoutes.ownerDashboard : AppRoutes.staffHome);
        } else {
          _navigateTo(AppRoutes.login);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated || !mounted) return;

    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateTo(AppRoutes.login);
        return;
      }

      await ref.read(authProvider.notifier).checkAuth();
      if (!mounted || _hasNavigated) return;

      final state = ref.read(authProvider);
      final role = state.user?.role ?? KmtRole.owner;
      if (role == KmtRole.owner) {
        _navigateTo(AppRoutes.ownerDashboard);
      } else {
        _navigateTo(AppRoutes.staffHome);
      }
    } catch (e) {
      debugPrint('SplashScreen auth error: $e');
      if (mounted && !_hasNavigated) {
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser != null) {
          _navigateTo(AppRoutes.ownerDashboard);
        } else {
          _navigateTo(AppRoutes.login);
        }
      }
    }
  }

  void _navigateTo(String route) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timeoutTimer?.cancel();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo from Chấm Công Trạm with error fallback
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110,
                        height: 110,
                        color: AppColors.white,
                        child: const Icon(
                          Icons.card_giftcard_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Title
              const Text(
                'Khuyến Mãi Trạm',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Hệ sinh thái Trạm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Loading Indicator
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
