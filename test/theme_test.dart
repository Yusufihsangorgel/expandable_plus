import 'package:expandable_plus/expandable_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableThemeData basics', () {
    test('defaults is a full theme', () {
      expect(ExpandableThemeData.defaults.isFull(), isTrue);
      expect(ExpandableThemeData.defaults.isEmpty(), isFalse);
    });

    test('empty theme is empty', () {
      expect(ExpandableThemeData.empty.isEmpty(), isTrue);
      expect(const ExpandableThemeData().isEmpty(), isTrue);
      expect(ExpandableThemeData.empty.isFull(), isFalse);
    });

    test('a partial theme is neither empty nor full', () {
      const theme = ExpandableThemeData(iconColor: Colors.red);
      expect(theme.isEmpty(), isFalse);
      expect(theme.isFull(), isFalse);
    });

    test('nullIfEmpty returns null for empty and self otherwise', () {
      expect(const ExpandableThemeData().nullIfEmpty(), isNull);
      const theme = ExpandableThemeData(iconColor: Colors.red);
      expect(theme.nullIfEmpty(), same(theme));
    });

    test('defaults sets headerPadding to zero', () {
      expect(ExpandableThemeData.defaults.headerPadding, EdgeInsets.zero);
    });
  });

  group('ExpandableThemeData.combine', () {
    test('fills unset fields from defaults', () {
      final combined = ExpandableThemeData.combine(
        const ExpandableThemeData(iconColor: Colors.red),
        ExpandableThemeData.defaults,
      );
      expect(combined.iconColor, Colors.red);
      expect(combined.animationDuration, const Duration(milliseconds: 300));
      expect(combined.headerPadding, EdgeInsets.zero);
    });

    test('returns the theme when defaults is empty', () {
      const theme = ExpandableThemeData(iconColor: Colors.red);
      final combined = ExpandableThemeData.combine(
        theme,
        ExpandableThemeData.empty,
      );
      expect(combined, same(theme));
    });

    test('returns defaults when the theme is empty', () {
      final combined = ExpandableThemeData.combine(
        ExpandableThemeData.empty,
        ExpandableThemeData.defaults,
      );
      expect(combined, same(ExpandableThemeData.defaults));
    });

    test('a full theme is returned unchanged', () {
      final full = ExpandableThemeData.defaults;
      final combined = ExpandableThemeData.combine(
        full,
        const ExpandableThemeData(iconColor: Colors.green),
      );
      expect(combined, same(full));
    });
  });

  group('ExpandableThemeData equality', () {
    test('equal field sets are equal and share a hashCode', () {
      const a = ExpandableThemeData(iconColor: Colors.red, iconSize: 20);
      const b = ExpandableThemeData(iconColor: Colors.red, iconSize: 20);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a differing field breaks equality', () {
      const a = ExpandableThemeData(iconColor: Colors.red);
      const b = ExpandableThemeData(iconColor: Colors.blue);
      expect(a, isNot(b));
    });

    test('headerPadding participates in equality', () {
      const a = ExpandableThemeData(headerPadding: EdgeInsets.zero);
      const b = ExpandableThemeData(headerPadding: EdgeInsets.all(4));
      expect(a, isNot(b));
      expect(a.hashCode, isNot(b.hashCode));
    });

    test('identical instances are equal', () {
      const a = ExpandableThemeData(iconColor: Colors.red);
      expect(a == a, isTrue);
    });
  });

  group('cross-fade math', () {
    test('crossFadePoint 0.5 spans the whole transition', () {
      const theme = ExpandableThemeData(crossFadePoint: 0.5);
      expect(theme.collapsedFadeStart, 0);
      expect(theme.collapsedFadeEnd, 1);
      expect(theme.expandedFadeStart, 0);
      expect(theme.expandedFadeEnd, 1);
    });

    test('crossFadePoint 0 shows the expanded widget immediately', () {
      const theme = ExpandableThemeData(crossFadePoint: 0);
      expect(theme.collapsedFadeStart, 0);
      expect(theme.collapsedFadeEnd, 0);
      expect(theme.expandedFadeStart, 0);
      expect(theme.expandedFadeEnd, 0);
    });

    test('crossFadePoint 0.25 fades over the first half', () {
      const theme = ExpandableThemeData(crossFadePoint: 0.25);
      expect(theme.collapsedFadeStart, 0);
      expect(theme.collapsedFadeEnd, 0.5);
    });

    test('crossFadePoint 1 fades at the end', () {
      const theme = ExpandableThemeData(crossFadePoint: 1);
      expect(theme.collapsedFadeStart, 1);
      expect(theme.collapsedFadeEnd, 1);
    });
  });

  group('withDefaults', () {
    testWidgets('resolves against the ambient theme and defaults', (
      tester,
    ) async {
      late ExpandableThemeData resolved;
      await tester.pumpWidget(
        ExpandableTheme(
          data: const ExpandableThemeData(iconColor: Colors.purple),
          child: Builder(
            builder: (context) {
              resolved = ExpandableThemeData.withDefaults(
                const ExpandableThemeData(iconSize: 40),
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      // Field from the local theme wins.
      expect(resolved.iconSize, 40);
      // Field from the ambient ExpandableTheme is used next.
      expect(resolved.iconColor, Colors.purple);
      // Everything else falls back to the built-in defaults.
      expect(resolved.animationDuration, const Duration(milliseconds: 300));
      expect(resolved.isFull(), isTrue);
    });

    testWidgets('falls back to defaults with no ambient theme', (tester) async {
      late ExpandableThemeData resolved;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolved = ExpandableThemeData.withDefaults(null, context);
            return const SizedBox();
          },
        ),
      );
      expect(resolved, ExpandableThemeData.defaults);
    });
  });
}
