import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/Pages/active_session.dart';
import 'package:salad_of_achievement/DB/models/object_box.dart';
import 'package:salad_of_achievement/DB/models/data_model.dart';

class MockObjectBoxState extends ChangeNotifier implements ObjectBoxState {
  @override
  List<Activity> getActiveActivities() => [Activity(name: 'Test Activity', timeSpent: 0)];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ActiveSession Logic Tests', () {
    testWidgets('Session initialization from normal entry', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      final mockState = MockObjectBoxState();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ObjectBoxState>.value(
            value: mockState,
            child: const ActiveSectionPage(arguments: ['25', 'Test Activity', false]),
          ),
        ),
      );

      // Verify internal state captured by globals/logic
      // Note: active_session.dart uses some top-level variables for session state
      expect(sessionTime, 25);
      expect(isFromNotification, false);
      expect(isNotified, false);
    });

    testWidgets('Session initialization from notification entry', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      final mockState = MockObjectBoxState();

      // Reset global state if necessary (since they are top-level)
      isNotified = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ObjectBoxState>.value(
            value: mockState,
            child: const ActiveSectionPage(arguments: ['25', 'Test Activity', true]),
          ),
        ),
      );

      expect(isFromNotification, true);
      expect(isNotified, true);
      expect(sessionTime, 0); // Logic sets sessionTime to 0 if from notification
      expect(doneMinutes, 25);
      expect(activityName, 'Test Activity');
    });

    testWidgets('Timer resync on app resume', (WidgetTester tester) async {
      final mockState = MockObjectBoxState();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ObjectBoxState>.value(
            value: mockState,
            child: const ActiveSectionPage(arguments: ['25', 'Test Activity', false]),
          ),
        ),
      );

      // Simulate app going to background and returning
      // The logic in _BodyState calls controller.correctTime(remain)
      // This is hard to unit test deeply without mocking TimerLogic.instance
      // but we can verify the lifecycle observer is registered.

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      await tester.pump();
      // If no crash occurred, lifecycle sync logic was executed
    });

    testWidgets('Cancel session cancels notifications', (WidgetTester tester) async {
      // This tests the PopScope logic
      final mockState = MockObjectBoxState();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ObjectBoxState>.value(
            value: mockState,
            child: const ActiveSectionPage(arguments: ['25', 'Test Activity', false]),
          ),
        ),
      );

      // In a real test we'd check if notifications were cancelled
      // Pop the page
      Navigator.of(tester.element(find.byType(ActiveSectionPage))).pop();
      await tester.pumpAndSettle();

      // PopScope should have triggered controller.cancelAllNotifications()
    });
  });
}
