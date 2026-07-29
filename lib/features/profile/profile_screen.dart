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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile & Cloud Settings',
          style: AppTypography.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
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
                // User Profile Avatar & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.surfaceSecondary,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person_rounded, size: 50, color: AppColors.primary)
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        user?.displayName ?? (user?.isAnonymous == true ? 'Guest Traveler' : 'Transit Traveler'),
                        style: AppTypography.hero.copyWith(fontSize: 22, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Google Cloud Sync Active',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.success),
                            const SizedBox(width: 6),
                            Text(
                              user != null && !user.isAnonymous
                                  ? 'Google Account Connected'
                                  : 'Firestore User Database Active',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
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

                // Google Auth Action Button
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

                // Statistics Grid Cards
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
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Alarms Woken',
                        value: '${history.length}',
                        icon: Icons.alarm_on_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.thinBorder),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storage_rounded, color: AppColors.primary),
                        title: const Text('Cloud Firestore User Database', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text('ID: ${user?.uid ?? "Anonymous"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                      ),
                      const Divider(height: 1, color: AppColors.thinBorder),
                      ListTile(
                        leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
                        title: const Text('Journey Simulator (Developer Mode)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Simulate transit progress & route deviation', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SimulationDrawer(),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.thinBorder),
                      ListTile(
                        leading: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                        title: const Text('Smart Alert Calibration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Adjust lead time algorithm sensitivity', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // Clearance for bottom navigation dock
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.thinBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 2),
          Text(title, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
