@Tags(['golden'])
library;

import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _goldenPanel({required bool expanded}) {
  final controller = ExpandableController(initialExpanded: expanded);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: SizedBox(
          width: 300,
          child: ExpandablePanel(
            controller: controller,
            theme: const ExpandableThemeData(
              iconColor: Color(0xFF1E88E5),
              headerAlignment: ExpandablePanelHeaderAlignment.center,
            ),
            header: Container(height: 40, color: const Color(0xFF90CAF9)),
            collapsed: Container(height: 30, color: const Color(0xFFC8E6C9)),
            expanded: Container(height: 120, color: const Color(0xFFA5D6A7)),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('goldens', () {
    testWidgets('collapsed panel matches its golden', (tester) async {
      await tester.pumpWidget(_goldenPanel(expanded: false));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExpandablePanel),
        matchesGoldenFile('goldens/panel_collapsed.png'),
      );
    });

    testWidgets('expanded panel matches its golden', (tester) async {
      await tester.pumpWidget(_goldenPanel(expanded: true));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExpandablePanel),
        matchesGoldenFile('goldens/panel_expanded.png'),
      );
    });
  });
}
