// Draws the difference between revealing one body and cross-fading two.
//
//   dart run tool/reveal_modes_figure.dart
//
// The README's first claim is that this package cross-fades between two
// different views rather than clipping one, and that sentence is doing a lot
// of work. `ExpansionTile` animates a height factor over a single child: the
// collapsed state is that same child, hidden. Here the collapsed and expanded
// states are separate widgets, so a row can summarise while it is shut and
// show a form when it is open.
//
// Three frames of each, side by side, is faster to read than the paragraph.
import 'dart:io';

const bg = '#14161C';
const ink = '#d8dee9';
const dim = '#8b93a3';
const edge = '#39414f';
const header = '#2a3240';
const bodyA = '#7fb3ff'; // the single body being revealed
const bodyB = '#8ee0a1'; // the second view, faded in

const frameW = 168.0;
const frameH = 118.0;
const gap = 24.0;
const left = 200.0; // room for the row label

/// A header bar with a chevron, at the top of every frame.
String headerBar(double x, double y, double turn) =>
    '''
  <rect x="$x" y="$y" width="$frameW" height="26" fill="$header"/>
  <rect x="${x + 12}" y="${y + 10}" width="72" height="6" rx="3" fill="$dim"/>
  <g transform="translate(${x + frameW - 22} ${y + 13}) rotate($turn)">
    <path d="M -5 -2 L 0 3 L 5 -2" fill="none" stroke="$ink" stroke-width="2"
      stroke-linecap="round" stroke-linejoin="round"/>
  </g>
''';

/// One frame of the single-body reveal: the body grows from nothing, clipped
/// to whatever height the animation has reached.
String clipFrame(double x, double y, String id, double t) {
  final h = (frameH - 26) * t;
  return '''
  <clipPath id="c$id"><rect x="$x" y="${y + 26}" width="$frameW"
    height="${h.toStringAsFixed(1)}"/></clipPath>
  <rect x="$x" y="$y" width="$frameW" height="$frameH" fill="none"
    stroke="$edge" stroke-width="1.2"/>
${headerBar(x, y, t * 180)}  <g clip-path="url(#c$id)">
    <rect x="${x + 12}" y="${y + 38}" width="${frameW - 24}" height="10" rx="2"
      fill="$bodyA" fill-opacity="0.75"/>
    <rect x="${x + 12}" y="${y + 54}" width="${frameW - 44}" height="10" rx="2"
      fill="$bodyA" fill-opacity="0.75"/>
    <rect x="${x + 12}" y="${y + 70}" width="${frameW - 60}" height="10" rx="2"
      fill="$bodyA" fill-opacity="0.75"/>
  </g>
''';
}

/// One frame of the cross-fade: two different views, one leaving, one
/// arriving. The summary line and the form are not the same widget.
String fadeFrame(double x, double y, double t) {
  final out = (1 - t).clamp(0.0, 1.0);
  return '''
  <rect x="$x" y="$y" width="$frameW" height="$frameH" fill="none"
    stroke="$edge" stroke-width="1.2"/>
${headerBar(x, y, t * 180)}  <rect x="${x + 12}" y="${y + 38}" width="${frameW - 40}" height="10" rx="2"
    fill="$bodyA" fill-opacity="${(out * 0.75).toStringAsFixed(2)}"/>
  <text x="${x + 12}" y="${y + 62}" fill="$bodyA" font-size="10"
    font-family="Menlo, monospace"
    fill-opacity="${(out * 0.8).toStringAsFixed(2)}">summary</text>
  <rect x="${x + 12}" y="${y + 38}" width="${frameW - 24}" height="22" rx="3"
    fill="none" stroke="$bodyB" stroke-width="1.4"
    stroke-opacity="${(t * 0.9).toStringAsFixed(2)}"/>
  <rect x="${x + 12}" y="${y + 66}" width="${frameW - 24}" height="22" rx="3"
    fill="none" stroke="$bodyB" stroke-width="1.4"
    stroke-opacity="${(t * 0.9).toStringAsFixed(2)}"/>
  <text x="${x + 12}" y="${y + 106}" fill="$bodyB" font-size="10"
    font-family="Menlo, monospace"
    fill-opacity="${(t * 0.85).toStringAsFixed(2)}">a different widget</text>
''';
}

void main() {
  const steps = [0.0, 0.5, 1.0];
  final width = left + frameW * 3 + gap * 3;
  const height = 340.0;

  final svg = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="${width.toStringAsFixed(0)}" height="${height.toInt()}" '
      'viewBox="0 0 ${width.toStringAsFixed(0)} ${height.toInt()}">',
    )
    ..writeln('  <rect width="100%" height="100%" fill="$bg"/>')
    ..writeln(
      '  <text x="20" y="44" fill="$ink" font-size="14" '
      'font-family="Menlo, monospace">ExpansionTile</text>',
    )
    ..writeln(
      '  <text x="20" y="64" fill="$dim" font-size="11.5" '
      'font-family="Menlo, monospace">one body, revealed by</text>',
    )
    ..writeln(
      '  <text x="20" y="80" fill="$dim" font-size="11.5" '
      'font-family="Menlo, monospace">growing its height</text>',
    )
    ..writeln(
      '  <text x="20" y="204" fill="$ink" font-size="14" '
      'font-family="Menlo, monospace">expandable_plus</text>',
    )
    ..writeln(
      '  <text x="20" y="224" fill="$dim" font-size="11.5" '
      'font-family="Menlo, monospace">two views, one</text>',
    )
    ..writeln(
      '  <text x="20" y="240" fill="$dim" font-size="11.5" '
      'font-family="Menlo, monospace">cross-fading into</text>',
    )
    ..writeln(
      '  <text x="20" y="256" fill="$dim" font-size="11.5" '
      'font-family="Menlo, monospace">the other</text>',
    );

  for (var i = 0; i < steps.length; i++) {
    final x = left + i * (frameW + gap);
    svg
      ..write(clipFrame(x, 26, 'a$i', steps[i]))
      ..write(fadeFrame(x, 186, steps[i]));
  }

  svg
    ..writeln(
      '  <text x="${width / 2}" y="322" fill="$dim" font-size="11.5" '
      'font-family="Menlo, monospace" text-anchor="middle">'
      'shut, halfway, open — the collapsed row can say something the open '
      'one does not</text>',
    )
    ..writeln('</svg>');

  File('doc/reveal-modes.svg').writeAsStringSync(svg.toString());
  stdout.writeln('wrote doc/reveal-modes.svg');
  stdout.writeln(
    'render: rsvg-convert -z 2 doc/reveal-modes.svg '
    '-o doc/reveal-modes.png',
  );
}
