import '../../shared/models/journey_feedback.dart';

class FeedbackAdaptationService {
  const FeedbackAdaptationService();

  /// Calculates adjusted lead time offset in minutes based on historical feedback history
  int calculateLeadOffsetMinutes(List<JourneyFeedback> history) {
    if (history.isEmpty) return 0;

    int offset = 0;
    for (final feedback in history) {
      switch (feedback.timing) {
        case AlertTimingFeedback.tooEarly:
          offset -= 1; // Reduce lead time by 1 min
          break;
        case AlertTimingFeedback.tooLate:
          offset += 2; // Increase lead time by 2 mins
          break;
        case AlertTimingFeedback.perfect:
          break;
      }
    }

    // Clamp total offset between -5 and +10 minutes
    return offset.clamp(-5, 10);
  }
}
