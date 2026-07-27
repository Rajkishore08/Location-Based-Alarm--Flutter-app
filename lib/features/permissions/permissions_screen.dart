import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_buttons.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _hasLocationPermission = false;
  bool _hasNotificationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await ref.read(locationServiceProvider).checkPermissionStatus();
    setState(() {
      _hasLocationPermission = status == LocationPermission.always || status == LocationPermission.whileInUse;
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await ref.read(locationServiceProvider).requestPermission();
    setState(() {
      _hasLocationPermission = status == LocationPermission.always || status == LocationPermission.whileInUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.inverseSurface : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Title & Subtitle Header
              Text(
                'A few permissions before your journey',
                style: AppTypography.headlineLgMobile.copyWith(
                  color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'To keep your commute safe and on-track, we need access to a few things.',
                style: AppTypography.bodyLg.copyWith(
                  color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Permissions Stack List
              Expanded(
                child: ListView(
                  children: [
                    // 1. Location Access (ACTIVE Example)
                    _buildPermissionCard(
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      iconBgColor: AppColors.success.withValues(alpha: 0.15),
                      title: 'Location Access',
                      description: 'Required to track journey.',
                      badgeText: _hasLocationPermission ? 'ACTIVE' : null,
                      badgeColor: AppColors.success,
                      isGranted: _hasLocationPermission,
                      onTap: _requestLocationPermission,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Background Location
                    _buildPermissionCard(
                      icon: Icons.near_me_rounded,
                      iconColor: AppColors.primaryContainer,
                      iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                      title: 'Background Location',
                      description: 'Allows monitoring when phone is locked or you\'re using other apps.',
                      hasLeftBorder: true,
                      buttonText: 'Enable',
                      isGranted: _hasLocationPermission,
                      onTap: _requestLocationPermission,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Notifications
                    _buildPermissionCard(
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppColors.secondary,
                      iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
                      title: 'Notifications',
                      description: 'Required to send real-time route alerts.',
                      buttonText: 'Enable',
                      isGranted: _hasNotificationPermission,
                      onTap: () => setState(() => _hasNotificationPermission = true),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Battery Optimization
                    _buildPermissionCard(
                      icon: Icons.battery_charging_full_rounded,
                      iconColor: AppColors.tertiary,
                      iconBgColor: AppColors.tertiary.withValues(alpha: 0.1),
                      title: 'Battery Optimization',
                      description: 'Keep the app active during long trips.',
                      buttonText: 'Configure',
                      isGranted: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressSegment(true),
                  _buildProgressSegment(true),
                  _buildProgressSegment(true, isLong: true),
                  _buildProgressSegment(false),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Bottom Primary Action
              AppPrimaryButton(
                text: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    String? badgeText,
    Color? badgeColor,
    String? buttonText,
    bool hasLeftBorder = false,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadius.borderXl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isDark ? AppColors.glassBorderDark : AppColors.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (hasLeftBorder)
                Container(
                  width: 4,
                  color: AppColors.primaryContainer,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: AppRadius.borderLg,
                        ),
                        child: Icon(icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: AppTypography.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                                  ),
                                ),
                                if (badgeText != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (badgeColor ?? AppColors.success).withValues(alpha: 0.15),
                                      borderRadius: AppRadius.borderFull,
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: AppTypography.labelMd.copyWith(
                                        color: badgeColor ?? AppColors.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: AppTypography.bodyMd.copyWith(
                                color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (buttonText != null && !isGranted) ...[
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
                            ),
                            child: Text(buttonText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment(bool isFilled, {bool isLong = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isLong ? 32 : 20,
      height: 4,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primaryContainer : AppColors.outlineVariant.withValues(alpha: 0.4),
        borderRadius: AppRadius.borderFull,
      ),
    );
  }
}
