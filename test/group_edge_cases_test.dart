import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accordion group edge cases', () {
    test('expand A then B leaves only B open', () {
      final g = ExpandableGroupController();
      final a = ExpandableController(group: g);
      final b = ExpandableController(group: g);
      a.expanded = true;
      b.expanded = true;
      expect(a.expanded, false);
      expect(b.expanded, true);
      expect(g.expandedMember, b);
    });

    test(
      'at-least-one-open: collapsing the only open member re-expands it',
      () {
        final g = ExpandableGroupController(allowAllCollapsed: false);
        final a = ExpandableController(group: g);
        ExpandableController(group: g);
        a.expanded = true;
        a.expanded = false; // must bounce back
        expect(a.expanded, true, reason: 'last-open should stay open');
        expect(g.expandedMember, a);
      },
    );

    test('rapid alternating toggles never loop or throw and keep <=1 open', () {
      final g = ExpandableGroupController();
      final cs = List.generate(5, (_) => ExpandableController(group: g));
      for (var i = 0; i < 200; i++) {
        cs[i % 5].expanded = true;
        final open = cs.where((c) => c.expanded).length;
        expect(open, lessThanOrEqualTo(1));
      }
      expect(cs.where((c) => c.expanded).length, 1);
    });

    test('registering an already-expanded member preserves at-most-one', () {
      final g = ExpandableGroupController();
      final a = ExpandableController(initialExpanded: true, group: g);
      final b = ExpandableController(initialExpanded: true, group: g);
      final open = [a, b].where((c) => c.expanded).length;
      expect(open, 1, reason: 'joining two pre-expanded members => one wins');
    });

    test('collapseAll with allowAllCollapsed:false keeps one open', () {
      final g = ExpandableGroupController(allowAllCollapsed: false);
      final a = ExpandableController(group: g);
      ExpandableController(group: g);
      a.expanded = true;
      g.collapseAll();
      expect(g.expandedMember, isNotNull, reason: 'one must remain');
    });

    test('collapseAll with allowAllCollapsed:true collapses everything', () {
      final g = ExpandableGroupController();
      final a = ExpandableController(group: g);
      final b = ExpandableController(group: g);
      a.expanded = true;
      g.collapseAll();
      expect(a.expanded, false);
      expect(b.expanded, false);
      expect(g.expandedMember, isNull);
    });
  });
}
