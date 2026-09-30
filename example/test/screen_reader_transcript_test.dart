// Drives the order page and prints what a screen reader is handed at each
// step, next to the same three headers built the way `expandable` builds them.
//
//   cd example && flutter test test/screen_reader_transcript_test.dart
//
// Every line is printed after the expectation that makes it true, so the
// transcript cannot describe a state the tree is not actually in. That matters
// most for the announcement card on the page, which claims in plain text what
// a screen reader hears: the claim is checked here against the real semantics
// node before it is repeated.

import 'package:expandable_plus/expandable_plus.dart';
import 'package:expandable_plus_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const _headers = <String>['Shipping', 'Payment', 'Returns'];

void _say(String line) {
  // ignore: avoid_print
  print(line);
}

/// Gives the page room to lay out in one frame, so nothing under test is off
/// the bottom of an 800x600 default.
void _useATallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

SemanticsNode _headerNode(WidgetTester tester, String title) {
  final finder = find.ancestor(
    of: find.text(title),
    matching: find.byType(ExpandableButton),
  );
  expect(finder, findsOneWidget, reason: '$title should be one header button');
  return tester.getSemantics(finder);
}

/// Asserts the announcement for [title], then prints it.
void _readOut(
  WidgetTester tester,
  String title, {
  required bool expanded,
  String note = '',
}) {
  expect(
    _headerNode(tester, title),
    isSemantics(isButton: true, hasExpandedState: true, isExpanded: expanded),
  );
  final state = expanded ? 'expanded' : 'collapsed';
  _say(
    '  ${title.padRight(9)} button, ${state.padRight(10)} $note'.trimRight(),
  );
}

/// Checks the line the page prints about itself against the state just read
/// out of the semantics tree, then repeats it.
void _readOutTheCard(String title, {required bool expanded}) {
  final line = '"$title, button, ${expanded ? 'expanded' : 'collapsed'}"';
  expect(
    find.text(line),
    findsOneWidget,
    reason: 'the announcement card should be showing $line',
  );
  _say('  the page shows: $line');
}

String _counterLine(WidgetTester tester) {
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final data = text.data;
    if (data != null && data.startsWith('bodies built: ')) {
      return data;
    }
  }
  fail('the items card should be showing a counter');
}

int _bodiesBuilt(WidgetTester tester) {
  final match = RegExp(r'bodies built: (\d+)').firstMatch(_counterLine(tester));
  return int.parse(match!.group(1)!);
}

/// How many order lines are in the basket, read off the same counter.
int _orderLines(WidgetTester tester) {
  final match = RegExp(r'of (\d+)').firstMatch(_counterLine(tester));
  return int.parse(match!.group(1)!);
}

/// Counts order lines by the price on each header. The card's own total reads
/// `20 items, £59.85`, which starts with a digit, so it is not one of these.
///
/// [includingOffScreen] is the difference between the two numbers that matter
/// here: a `ListView` builds a little past its bottom edge, and those lines
/// cost exactly as much as the visible ones.
int _lines(WidgetTester tester, {required bool includingOffScreen}) {
  return tester
      .widgetList<Text>(find.byType(Text, skipOffstage: !includingOffScreen))
      .where((text) => (text.data ?? '').startsWith('£'))
      .length;
}

void main() {
  testWidgets('what the three headers announce, tap by tap', (tester) async {
    _useATallScreen(tester);
    // Disposed at the end of the test rather than in a tear-down: the
    // framework checks for leaked handles before tear-downs run.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    _say('on the first frame');
    _readOut(tester, 'Shipping', expanded: true);
    _readOut(tester, 'Payment', expanded: false);
    _readOut(tester, 'Returns', expanded: false);
    _readOutTheCard('Shipping', expanded: true);

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    _say('');
    _say('after tapping Payment');
    _readOut(
      tester,
      'Shipping',
      expanded: false,
      note: 'the group closed it, nobody tapped it',
    );
    _readOut(tester, 'Payment', expanded: true);
    _readOut(tester, 'Returns', expanded: false);
    _readOutTheCard('Payment', expanded: true);

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    _say('');
    _say('after tapping Payment again');
    for (final title in _headers) {
      _readOut(tester, title, expanded: false);
    }
    _readOutTheCard('Payment', expanded: false);
    handle.dispose();
  });

  testWidgets('the same three headers, built the way expandable builds them', (
    tester,
  ) async {
    _useATallScreen(tester);
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              for (final title in _headers)
                // A bare InkWell with no `Semantics` around it hands a screen
                // reader exactly this: a tap target with a label on it.
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(title),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _say('');
    _say('the same three headers as a bare InkWell');
    for (final title in _headers) {
      expect(
        tester.getSemantics(
          find.ancestor(of: find.text(title), matching: find.byType(InkWell)),
        ),
        isSemantics(isButton: false, hasExpandedState: false),
      );
      _say('  ${title.padRight(9)} tappable, no button role, no open state');
    }
    _say(
      '  ${_headers.length} of ${_headers.length} announce nothing but their '
      'text',
    );
    handle.dispose();
  });

  testWidgets('the closed line is an answer, not the open body clipped', (
    tester,
  ) async {
    _useATallScreen(tester);
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    _say('');
    _say('what the Shipping section shows in each state');
    for (final option in const ['Standard', 'Express', 'Collection']) {
      expect(find.text(option).hitTestable(), findsOneWidget);
    }
    _say('  open      Standard, Express and Collection, all three tappable');

    await tester.tap(find.text('Shipping'));
    await tester.pumpAndSettle();

    expect(find.text('Standard, arrives Tue 12 Aug'), findsOneWidget);
    expect(find.text('Express, arrives Mon 11 Aug'), findsNothing);
    // The cross-fade keeps both children in the tree. The options are still
    // built, they are just behind an IgnorePointer with no size to speak of,
    // which is the cost `lazy` exists to remove further down the page.
    expect(find.text('Express'), findsOneWidget);
    expect(find.text('Express').hitTestable(), findsNothing);
    _say('  closed    "Standard, arrives Tue 12 Aug", and no option in reach');

    await tester.tap(find.text('Shipping'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Express'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shipping'));
    await tester.pumpAndSettle();

    expect(find.text('Express, arrives Mon 11 Aug'), findsOneWidget);
    expect(find.text('Standard, arrives Tue 12 Aug'), findsNothing);
    _say('  open it, choose Express, close it again');
    _say('  closed    "Express, arrives Mon 11 Aug"');
    _say('  the closed line changed with the choice, so it is a second view');
  });

  testWidgets('how many order lines build a body they were never shown', (
    tester,
  ) async {
    _useATallScreen(tester);
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    _say('');
    _say(
      'expanded bodies built, ${_orderLines(tester)} order lines in a 240 px '
      'list',
    );

    final lazyOn = _bodiesBuilt(tester);
    expect(lazyOn, 0);
    _say('  lazy: true    $lazyOn');

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final lazyOff = _bodiesBuilt(tester);
    final built = _lines(tester, includingOffScreen: true);
    final onScreen = _lines(tester, includingOffScreen: false);
    // "One per line" is the claim, so it is checked against the lines the list
    // built. `greaterThan(0)` would pass just as happily if the two drifted
    // apart, and the two drifting apart is the only thing worth catching here.
    expect(lazyOff, built);
    // The bill is larger than the screen and smaller than the basket, which is
    // the whole shape of the problem: it arrives with the viewport rather than
    // with the twentieth item.
    expect(onScreen, lessThan(built));
    expect(built, lessThan(_orderLines(tester)));
    _say(
      '  lazy: false   $lazyOff   $onScreen lines on screen, $built built, '
      'of ${_orderLines(tester)} in the basket',
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(_bodiesBuilt(tester), 0);

    await tester.tap(find.text('Oat milk, 1 L'));
    await tester.pumpAndSettle();

    final afterOpening = _bodiesBuilt(tester);
    _say('  lazy: true    $afterOpening   after opening one line');
    expect(afterOpening, 1);
  });
}
