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

    testWidgets(
      'disposes the controller it creates for itself, unregistering it '
      'from its group',
      (tester) async {
        final group = ExpandableGroupController();
        addTearDown(group.dispose);

        await tester.pumpWidget(
          ExpandableNotifier(group: group, child: const SizedBox()),
        );
        expect(group.members.length, 1);

        // Remove the notifier from the tree; it should dispose the
        // controller it created for itself and the group should notice.
        await tester.pumpWidget(const SizedBox());
        expect(group.members.length, 0);
      },
    );

    testWidgets('does not dispose a controller supplied by the caller', (
      tester,
    ) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        ExpandableNotifier(controller: controller, child: const SizedBox()),
      );

      // Remove the notifier from the tree; a caller-supplied controller
      // stays owned by the caller, so it must still be usable.
      await tester.pumpWidget(const SizedBox());
      controller.expanded = true;
      expect(controller.expanded, isTrue);
    });
  });
}
