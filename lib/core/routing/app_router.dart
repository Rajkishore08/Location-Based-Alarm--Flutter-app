import 'package:go_router/go_router.dart';

import '../../features/alarm/full_screen_alarm_screen.dart';
import '../../features/alarm_setup/destination_details_screen.dart';
import '../../features/alarm_setup/smart_alarm_setup_screen.dart';
import '../../features/arrival/destination_reached_screen.dart';
import '../../features/destination_search/destination_search_screen.dart';
import '../../features/history/journey_history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journey/active_journey_screen.dart';
import '../../features/journey/journey_started_screen.dart';
import '../../features/journey/journey_status_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/saved_places/saved_places_screen.dart';
import '../../shared/models/destination.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const DestinationSearchScreen(),
    ),
    GoRoute(
      path: '/destination',
      builder: (context, state) {
        final Destination dest = state.extra as Destination? ??
            const Destination(
              id: 'default_dest',
              name: 'Chennai Central Railway Station',
              address: 'Kannappar Thidal, Periyamet, Chennai',
              latitude: 13.0827,
              longitude: 80.2707,
            );
        return DestinationDetailsScreen(destination: dest);
      },
    ),
    GoRoute(
      path: '/alarm-setup',
      builder: (context, state) {
        final Destination dest = state.extra as Destination? ??
            const Destination(
              id: 'default_dest',
              name: 'Chennai Central Railway Station',
              address: 'Kannappar Thidal, Periyamet, Chennai',
              latitude: 13.0827,
              longitude: 80.2707,
            );
        return SmartAlarmSetupScreen(destination: dest);
      },
    ),
    GoRoute(
      path: '/journey-started',
      builder: (context, state) => const JourneyStartedScreen(),
    ),
    GoRoute(
      path: '/journey',
      builder: (context, state) => const ActiveJourneyScreen(),
    ),
    GoRoute(
      path: '/journey/status',
      builder: (context, state) => const JourneyStatusScreen(),
    ),
    GoRoute(
      path: '/alarm',
      builder: (context, state) => const FullScreenAlarmScreen(),
    ),
    GoRoute(
      path: '/arrival',
      builder: (context, state) => const DestinationReachedScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const DestinationReachedScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const JourneyHistoryScreen(),
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const SavedPlacesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
