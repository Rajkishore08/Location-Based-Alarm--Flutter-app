import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/app_buttons.dart';
import '../simulation/simulation_drawer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(journeyHistoryProvider);
    final authService = ref.watch(authServiceProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Cloud Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          final User? user = snapshot.data ?? authService.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            child: Column(
              children: [
                // User Profile Header with Google Auth Avatar
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person_rounded, size: 48, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        user?.displayName ?? (user?.isAnonymous == true ? 'Guest Traveler' : 'Transit Traveler'),
                        style: AppTypography.headlineLgMobile,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Google Cloud Sync Active',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.secondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderFull,
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              user != null && !user.isAnonymous
                                  ? 'Google Account Connected'
                                  : 'Firestore User Database Active',
                              style: AppTypography.labelMd.copyWith(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Google Auth Trigger Button
                if (user == null || user.isAnonymous) ...[
                  AppPrimaryButton(
                    text: 'Sign In with Google',
                    icon: Icons.login_rounded,
                    onPressed: () async {
                      final cred = await authService.signInWithGoogle();
                      if (cred?.user != null) {
                        await firestoreService.saveUserProfile(cred!.user!);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ] else ...[
                  AppSecondaryButton(
                    text: 'Sign Out',
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      await authService.signOut();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                const SizedBox(height: AppSpacing.md),

                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Journeys',
                        value: '${history.length}',
                        icon: Icons.explore_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Alarms Woken',
                        value: '${history.length}',
                        icon: Icons.alarm_on_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Accuracy',
                        value: '98%',
                        icon: Icons.auto_awesome_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Settings List
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.borderXl,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storage_rounded, color: AppColors.primaryContainer),
                        title: const Text('Cloud Firestore User Database'),
                        subtitle: Text('ID: ${user?.uid ?? "Anonymous"}'),
                        trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.bug_report_outlined, color: AppColors.primaryContainer),
                        title: const Text('Journey Simulator (Developer Mode)'),
                        subtitle: const Text('Simulate transit progress & route deviation'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SimulationDrawer(),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.tune_rounded, color: AppColors.primaryContainer),
                        title: const Text('Smart Alert Calibration'),
                        subtitle: const Text('Adjust lead time algorithm sensitivity'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.go('/history');
          if (idx == 2) context.go('/saved');
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.borderXl,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryContainer, size: 24),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.statsSm.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(title, style: AppTypography.labelMd.copyWith(color: AppColors.outline, fontSize: 11)),
        ],
      ),
    );
  }
}
