import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Widget _panel(ExpandableController controller, {ExpandableThemeData? theme}) =>
    ExpandablePanel(
      controller: controller,
      theme: theme,
      header: const Text('Details'),
      collapsed: const Text('Summary'),
      expanded: const Text('Everything'),
    );

void main() {
  group('header semantics', () {
    testWidgets('announces itself as a button that is collapsed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_host(_panel(controller)));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(ExpandableButton).first),
        isSemantics(
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('flips to expanded when the header is tapped', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_host(_panel(controller)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(controller.expanded, isTrue);
      // The point of the flag: the announcement changes with the state, so a
      // screen reader user hears the result of their own tap.
      expect(
        tester.getSemantics(find.byType(ExpandableButton).first),
        isSemantics(
          isButton: true,
          hasExpandedState: true,
          isExpanded: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('follows the controller when it is changed programmatically', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final controller = ExpandableController(initialExpanded: true);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_host(_panel(controller)));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(ExpandableButton).first),
        isSemantics(isExpanded: true),
      );

      controller.value = false;
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(ExpandableButton).first),
        isSemantics(isExpanded: false),
      );
      handle.dispose();
    });

    testWidgets('works without the ink well too', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          _panel(
            controller,
            theme: const ExpandableThemeData(useInkWell: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(ExpandableButton).first),
        isSemantics(
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('a standalone ExpandableButton carries the same semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          ExpandableNotifier(
            controller: controller,
            child: const ExpandableButton(child: Text('Toggle')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(ExpandableButton)),
        isSemantics(isButton: true, isExpanded: false),
      );

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(ExpandableButton)),
        isSemantics(isExpanded: true),
      );
      handle.dispose();
    });
  });
}
