import 'dart:ui';
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start speech recognition on open
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
      _userTranscript = 'Listening to your speech... Speak clearly!';
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
    if (_userTranscript.isNotEmpty && !_userTranscript.startsWith('Listening')) {
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

          await Future.delayed(const Duration(milliseconds: 2200));
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚡ ${result.aiResponse}'),
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.thinBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 40,
                offset: Offset(0, -12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Perplexity AI Command Center',
                    style: AppTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Natural Language Intent Engine',
                style: AppTypography.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Multi-Color Pulsing AI Intelligence Orb
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
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: _isListening ? 0.65 : 0.3),
                              blurRadius: _isListening ? 36 : 18,
                              spreadRadius: _isListening ? 8 : 2,
                            ),
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: _isListening ? 0.45 : 0.2),
                              blurRadius: _isListening ? 48 : 24,
                              spreadRadius: _isListening ? 12 : 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Live Transcription Glass Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.thinBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      _userTranscript.isEmpty
                          ? 'Tap mic and say: "Wake me before my stop"'
                          : '"$_userTranscript"',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isListening ? AppColors.success : Colors.white,
                      ),
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.success),
                      ),
                    ],
                  ],
                ),
              ),

              // AI Voice Spoken Response Card
              if (_aiResponse.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.smart_toy_rounded, color: AppColors.success, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _aiResponse,
                          style: AppTypography.body.copyWith(
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

              // Requested AI Prompt Chips
              Text(
                'SUGGESTED PROMPTS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildPromptChip('Wake me before my stop'),
                  _buildPromptChip('Alert me near office'),
                  _buildPromptChip('Navigate to Airport'),
                  _buildPromptChip('Find nearest EV station'),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(String command) {
    return ActionChip(
      avatar: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accent),
      label: Text(command, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      backgroundColor: AppColors.surfaceSecondary,
      side: const BorderSide(color: AppColors.thinBorder),
      onPressed: () {
        setState(() {
          _userTranscript = command;
        });
        _processCommand(command);
      },
    );
  }
}
