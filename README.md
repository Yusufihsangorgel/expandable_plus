# expandable_plus

![expandable_plus banner](doc/banner.png)

A maintained continuation of the `expandable` package. It shows content that the
user can expand or collapse, with an optional header, an animated icon, and a
cross-fade between the collapsed and expanded views.

`expandable` has not had a release since 2021 and has a backlog of open issues.
`expandable_plus` keeps the same public API, so you can move to it without
rewriting anything, and it closes some of the most requested gaps. It adds
accordion groups and a header padding option, and it fixes body taps on a
standalone panel.

## Migration from expandable

Change the import. Nothing else changes.

```dart
// before
import 'package:expandable/expandable.dart';
// after
import 'package:expandable_plus/expandable_plus.dart';
```

The class names, fields, and defaults are the same, so your existing panels look
and behave the way they did.

## Install

```yaml
dependencies:
  expandable_plus: ^0.1.0
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

## What's fixed

* Open one panel at a time: [#8](https://github.com/aryzhov/flutter-expandable/issues/8)
* Remove the padding around the header: [#72](https://github.com/aryzhov/flutter-expandable/issues/72)
* `tapBodyToExpand` and `tapBodyToCollapse` not working: [#50](https://github.com/aryzhov/flutter-expandable/issues/50)
* Example not compiling: [#114](https://github.com/aryzhov/flutter-expandable/issues/114)

## Credits

Based on `expandable` by Alexander Ryzhov (MIT). Original repository:
https://github.com/aryzhov/flutter-expandable

## License

MIT. See [LICENSE](LICENSE).
