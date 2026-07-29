import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/alarm_configuration.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../services/voice/voice_assistant_service.dart';

class VoiceAssistantModal extends ConsumerStatefulWidget {
  const VoiceAssistantModal({super.key});

  @override
  ConsumerState<VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends ConsumerState<VoiceAssistantModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _userTranscript = '';
  String _aiResponse = '';
  bool _isProcessing = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start listening on modal open
    Future.microtask(() => _startListening());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final voiceService = ref.read(voiceAssistantServiceProvider);
    setState(() {
      _isListening = true;
      _userTranscript = 'Listening... Speak your command!';
      _aiResponse = '';
      _isProcessing = false;
    });

    await voiceService.listen(
      onResult: (text) {
        setState(() {
          _userTranscript = text;
        });
      },
      onComplete: () {
        if (mounted && _isListening) {
          _processCommand(_userTranscript);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    final voiceService = ref.read(voiceAssistantServiceProvider);
    await voiceService.stopListening();
    setState(() {
      _isListening = false;
    });
    if (_userTranscript.isNotEmpty && _userTranscript != 'Listening... Speak your command!') {
      _processCommand(_userTranscript);
    }
  }

  Future<void> _processCommand(String text) async {
    if (_isProcessing) return;
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    final voiceService = ref.read(voiceAssistantServiceProvider);
    final savedPlaces = ref.read(savedPlacesProvider);

    final VoiceCommandResult result = await voiceService.processVoiceCommand(
      voiceInput: text,
      savedPlaces: savedPlaces,
    );

    if (mounted) {
      setState(() {
        _userTranscript = result.userQuery;
        _aiResponse = result.aiResponse;
        _isProcessing = false;
      });

      if (result.success) {
        if (result.isCancelCommand) {
          ref.read(activeJourneyProvider.notifier).stopJourney();
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.pop(context);
        } else if (result.targetDestination != null) {
          final config = AlarmConfiguration(
            leadDistanceKm: result.leadDistanceMeters / 1000.0,
          );

          ref.read(activeJourneyProvider.notifier).startJourney(
                result.targetDestination!,
                config: config,
              );

          await Future.delayed(const Duration(milliseconds: 2400));
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 ${result.aiResponse}'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Buddy Voice AI Assistant',
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Say "Hey buddy set alarm for Home" or "Set alert for Office"',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline, fontSize: 12),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Animated Mic Wave Visualizer Button
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [AppColors.primaryContainer, AppColors.secondary]
                            : [AppColors.primaryFixedDim, AppColors.primaryContainer],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? AppColors.primaryContainer : AppColors.secondary)
                              .withValues(alpha: 0.5),
                          blurRadius: _isListening ? 28 : 12,
                          spreadRadius: _isListening ? 6 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Status & Live Transcript Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainer,
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  _userTranscript.isEmpty
                      ? 'Tap mic and say: "Set alarm for Home"'
                      : '"$_userTranscript"',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isListening ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
                if (_isProcessing) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ],
              ],
            ),
          ),

          // AI Voice Speech Response Card
          if (_aiResponse.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderXl,
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_rounded, color: AppColors.success, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _aiResponse,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Quick Command Chips
          Text(
            'QUICK VOICE COMMANDS',
            style: AppTypography.labelMd.copyWith(
              color: AppColors.outline,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickChip('Hey buddy set alarm for Home'),
              _buildQuickChip('Set alert for Office'),
              _buildQuickChip('Set alarm for 2 km'),
              _buildQuickChip('Cancel alarm'),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String command) {
    return ActionChip(
      avatar: const Icon(Icons.record_voice_over_rounded, size: 14, color: AppColors.primaryContainer),
      label: Text(command, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.12),
      side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      onPressed: () {
        setState(() {
          _userTranscript = command;
        });
        _processCommand(command);
      },
    );
  }
}
