import 'dart:math';

import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Measures whether [ExpandableGroupController] holds the two rules it
/// documents, across a long random walk with a fixed seed so the counts are
/// reproducible:
///
///  * at most one member expanded, always;
///  * at least one member expanded, when `allowAllCollapsed` is false.
///
/// The second was once enforced only by the change listener, so a group whose
/// members all joined collapsed sat in the forbidden state until something
/// touched it. Run this file against the parent of that fix and it reports the
/// violations; on this commit it reports none.
void main() {
  const seed = 42, groups = 100, steps = 20, members = 4;

  test('both group rules hold across $groups x $steps transitions', () {
    final rng = Random(seed);
    var twoOpen = 0, noneOpen = 0, checks = 0, noneAtBuild = 0;

    for (var trial = 0; trial < groups; trial++) {
      final group = ExpandableGroupController(allowAllCollapsed: false);
      final cs = List.generate(
        members,
        (_) => ExpandableController(group: group),
      );
      if (cs.every((c) => !c.expanded)) noneAtBuild++;

      for (var step = 0; step < steps; step++) {
        final c = cs[rng.nextInt(cs.length)];
        // Three operations, not just toggle: setting a value that is already
        // there fires no change event, and that is the case the listener
        // never sees.
        switch (rng.nextInt(3)) {
          case 0:
            c.expanded = true;
          case 1:
            c.expanded = false;
          case 2:
            c.toggle();
        }
        checks++;
        final open = cs.where((x) => x.expanded).length;
        if (open > 1) twoOpen++;
        if (open == 0) noneOpen++;
      }

      for (final c in cs) {
        c.dispose();
      }
      group.dispose();
    }

    printOnFailure(
      'transitions: $checks, born with none open: '
      '$noneAtBuild/$groups',
    );
    expect(twoOpen, 0, reason: 'more than one member was expanded');
    expect(noneOpen, 0, reason: 'no member was expanded');
  });
}
