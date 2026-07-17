import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableGroupController', () {
    test('expanding one member collapses the others', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group);
      final b = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        a.dispose();
        b.dispose();
      });

      a.expanded = true;
      expect(a.expanded, isTrue);
      expect(b.expanded, isFalse);

      b.expanded = true;
      expect(a.expanded, isFalse);
      expect(b.expanded, isTrue);
    });

    test('without a group both members stay expanded', () {
      final a = ExpandableController();
      final b = ExpandableController();
      addTearDown(() {
        a.dispose();
        b.dispose();
      });

      a.expanded = true;
      b.expanded = true;
      expect(a.expanded, isTrue);
      expect(b.expanded, isTrue);
    });

    test('members reflects the joined controllers in order', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group);
      final b = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        a.dispose();
        b.dispose();
      });
      expect(group.members.toList(), [a, b]);
    });

    test('expandedMember reports the open member or null', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group);
      final b = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        a.dispose();
        b.dispose();
      });

      expect(group.expandedMember, isNull);
      a.expanded = true;
      expect(group.expandedMember, same(a));
      b.expanded = true;
      expect(group.expandedMember, same(b));
    });

    test('allowAllCollapsed true lets every member collapse', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group, initialExpanded: true);
      addTearDown(() {
        group.dispose();
        a.dispose();
      });
      a.expanded = false;
      expect(a.expanded, isFalse);
      expect(group.expandedMember, isNull);
    });

    test('allowAllCollapsed false keeps one member open', () {
      final group = ExpandableGroupController(allowAllCollapsed: false);
      final a = ExpandableController(group: group, initialExpanded: true);
      final b = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        a.dispose();
        b.dispose();
      });

      // Collapsing the only open member re-expands it.
      a.expanded = false;
      expect(a.expanded, isTrue);

      // Opening another member is still allowed and collapses the first.
      b.expanded = true;
      expect(a.expanded, isFalse);
      expect(b.expanded, isTrue);

      // The now-only-open member cannot be collapsed either.
      b.expanded = false;
      expect(b.expanded, isTrue);
    });

    test(
      'registering an already-expanded member collapses the previous one',
      () {
        final group = ExpandableGroupController();
        final a = ExpandableController(group: group, initialExpanded: true);
        final b = ExpandableController(group: group, initialExpanded: true);
        addTearDown(() {
          group.dispose();
          a.dispose();
          b.dispose();
        });
        expect(a.expanded, isFalse);
        expect(b.expanded, isTrue);
      },
    );

    test('collapseAll collapses every member', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group, initialExpanded: true);
      final b = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        a.dispose();
        b.dispose();
      });
      group.collapseAll();
      expect(a.expanded, isFalse);
      expect(b.expanded, isFalse);
    });

    test('the group notifies listeners when a member changes', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        a.dispose();
      });
      var notifications = 0;
      group.addListener(() => notifications++);
      a.expanded = true;
      expect(notifications, greaterThan(0));
    });

    test('a disposed controller no longer affects the group', () {
      final group = ExpandableGroupController();
      final a = ExpandableController(group: group);
      final b = ExpandableController(group: group);
      addTearDown(() {
        group.dispose();
        b.dispose();
      });

      a.expanded = true;
      expect(b.expanded, isFalse);

      a.dispose();
      expect(group.members.contains(a), isFalse);

      // b can now expand and there is no lingering member to coordinate with.
      b.expanded = true;
      expect(b.expanded, isTrue);
    });
  });
}
