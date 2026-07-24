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

    test('at-least-one-open holds from the start, not just after a change', () {
      // The guarantee used to be maintained but never established: nothing
      // fires _onMemberChanged when members join collapsed, so a group whose
      // members all start closed sat at zero expanded forever — the state the
      // flag exists to forbid.
      final g = ExpandableGroupController(allowAllCollapsed: false);
      final a = ExpandableController(group: g);
      final b = ExpandableController(group: g);
      expect(a.expanded, true, reason: 'the first member to join opens');
      expect(b.expanded, false);
      expect(g.expandedMember, a);
    });

    test('a member that joins already open is not overridden', () {
      final g = ExpandableGroupController(allowAllCollapsed: false);
      final a = ExpandableController(group: g);
      final b = ExpandableController(group: g, initialExpanded: true);
      expect(b.expanded, true);
      expect(a.expanded, false, reason: 'the explicit one wins');
      expect(g.expandedMember, b);
    });

    test('allowAllCollapsed:true still starts with everything closed', () {
      final g = ExpandableGroupController();
      final cs = List.generate(3, (_) => ExpandableController(group: g));
      expect(cs.where((c) => c.expanded), isEmpty);
      expect(g.expandedMember, isNull);
    });

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
