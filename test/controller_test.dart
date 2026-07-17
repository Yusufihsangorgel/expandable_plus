import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableController', () {
    test('starts collapsed by default', () {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      expect(controller.expanded, isFalse);
      expect(controller.value, isFalse);
    });

    test('honours initialExpanded', () {
      final controller = ExpandableController(initialExpanded: true);
      addTearDown(controller.dispose);
      expect(controller.expanded, isTrue);
    });

    test('the expanded setter updates the value and notifies', () {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.expanded = true;
      expect(controller.value, isTrue);
      expect(notifications, 1);
    });

    test('toggle flips the state', () {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      controller.toggle();
      expect(controller.expanded, isTrue);
      controller.toggle();
      expect(controller.expanded, isFalse);
    });
  });

  group('ExpandableController.of', () {
    testWidgets('finds the controller provided by an ExpandableNotifier', (
      tester,
    ) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      late ExpandableController? found;
      await tester.pumpWidget(
        ExpandableNotifier(
          controller: controller,
          child: Builder(
            builder: (context) {
              found = ExpandableController.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(found, same(controller));
    });

    testWidgets('returns null when there is no notifier', (tester) async {
      late ExpandableController? found;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            found = ExpandableController.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(found, isNull);
    });

    testWidgets('required: true asserts when no notifier is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            ExpandableController.of(context, required: true);
            return const SizedBox();
          },
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('ExpandableNotifier', () {
    testWidgets('creates a controller from initialExpanded', (tester) async {
      late ExpandableController? found;
      await tester.pumpWidget(
        ExpandableNotifier(
          initialExpanded: true,
          child: Builder(
            builder: (context) {
              found = ExpandableController.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(found, isNotNull);
      expect(found!.expanded, isTrue);
    });
  });
}
