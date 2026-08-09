import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every build and every `initState` of its subtree.
class _Tracked extends StatefulWidget {
  const _Tracked({required this.builds, required this.inits});
  final List<int> builds;
  final List<int> inits;

  @override
  State<_Tracked> createState() => _TrackedState();
}

class _TrackedState extends State<_Tracked> {
  @override
  void initState() {
    super.initState();
    widget.inits.add(1);
  }

  @override
  Widget build(BuildContext context) {
    widget.builds.add(1);
    return const SizedBox(height: 40, child: Text('body'));
  }
}

Widget _list({
  required bool lazy,
  required List<int> builds,
  required List<int> inits,
  int count = 20,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ListView(
        children: List.generate(
          count,
          (i) => ExpandablePanel(
            lazy: lazy,
            header: Text('Section $i'),
            collapsed: const SizedBox(height: 20),
            expanded: _Tracked(builds: builds, inits: inits),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('collapsed panels build their expanded body without lazy', (
    tester,
  ) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(_list(lazy: false, builds: builds, inits: inits));
    // This is the cost the fix removes, pinned so a regression is visible.
    expect(builds.length, 15);
    expect(inits.length, 15);
  });

  testWidgets('the default is eager, with nothing passed', (tester) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: List.generate(
              20,
              // No lazy argument at all: this pins the default, so flipping it
              // turns into a failing test rather than a silent behaviour change
              // for everyone already on the package.
              (i) => ExpandablePanel(
                header: Text('Section $i'),
                collapsed: const SizedBox(height: 20),
                expanded: _Tracked(builds: builds, inits: inits),
              ),
            ),
          ),
        ),
      ),
    );
    expect(inits.length, 15);
  });

  test('Expandable defaults lazy to false', () {
    expect(
      const Expandable(
        collapsed: SizedBox.shrink(),
        expanded: SizedBox.shrink(),
      ).lazy,
      isFalse,
    );
  });

  testWidgets('lazy builds none of them', (tester) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(_list(lazy: true, builds: builds, inits: inits));
    expect(builds, isEmpty);
    expect(inits, isEmpty);
  });

  testWidgets('the body appears when the panel opens, and stays after it '
      'closes', (tester) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(
      _list(lazy: true, builds: builds, inits: inits, count: 1),
    );
    expect(find.text('body'), findsNothing);

    await tester.tap(find.text('Section 0'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
    expect(inits.length, 1);

    // Closing keeps the child alive: no second initState when it reopens, so
    // whatever state it holds survives the round trip.
    await tester.tap(find.text('Section 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Section 0'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
    expect(inits.length, 1);
  });

  testWidgets('a panel that starts open builds its body on the first frame', (
    tester,
  ) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableNotifier(
            initialExpanded: true,
            child: ExpandablePanel(
              lazy: true,
              header: const Text('Section'),
              collapsed: const SizedBox(height: 20),
              expanded: _Tracked(builds: builds, inits: inits),
            ),
          ),
        ),
      ),
    );
    expect(find.text('body'), findsOneWidget);
    expect(inits.length, 1);
  });

  testWidgets('the animation never shows the placeholder', (tester) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(
      _list(lazy: true, builds: builds, inits: inits, count: 1),
    );
    await tester.tap(find.text('Section 0'));
    // One frame into the cross-fade the real child has to be in the tree
    // already, or the transition would animate an empty box.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('body'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('lazy is ignored when a builder supplies the layout', (
    tester,
  ) async {
    final builds = <int>[], inits = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandablePanel(
            lazy: true,
            header: const Text('Section'),
            collapsed: const SizedBox(height: 20),
            expanded: _Tracked(builds: builds, inits: inits),
            builder: (context, collapsed, expanded) =>
                Column(children: [collapsed, expanded]),
          ),
        ),
      ),
    );
    // The builder put both children in the tree itself, which is documented.
    expect(inits.length, 1);
  });
}
