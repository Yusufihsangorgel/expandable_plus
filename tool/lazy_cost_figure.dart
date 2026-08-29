// Draws what a collapsed panel costs when its body is built anyway.
//
//   dart run tool/lazy_cost_figure.dart
//
// This is the package's strongest argument and it was prose. A cross-fade
// keeps both children in the tree, so a collapsed panel still builds its
// expanded body -- invisible, off screen, and paid for on the first frame.
//
// The numbers are `test/lazy_test.dart`'s own, not an estimate: twenty
// panels in a ListView, `expect(builds.length, 15)` and
// `expect(inits.length, 15)` by default, `expect(builds, isEmpty)` with
// `lazy: true`. Fifteen rather than twenty because that is what the viewport
// lays out; the list is lazy about rows even when the panel is not lazy about
// bodies.
import 'dart:io';

const bg = '#14161C';
const ink = '#d8dee9';
const dim = '#8b93a3';
const edge = '#39414f';
const card = '#1b1f28';
const header = '#31405c';
const cost = '#e0796f'; // a body that was built and nobody asked for
const saved = '#7fb3ff';

const panelW = 290.0;
const rows =
    8; // what fits in the drawn viewport; the count is stated, not drawn
const rowH = 36.0;
const bodyH = 16.0;

/// One column: a scrolling list of collapsed panels, drawn with or without
/// the expanded body that a collapsed panel builds anyway.
String column(double x, String title, String setting, {required bool eager}) {
  const top = 106.0;
  final b = StringBuffer()
    ..writeln(
      '  <text x="${x + panelW / 2}" y="38" fill="$ink" font-size="14" '
      'font-family="Menlo, monospace" text-anchor="middle">$title</text>',
    )
    ..writeln(
      '  <text x="${x + panelW / 2}" y="58" fill="${eager ? cost : saved}" '
      'font-size="12" font-family="Menlo, monospace" '
      'text-anchor="middle">$setting</text>',
    )
    ..writeln(
      '  <text x="${x + panelW / 2}" y="84" fill="$dim" font-size="11" '
      'font-family="Menlo, monospace" text-anchor="middle">'
      'a ListView of 20 collapsed panels</text>',
    )
    ..writeln(
      '  <rect x="$x" y="$top" width="$panelW" height="${rows * rowH + 14}" '
      'fill="$card" stroke="$edge" stroke-width="1.2" rx="4"/>',
    );

  var y = top + 9;
  for (var i = 0; i < rows; i++) {
    // The header: what the reader sees.
    b.writeln(
      '    <rect x="${x + 12}" y="$y" width="${panelW - 24}" height="13" '
      'rx="2" fill="$header"/>',
    );
    if (eager) {
      // The expanded body, built and in the tree, behind the collapsed one.
      b
        ..writeln(
          '    <rect x="${x + 12}" y="${y + 15}" width="${panelW - 24}" '
          'height="$bodyH" rx="2" fill="$cost" fill-opacity="0.22" '
          'stroke="$cost" stroke-width="0.8" stroke-dasharray="3 2"/>',
        )
        ..writeln(
          '    <text x="${x + panelW / 2}" y="${y + 27}" fill="$cost" '
          'font-size="8.5" font-family="Menlo, monospace" '
          'text-anchor="middle">expanded body, built, never shown</text>',
        );
    }
    y += rowH;
  }

  // The count, which is the whole point.
  final n = eager ? '15' : '0';
  b
    ..writeln(
      '  <text x="${x + panelW / 2}" y="${top + rows * rowH + 56}" '
      'fill="${eager ? cost : saved}" font-size="27" '
      'font-family="Menlo, monospace" text-anchor="middle">$n</text>',
    )
    ..writeln(
      '  <text x="${x + panelW / 2}" y="${top + rows * rowH + 78}" '
      'fill="$dim" font-size="11" font-family="Menlo, monospace" '
      'text-anchor="middle">bodies built on the first frame</text>',
    )
    ..writeln(
      '  <text x="${x + panelW / 2}" y="${top + rows * rowH + 95}" '
      'fill="$dim" font-size="11" font-family="Menlo, monospace" '
      'text-anchor="middle">and $n initState calls</text>',
    );
  return b.toString();
}

void main() {
  const left = 44.0, gap = 74.0;
  final width = left * 2 + panelW * 2 + gap;
  const height = 570.0;

  // The counts sit below the list, and the caption below them. Getting this
  // wrong prints text on top of text, which renders without complaint -- so
  // it is checked here rather than noticed in a screenshot.
  const lastCountBaseline = 106.0 + rows * rowH + 95;
  assert(
    height - 30 > lastCountBaseline + 24,
    'the caption would land on the counts',
  );

  final svg = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="${width.toStringAsFixed(0)}" height="${height.toInt()}" '
      'viewBox="0 0 ${width.toStringAsFixed(0)} ${height.toInt()}">',
    )
    ..writeln('  <rect width="100%" height="100%" fill="$bg"/>')
    ..write(column(left, 'the default', 'lazy: false', eager: true))
    ..write(
      column(left + panelW + gap, 'held back', 'lazy: true', eager: false),
    )
    ..writeln(
      '  <text x="${width / 2}" y="${height - 30}" fill="$ink" '
      'font-size="12" font-family="Menlo, monospace" text-anchor="middle">'
      'fifteen, not twenty: the list lays out only what the viewport '
      'holds</text>',
    )
    ..writeln(
      '  <text x="${width / 2}" y="${height - 12}" fill="$dim" '
      'font-size="10.5" font-family="Menlo, monospace" text-anchor="middle">'
      'each of those builds both children -- the numbers are '
      'test/lazy_test.dart\'s own assertions</text>',
    )
    ..writeln('</svg>');

  File('doc/lazy-cost.svg').writeAsStringSync(svg.toString());
  stdout
    ..writeln('wrote doc/lazy-cost.svg')
    ..writeln(
      'render: rsvg-convert -z 2 doc/lazy-cost.svg -o doc/lazy-cost.png',
    );
}
