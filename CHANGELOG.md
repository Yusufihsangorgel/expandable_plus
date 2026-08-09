## 1.2.0

- `ExpandableController.of(required: true)` now throws when there is no
  `ExpandableNotifier` above it, in every build mode. It used to only assert,
  and asserts are compiled out of a release build, so a misplaced widget threw
  during development and then quietly did nothing in the shipped app: an
  `ExpandableButton` with a null `onTap` still looks like a button and ignores
  every tap, and a panel with no controller renders permanently open. The error
  names the widget that asked and says what to wrap it in.
- The README opens with what the package is for and answers `ExpansionTile` and
  `expandable` in its first screen, with the source lines and issue numbers
  behind each claim.

## 1.1.1

- The example demonstrates `lazy`. Twenty panels in a list, a switch for the
  mode, and a counter for how many expanded bodies have been built. It reads
  zero until you open one, and jumps to fifteen the moment the switch goes off.
  The feature shipped in 1.1.0 with nothing to look at.

## 1.1.0

- Add `lazy` to `ExpandablePanel` and `Expandable`. A cross-fade keeps both
  children in the tree. A collapsed panel builds its expanded body anyway.
  Twenty collapsed panels in a `ListView` build fifteen of them on the first
  frame, one per panel the viewport lays out, which is the shape of the report
  in [expandable#123](https://github.com/aryzhov/flutter-expandable/issues/123)
  that a screen "stops being usable when you have more than 10 expandables".
  With `lazy: true` a panel that has never opened builds a zero-size
  placeholder instead.
- The first expand swaps the real child in and keeps it. Reopening runs no
  second `initState`. A body holding scroll position or form input survives a
  close.
- Off by default, and `test/lazy_test.dart` asserts that with nothing passed.
  Turning it on changes when a child's `initState` runs, which is a decision
  for the caller rather than something to hand everyone in a minor release.
- `Expandable` is a `StatefulWidget` now. Its constructor is unchanged and
  still `const`.

## 1.0.0

First stable release. The API below is what 1.0 freezes.

- **Fix `allowAllCollapsed: false` not holding at the start.** The flag
  documents that the group "always keeps one member expanded", but the group
  only ever *maintained* that: `_onMemberChanged` re-expands the last open
  member when it closes, and nothing fires it while members are only joining.
  A group whose members all started collapsed (the ordinary case, since
  `initialExpanded` defaults to false) therefore sat at zero expanded
  indefinitely, the one state the flag exists to forbid. Randomised toggling
  across 100 groups and 2000 transitions hit it 24 times. Joining a group in
  that state now expands the first member, which is what an accordion with no
  explicit `initialExpanded` should look like. A member that joins already
  expanded still wins, and `allowAllCollapsed: true` is unchanged: those groups
  still start with everything closed.

The mutual-exclusion half of the invariant was already sound: the same 2000
transitions produced no case of two members open at once, in either mode.

## 0.2.4

- Fix a leak: `ExpandableNotifier` created its own `ExpandableController`
  whenever no `controller` was passed in, but never disposed it. This is the
  default path for a bare `ExpandablePanel` and for the accordion pattern
  (`ExpandableNotifier(group: ...)`). In the accordion case the effect went
  beyond a passive leak: `ExpandableGroupController` only removes a member
  from its `dispose()`, so every panel built and then discarded (a list item
  removed or filtered, a route popped) left a dead controller permanently
  registered in the group. `ExpandableNotifier` now disposes the controller
  it created for itself and leaves a caller-supplied controller alone, same
  as before.

## 0.2.3

- Install instructions now say `pub add` instead of pinning a version. The
  pinned number was stale by several releases and would have been stale again
  after the next one: the README ships frozen in the archive; a hand-edited
  version line is wrong the moment anything is published. This one cannot go
  out of date.

## 0.2.2

- Shorten the screenshot description. pub.dev accepts up to 200 characters but
  scores only those under 160. The previous release published cleanly and
  quietly gave up the documentation points it was meant to earn.

## 0.2.1

- Declare the demo in `pubspec.yaml` so pub.dev shows it on the package page.
  The recording was already in the repository and in the README, but pub.dev
  only renders what the `screenshots:` field points at. Anyone landing on the
  page from search saw text where the demo should have been.

## 0.2.0

- The header is now accessible. `ExpandableButton` exposes the button role and
  the panel's expanded state to the semantics tree, so a screen reader
  announces "collapsed" or "expanded" and announces the change when the user
  presses it. Before this the header was a bare tap target: no role, no state,
  and nothing said when it toggled, which left the widget unusable with
  assistive technology. Every header and header icon goes through
  `ExpandableButton`: panels and accordion groups get it with no changes, and
  the flag follows the controller when the panel is expanded from code.

## 0.1.1

- Docs: sharpen the pub.dev description to lead with the value and the terms people search.

## 0.1.0

First release, continuing the `expandable` package.

* Keeps the public API of `expandable` 5.0.1. Existing code works after
  changing the import.
* Accordion groups through `ExpandableGroupController` for making sibling
  panels mutually exclusive, with an `allowAllCollapsed` option to keep one
  panel open (expandable issue #8).
* `headerPadding` on `ExpandableThemeData` to control the space around the header
  (expandable issue #72).
* Body taps now toggle a standalone `ExpandablePanel` (expandable issue #50).
* A worked example that compiles and runs (expandable issue #114).
