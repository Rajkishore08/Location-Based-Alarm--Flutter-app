import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_route_alert/app.dart';
import 'package:smart_route_alert/services/alarm/alarm_service.dart';
import 'package:smart_route_alert/services/storage/local_storage_service.dart';
import 'package:smart_route_alert/shared/providers/app_providers.dart';

void main() {
  testWidgets('App renders onboarding screen on initial launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final alarmService = AlarmService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          alarmServiceProvider.overrideWithValue(alarmService),
        ],
        child: const SmartRouteAlertApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Smart Route Alert'), findsOneWidget);
    expect(find.text('Sleep without worrying'), findsOneWidget);
  });
}
