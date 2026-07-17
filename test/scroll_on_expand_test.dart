import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScrollOnExpand', () {
    testWidgets('renders its child and survives a state change', (
      tester,
    ) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      const childKey = Key('scroll-child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ExpandableNotifier(
                  controller: controller,
                  child: ScrollOnExpand(
                    child: ExpandablePanel(
                      key: childKey,
                      header: const Text('Header'),
                      collapsed: const SizedBox(height: 40),
                      expanded: const SizedBox(height: 400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(childKey), findsOneWidget);

      controller.expanded = true;
      // Settle past the delayed scroll callback that ScrollOnExpand schedules.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byKey(childKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      controller.expanded = false;
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });
}
