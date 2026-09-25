# expandable_plus

## Purpose

`expandable_plus` cross-fades a collapsed widget into a different expanded
widget, with optional accordion grouping. It is a drop-in successor to
`expandable`: same type names, change the import.

If one view that grows is enough, use Material `ExpansionTile`. What this
adds is two genuinely different views, accordion grouping via
`ExpandableGroupController`, and header semantics (button role and expanded
state on `ExpandableButton`).

## Usage

Import `package:expandable_plus/expandable_plus.dart`. A standalone panel;
with no `controller`, `ExpandablePanel` creates and owns one:

```dart
ExpandablePanel(
  header: const Text('Shipping'),
  collapsed: const Text('Standard, arrives Tuesday'),
  expanded: const Text('Address and delivery options'),
)
```

Accordion, as in `example/lib/main.dart`. One `ExpandableController` per
panel, same group. Dispose each controller, then the group:

```dart
final group = ExpandableGroupController();
final controllers = <ExpandableController>[
  ExpandableController(group: group, initialExpanded: true),
  ExpandableController(group: group),
];

ExpandablePanel(
  controller: controllers[0],
  header: const Text('Shipping'),
  collapsed: const Text('Standard, arrives Tuesday'),
  expanded: const Text('Address and delivery options'),
);
```

`ExpandableGroupController(allowAllCollapsed: false)` keeps one member open.
`lazy: true` on `ExpandablePanel` / `Expandable` defers building `expanded`
until the first open.

## Contracts

**Ownership.** A caller-supplied `ExpandableController` is never disposed by
the package. `ExpandableNotifier` disposes only a controller it created
(`_ownsController`). `ExpandablePanel` with no `controller` and no ambient
`ExpandableController.of` wraps itself in an `ExpandableNotifier` that owns
the controller.

**Notifier placement.** `Expandable`, `ExpandableButton`, `ExpandableIcon`,
and `ScrollOnExpand` call `ExpandableController.of(context, required: true)`.
The `ExpandableNotifier` must be an ancestor of those widgets.
`ExpandablePanel` installs that notifier as its child, around the header and
body; a sibling or parent context cannot read it. Custom layouts wrap the
subtree in `ExpandableNotifier` themselves.

**`lazy`.** Default `false`. Off: `AnimatedCrossFade` keeps both children in
the tree, so a collapsed panel still runs `initState` on `expanded`. On: a
never-opened panel builds `SizedBox.shrink()` instead of `expanded`; the
first expand swaps the real child in and it stays (reopen does not run
`initState` again). Ignored when `ExpandablePanel.builder` is set.

**Group membership.** `ExpandableController` constructor calls
`ExpandableGroupController._register`; `ExpandableController.dispose` calls
`_unregister`. The group holds a listener per member. Discarding a panel
without disposing its controller leaves it in `members` with the listener
still attached. Call `ExpandableGroupController.dispose` when finished with
the group.

## Mistakes

**Missing notifier.** Building `ExpandableButton` (or `Expandable`,
`ExpandableIcon`, `ScrollOnExpand`) with no `ExpandableNotifier` ancestor
throws `FlutterError`: "No ExpandableNotifier found above this widget."
Throws in every build mode. Wrap the subtree, or use `ExpandablePanel`.

**One notifier around several panels.** They share one controller and
open/close together. Accordion is one controller per panel, each constructed
with the same `group:`.

**Dynamic list leak.** `controller: ExpandableController(group: group)`
inside a builder, never stored: rebuilds join new members; removing a row
(filter, `ListView` item gone, route pop) never calls `_unregister`.
`group.members` grows; dead controllers still get collapsed. Keep
controllers keyed by item and dispose on remove, or wrap each row in
`ExpandableNotifier(group: group)` with no `controller` so the notifier owns
and disposes it.

**`lazy: true` plus `builder:`.** `lazy` is ignored; both children build at
once. Defer inside the builder, or drop `builder`.

**`ExpandableNotifier(controller:, group:)`.** Asserts: set `group` on the
controller.

**Long list, `lazy` left at default.** Twenty collapsed `ExpandablePanel`s in
a `ListView` build fifteen expanded bodies on the first frame
(`test/lazy_test.dart`). Pass `lazy: true`.

## Layout

- `lib/expandable_plus.dart` — public API; `lib/src/{controller,group,theme,widgets}.dart`
- `example/lib/main.dart` — accordion and a `lazy` list
- `test/` — widget tests; goldens tagged `golden` (one platform)
- `tool/` — README figures

```sh
flutter analyze --fatal-infos
flutter test --exclude-tags golden
cd example && flutter test
cd example && flutter run
```

## Contributing

Before changing this repository, read [CONTRIBUTING.md](CONTRIBUTING.md), [package engineering rules](docs/engineering/package.md), and the [debt register](docs/engineering/debt.json). These requirements apply to every contributor. The usage guidance above remains the consumer contract.
