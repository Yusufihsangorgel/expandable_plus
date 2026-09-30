# expandable_plus

Panels that expand and collapse, cross-fading between two different views
rather than clipping one, with accordion groups and a correct screen reader
announcement.

![An accordion of three panels, Shipping, Payment and Returns. Opening one
closes the last, the chevron turns as it goes, and the collapsed and expanded
states show different content rather than the same content clipped](https://raw.githubusercontent.com/Yusufihsangorgel/expandable_plus/main/doc/demo.gif)

## Why this instead of what you already have

**Instead of `ExpansionTile`.** Its constructor takes no collapsed-content
parameter (`material/expansion_tile.dart:121`). Every `collapsed*` field it
does accept is a style: `collapsedBackgroundColor`, `collapsedTextColor`,
`collapsedIconColor`, `collapsedShape`. It reveals a single body by animating a
height factor, so there is no cross-fade between two different views, and
nothing coordinates one tile with the next.

![Two rows of three frames. The top row reveals one body by growing its height,
so the shut frame shows nothing. The bottom row fades a summary line out while a
form fades in, and the shut frame still says
something.](https://raw.githubusercontent.com/Yusufihsangorgel/expandable_plus/main/doc/reveal-modes.png)

That difference decides what a shut panel can say. Growing a height means the
collapsed state is the expanded one with most of it hidden, so a shut row
either shows the top of the form or shows nothing. Two views means a shut
Shipping row can read "Standard, arrives Thursday" and an open one can be the
address form. Redraw the figure with
`dart run tool/reveal_modes_figure.dart`.

**Instead of [expandable].** This package provides accordion grouping, header
button semantics and separate collapsed and expanded views.

[expandable]: https://pub.dev/packages/expandable

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

Create one `ExpandableController` per panel and give each the same
`ExpandableGroupController`. When one opens, the others close. Panels that are
not in a group are unaffected.

Keep the controllers in your `State` and a rebuild reuses them. `FaqList` is
your widget.

```dart
class _FaqListState extends State<FaqList> {
  final _group = ExpandableGroupController();
  late final _controllers = [
    ExpandableController(group: _group),
    ExpandableController(group: _group),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandablePanel(
          controller: _controllers[0],
          header: const Text('Section 1'),
          collapsed: const Text('Summary 1'),
          expanded: const Text('Body 1'),
        ),
        ExpandablePanel(
          controller: _controllers[1],
          header: const Text('Section 2'),
          collapsed: const Text('Summary 2'),
          expanded: const Text('Body 2'),
        ),
      ],
    );
  }
}
```

Pass `ExpandableGroupController(allowAllCollapsed: false)` to keep one section
open at all times. A controller you create is yours to dispose, and the group
holds listeners on its members. Dispose each controller, then the group, as
above.

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
`test/lazy_test.dart`, which pins the number. Redraw the figure with
`dart run tool/lazy_cost_figure.dart`.

![Two lists of twenty collapsed panels side by side. In the left one, headed
"lazy: false", every laid-out row has a dashed red body behind it reading
"expanded body, built, never shown", and the count underneath is 15. In the
right one, headed "lazy: true", the rows are bare and the count is
0.](https://raw.githubusercontent.com/Yusufihsangorgel/expandable_plus/main/doc/lazy-cost.png)

`lazy: true` holds a panel's body back until it first opens:

```dart
ExpandablePanel(
  lazy: true,
  header: const Text('Section'),
  collapsed: const Text('Summary'),
  // Your widget. `lazy` is what keeps it unbuilt until the panel opens,
  // which is the whole reason to reach for it.
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

`ExpandableButton` wraps the header in `Semantics(button: true, expanded: ...)`.
There is no label or semantics parameter to pass. The header widget is the
name: a `Text('Shipping')` header is announced as Shipping.

`example/test/screen_reader_transcript_test.dart` drives the example accordion
and asserts those flags after every tap, then writes them in this spoken form.
It is the node's label, the button role, and the expanded flag — not a
recording of VoiceOver. First frame, Shipping already open:

```
Shipping, button, expanded
Payment, button, collapsed
Returns, button, collapsed
```

Tap Payment. The group closes Shipping; nobody tapped it:

```
Shipping, button, collapsed
Payment, button, expanded
Returns, button, collapsed
```

Tap Payment again:

```
Shipping, button, collapsed
Payment, button, collapsed
Returns, button, collapsed
```

The same three titles built as a bare `InkWell` with no `Semantics` around it:

```
Shipping  tappable, no button role, no open state
Payment   tappable, no button role, no open state
Returns   tappable, no button role, no open state
```

`ExpandablePanel` does this for you. A custom layout still has to wrap the
subtree in `ExpandableNotifier` and put the header in `ExpandableButton`;
otherwise the node is missing. Leave `tapHeaderToExpand` at its default
(`true`) so the header text sits inside the button. Turn it off and only the
chevron is the button, and it has no name.

The flag follows the controller, so expanding from code updates the
announcement too. The change is the flag on the button, not a live region: a
screen reader focused on the header hears the new state.

## What's fixed

* Open one panel at a time: [#8](https://github.com/aryzhov/flutter-expandable/issues/8)
* Remove the padding around the header: [#72](https://github.com/aryzhov/flutter-expandable/issues/72)
* `tapBodyToExpand` and `tapBodyToCollapse` not working: [#50](https://github.com/aryzhov/flutter-expandable/issues/50)
* Example not compiling: [#114](https://github.com/aryzhov/flutter-expandable/issues/114)
* Screen-reader support: the header exposes a button role and an expanded
  state

## Credits

Based on `expandable` by Alexander Ryzhov (MIT). Original repository:
https://github.com/aryzhov/flutter-expandable

## License

MIT. See [LICENSE](LICENSE).
