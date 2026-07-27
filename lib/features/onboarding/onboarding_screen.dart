import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = const [
    {
      'title': 'Sleep without worrying',
      'subtitle': 'Set your destination and relax. Smart Route Alert keeps track of your journey.',
      'icon': 'bedtime',
    },
    {
      'title': 'Smarter than a normal alarm',
      'subtitle': 'Your alert automatically adapts to distance, speed, direction and ETA.',
      'icon': 'auto_awesome',
    },
    {
      'title': 'Wake up at the right moment',
      'subtitle': 'Receive a powerful alarm before reaching your destination.',
      'icon': 'notifications_active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.inverseSurface : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: App Branding & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.borderLg,
                        ),
                        child: const Icon(Icons.alarm_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Smart Route Alert',
                        style: AppTypography.headlineMd.copyWith(
                          color: isDark ? AppColors.primaryFixed : AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: _currentPage == 2 ? 0.0 : 1.0,
                    child: TextButton(
                      onPressed: _currentPage == 2 ? null : () => context.go('/permissions'),
                      child: Text(
                        'Skip',
                        style: AppTypography.bodyLg.copyWith(
                          color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Carousel View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glass Illustration Card
                        Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2638)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing Halo Glow
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                _getSlideIcon(slide['icon']),
                                size: 84,
                                color: AppColors.primaryContainer,
                              ),
                              if (index == 1)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.glassDarkBg : Colors.white,
                                      borderRadius: AppRadius.borderFull,
                                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ADJUSTING TO SPEED',
                                          style: AppTypography.labelMd.copyWith(
                                            fontSize: 9,
                                            color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Title & Description
                        Text(
                          slide['title']!,
                          style: AppTypography.headlineLgMobile.copyWith(
                            color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide['subtitle']!,
                          style: AppTypography.bodyLg.copyWith(
                            color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls Area (Dot Indicators & Action Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.lg),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == idx ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == idx ? AppColors.primaryContainer : AppColors.outlineVariant,
                          borderRadius: AppRadius.borderFull,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Button
                  AppPrimaryButton(
                    text: _currentPage == 2 ? 'Get Started' : 'Next',
                    icon: _currentPage == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/permissions');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSlideIcon(String? icon) {
    switch (icon) {
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'notifications_active':
        return Icons.notifications_active_rounded;
      default:
        return Icons.bedtime_rounded;
    }
  }
}
