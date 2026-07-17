import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('tapBody (issue #50)', () {
    testWidgets(
      'tapBodyToExpand expands a standalone panel when the body is tapped',
      (tester) async {
        final controller = ExpandableController();
        addTearDown(controller.dispose);
        const bodyKey = Key('collapsed-body');

        await tester.pumpWidget(
          _host(
            ExpandablePanel(
              controller: controller,
              theme: const ExpandableThemeData(tapBodyToExpand: true),
              collapsed: Container(
                key: bodyKey,
                width: 200,
                height: 60,
                color: const Color(0xFFB0BEC5),
              ),
              expanded: Container(
                width: 200,
                height: 200,
                color: const Color(0xFF90A4AE),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.expanded, isFalse);
        await tester.tap(find.byKey(bodyKey));
        await tester.pumpAndSettle();
        expect(controller.expanded, isTrue);
      },
    );

    testWidgets('tapBodyToExpand works inside an ExpandableNotifier too', (
      tester,
    ) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      const bodyKey = Key('collapsed-body');

      await tester.pumpWidget(
        _host(
          ExpandableNotifier(
            controller: controller,
            child: ExpandablePanel(
              theme: const ExpandableThemeData(tapBodyToExpand: true),
              collapsed: Container(
                key: bodyKey,
                width: 200,
                height: 60,
                color: const Color(0xFFB0BEC5),
              ),
              expanded: Container(
                width: 200,
                height: 200,
                color: const Color(0xFF90A4AE),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(bodyKey));
      await tester.pumpAndSettle();
      expect(controller.expanded, isTrue);
    });

    testWidgets(
      'tapBodyToCollapse collapses when the expanded body is tapped',
      (tester) async {
        final controller = ExpandableController(initialExpanded: true);
        addTearDown(controller.dispose);
        const bodyKey = Key('expanded-body');

        await tester.pumpWidget(
          _host(
            ExpandablePanel(
              controller: controller,
              theme: const ExpandableThemeData(tapBodyToCollapse: true),
              collapsed: Container(
                width: 200,
                height: 60,
                color: const Color(0xFFB0BEC5),
              ),
              expanded: Container(
                key: bodyKey,
                width: 200,
                height: 200,
                color: const Color(0xFF90A4AE),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.expanded, isTrue);
        await tester.tap(find.byKey(bodyKey));
        await tester.pumpAndSettle();
        expect(controller.expanded, isFalse);
      },
    );

    testWidgets('the body does not toggle when tap options are off', (
      tester,
    ) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);
      const bodyKey = Key('collapsed-body');

      await tester.pumpWidget(
        _host(
          ExpandablePanel(
            controller: controller,
            collapsed: Container(
              key: bodyKey,
              width: 200,
              height: 60,
              color: const Color(0xFFB0BEC5),
            ),
            expanded: Container(
              width: 200,
              height: 200,
              color: const Color(0xFF90A4AE),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(bodyKey));
      await tester.pumpAndSettle();
      expect(controller.expanded, isFalse);
    });
  });

  group('headerPadding (issue #72)', () {
    testWidgets('the default keeps the header without surrounding padding', (
      tester,
    ) async {
      const headerKey = Key('header');
      await tester.pumpWidget(
        _host(
          ExpandablePanel(
            theme: const ExpandableThemeData(
              hasIcon: false,
              tapHeaderToExpand: false,
            ),
            header: const SizedBox(key: headerKey, width: 100, height: 20),
            collapsed: const SizedBox(height: 10),
            expanded: const SizedBox(height: 40),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byKey(headerKey), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, EdgeInsets.zero);
    });

    testWidgets('a non-zero headerPadding is threaded into the header', (
      tester,
    ) async {
      const headerKey = Key('header');
      await tester.pumpWidget(
        _host(
          ExpandablePanel(
            theme: const ExpandableThemeData(
              hasIcon: false,
              tapHeaderToExpand: false,
              headerPadding: EdgeInsets.all(16),
            ),
            header: const SizedBox(key: headerKey, width: 100, height: 20),
            collapsed: const SizedBox(height: 10),
            expanded: const SizedBox(height: 40),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byKey(headerKey), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, const EdgeInsets.all(16));
    });
  });

  group('ExpandablePanel structure', () {
    testWidgets('tapping the header toggles the panel', (tester) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          ExpandablePanel(
            controller: controller,
            header: const Text('Header'),
            collapsed: const Text('Summary'),
            expanded: const Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Header'));
      await tester.pumpAndSettle();
      expect(controller.expanded, isTrue);
    });

    testWidgets('hasIcon controls whether an icon is shown', (tester) async {
      await tester.pumpWidget(
        _host(
          const ExpandablePanel(
            header: Text('Header'),
            collapsed: Text('Summary'),
            expanded: Text('Body'),
          ),
        ),
      );
      expect(find.byType(ExpandableIcon), findsOneWidget);

      await tester.pumpWidget(
        _host(
          const ExpandablePanel(
            theme: ExpandableThemeData(hasIcon: false),
            header: Text('Header'),
            collapsed: Text('Summary'),
            expanded: Text('Body'),
          ),
        ),
      );
      expect(find.byType(ExpandableIcon), findsNothing);
    });

    testWidgets('iconPlacement moves the icon to the requested side', (
      tester,
    ) async {
      const headerKey = Key('header');

      await tester.pumpWidget(
        _host(
          const ExpandablePanel(
            theme: ExpandableThemeData(
              iconPlacement: ExpandablePanelIconPlacement.right,
            ),
            header: SizedBox(key: headerKey, width: 100, height: 20),
            collapsed: SizedBox(height: 10),
            expanded: SizedBox(height: 40),
          ),
        ),
      );
      final headerRight = tester.getTopLeft(find.byKey(headerKey)).dx;
      final iconRight = tester.getTopLeft(find.byType(ExpandableIcon)).dx;
      expect(iconRight, greaterThan(headerRight));

      await tester.pumpWidget(
        _host(
          const ExpandablePanel(
            theme: ExpandableThemeData(
              iconPlacement: ExpandablePanelIconPlacement.left,
            ),
            header: SizedBox(key: headerKey, width: 100, height: 20),
            collapsed: SizedBox(height: 10),
            expanded: SizedBox(height: 40),
          ),
        ),
      );
      final headerLeft = tester.getTopLeft(find.byKey(headerKey)).dx;
      final iconLeft = tester.getTopLeft(find.byType(ExpandableIcon)).dx;
      expect(iconLeft, lessThan(headerLeft));
    });

    testWidgets('a panel without a controller creates its own notifier', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const ExpandablePanel(
            header: Text('Header'),
            collapsed: Text('Summary'),
            expanded: Text('Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ExpandableNotifier), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('a custom builder is used for the body', (tester) async {
      const markerKey = Key('custom-builder');
      await tester.pumpWidget(
        _host(
          ExpandablePanel(
            header: const Text('Header'),
            collapsed: const Text('Summary'),
            expanded: const Text('Body'),
            builder: (context, collapsed, expanded) {
              return Column(key: markerKey, children: [collapsed, expanded]);
            },
          ),
        ),
      );
      expect(find.byKey(markerKey), findsOneWidget);
    });
  });

  group('cross-fade state', () {
    testWidgets('collapsed shows the first child, expanded the second', (
      tester,
    ) async {
      final controller = ExpandableController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          ExpandableNotifier(
            controller: controller,
            child: const Expandable(
              collapsed: Text('Summary'),
              expanded: Text('Body'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      AnimatedCrossFade crossFade() =>
          tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade().crossFadeState, CrossFadeState.showFirst);

      controller.expanded = true;
      await tester.pumpAndSettle();
      expect(crossFade().crossFadeState, CrossFadeState.showSecond);
    });
  });

  group('theme inheritance', () {
    testWidgets('ExpandableTheme propagates the icon color', (tester) async {
      await tester.pumpWidget(
        _host(
          ExpandableTheme(
            data: const ExpandableThemeData(iconColor: Color(0xFFFF0000)),
            child: const ExpandablePanel(
              header: Text('Header'),
              collapsed: Text('Summary'),
              expanded: Text('Body'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, const Color(0xFFFF0000));
    });
  });
}
