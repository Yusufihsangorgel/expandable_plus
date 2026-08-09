# expandable_plus

Panels that expand and collapse, cross-fading between two different views
rather than clipping one, with accordion groups and a correct screen reader
announcement.

![expandable_plus banner](https://raw.githubusercontent.com/Yusufihsangorgel/expandable_plus/main/doc/banner.png)

## Why this instead of what you already have

**Instead of `ExpansionTile`.** Its constructor takes no collapsed-content
parameter (`material/expansion_tile.dart:121`). Every `collapsed*` field it
does accept is a style: `collapsedBackgroundColor`, `collapsedTextColor`,
`collapsedIconColor`, `collapsedShape`. It reveals a single body by animating a
height factor, so there is no cross-fade between two different views, and
nothing coordinates one tile with the next.

**Instead of [expandable].** `Semantics` appears nowhere in its source, so
`ExpandableButton` (`lib/expandable.dart:751`) hands a screen reader a bare
`InkWell` with no button role and no expanded state. Four of its open issues
are the ones people hit first: [#8] asks for one panel open at a time (April
2019), [#50] reports `tapBodyToExpand` not working (March 2020), [#72] asks how
to remove the header padding (September 2020), and [#114] reports the example
does not compile (October 2021, filed after the package's last release). The
public API here is the same one, so the move costs an import line.

[expandable]: https://pub.dev/packages/expandable
[#8]: https://github.com/aryzhov/flutter-expandable/issues/8
[#50]: https://github.com/aryzhov/flutter-expandable/issues/50
[#72]: https://github.com/aryzhov/flutter-expandable/issues/72
[#114]: https://github.com/aryzhov/flutter-expandable/issues/114

## Reach for it when

- The collapsed and expanded states show different content, not the same
  content clipped.
- A set of panels should behave as an accordion with one open at a time.
- Panels need a correct button role and expanded state announced to a screen
  reader.

Skip it if a Material `ExpansionTile` already fits your design. It ships with
the framework, it announces its own state changes through a live region
(`material/expansion_tile.dart:634`), and one fewer dependency is worth more
than the extras here.

## Migration from expandable

Change the import, and your existing panels behave the same.

```dart
// before
import 'package:expandable/expandable.dart';
// after
import 'package:expandable_plus/expandable_plus.dart';
```

The class names, fields, and defaults are the same. Your existing panels look
and behave the way they did.

## Install

```sh
flutter pub add expandable_plus
```

## Usage

<p align="center">
  <img src="https://raw.githubusercontent.com/Yusufihsangorgel/expandable_plus/main/doc/demo.gif" alt="expandable_plus accordion group demo" width="360">
</p>

### A basic panel

```dart
ExpandablePanel(
  header: const Text('Details'),
  collapsed: const Text(
    'A short summary.',
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
  expanded: const Text('The full text goes here.'),
)
```

### An accordion group

Pass one `ExpandableGroupController` to several panels. When one opens, the
others close. Panels that are not in a group are unaffected.

```dart
final group = ExpandableGroupController();

Column(
  children: [
    ExpandablePanel(
      controller: ExpandableController(group: group),
      header: const Text('Section 1'),
      collapsed: const Text('Summary 1'),
      expanded: const Text('Body 1'),
    ),
    ExpandablePanel(
      controller: ExpandableController(group: group),
      header: const Text('Section 2'),
      collapsed: const Text('Summary 2'),
      expanded: const Text('Body 2'),
    ),
  ],
)
```

Pass `ExpandableGroupController(allowAllCollapsed: false)` to keep one section
open at all times. Dispose the group when you are done with it, for example in
your `State.dispose`.

### Header padding

`headerPadding` controls the space around the header. The default is
`EdgeInsets.zero`, which matches `expandable`.

```dart
ExpandablePanel(
  theme: const ExpandableThemeData(headerPadding: EdgeInsets.all(16)),
  header: const Text('Details'),
  collapsed: const Text('Summary'),
  expanded: const Text('Body'),
)
```

## Long lists: `lazy`

A cross-fade keeps both children in the tree, and a collapsed panel still builds
its expanded body. One panel never notices. Twenty do: put twenty collapsed
`ExpandablePanel`s in a `ListView` and fifteen expanded bodies are built on the
first frame, one for every panel the viewport lays out. Measured in
`test/lazy_test.dart`, which pins the number.

`lazy: true` holds a panel's body back until it first opens:

```dart
ExpandablePanel(
  lazy: true,
  header: const Text('Section'),
  collapsed: const Text('Summary'),
  expanded: const HeavyBody(),
)
```

The first expand swaps the real child in, and it stays. Closing and reopening
costs nothing and keeps whatever state the body was holding, because its
`initState` runs once.

Off by default. Turning it on moves when a child's `initState` runs. That
matters if the body has to be alive before anyone opens it, which makes this a
decision rather than a default. Panels built through `builder` place both
children themselves and are unaffected.

## Accessibility

The header is a real button to a screen reader, and it carries the panel's
open state. A user hears "collapsed" or "expanded", and hears it change when
they press it. That comes from `ExpandableButton`, which every header and
header icon goes through. Panels and accordion groups get it without any
setup:

```dart
ExpandablePanel(
  header: Text('Details'),   // announced as a button, expanded or collapsed
  collapsed: Text('Summary'),
  expanded: Text('Everything'),
)
```

Nothing needs to be passed for this. It tracks the controller, and expanding a
panel from code updates the announcement too.

## What's fixed

* Open one panel at a time: [#8](https://github.com/aryzhov/flutter-expandable/issues/8)
* Remove the padding around the header: [#72](https://github.com/aryzhov/flutter-expandable/issues/72)
* `tapBodyToExpand` and `tapBodyToCollapse` not working: [#50](https://github.com/aryzhov/flutter-expandable/issues/50)
* Example not compiling: [#114](https://github.com/aryzhov/flutter-expandable/issues/114)
* No screen-reader support: the header exposed no button role and no
  expanded state, leaving the control unusable with assistive technology

## Credits

Based on `expandable` by Alexander Ryzhov (MIT). Original repository:
https://github.com/aryzhov/flutter-expandable

## License

MIT. See [LICENSE](LICENSE).
