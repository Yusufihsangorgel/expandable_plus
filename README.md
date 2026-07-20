# expandable_plus

![expandable_plus banner](https://raw.githubusercontent.com/Yusufihsangorgel/expandable_plus/main/doc/banner.png)

A maintained continuation of the `expandable` package. It shows content that the
user can expand or collapse, with an optional header, an animated icon, and a
cross-fade between the collapsed and expanded views.

`expandable` has not had a release since 2021 and has a backlog of open issues.
`expandable_plus` keeps the same public API, so you can move to it without
rewriting anything, and it closes some of the most requested gaps. It adds
accordion groups and a header padding option, and it fixes body taps on a
standalone panel.

## Migration from expandable

Change the import, and your existing panels behave the same.

```dart
// before
import 'package:expandable/expandable.dart';
// after
import 'package:expandable_plus/expandable_plus.dart';
```

The class names, fields, and defaults are the same, so your existing panels look
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

## Accessibility

The header is a real button to a screen reader, and it carries the panel's
open state, so a user hears "collapsed" or "expanded" and hears it change when
they press it. That comes from `ExpandableButton`, which every header and
header icon goes through, so panels and accordion groups get it without any
setup:

```dart
ExpandablePanel(
  header: Text('Details'),   // announced as a button, expanded or collapsed
  collapsed: Text('Summary'),
  expanded: Text('Everything'),
)
```

Nothing needs to be passed for this, and it tracks the controller, so
expanding a panel from code updates the announcement too.

## What's fixed

* Open one panel at a time: [#8](https://github.com/aryzhov/flutter-expandable/issues/8)
* Remove the padding around the header: [#72](https://github.com/aryzhov/flutter-expandable/issues/72)
* `tapBodyToExpand` and `tapBodyToCollapse` not working: [#50](https://github.com/aryzhov/flutter-expandable/issues/50)
* Example not compiling: [#114](https://github.com/aryzhov/flutter-expandable/issues/114)
* No screen-reader support: the header exposed no button role and no
  expanded state, so the control was unusable with assistive technology

## Credits

Based on `expandable` by Alexander Ryzhov (MIT). Original repository:
https://github.com/aryzhov/flutter-expandable

## License

MIT. See [LICENSE](LICENSE).
