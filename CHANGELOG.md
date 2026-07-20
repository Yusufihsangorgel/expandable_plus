## 0.2.2

- Shorten the screenshot description. pub.dev accepts up to 200 characters but
  scores only those under 160, so the previous release published cleanly and
  quietly gave up the documentation points it was meant to earn.

## 0.2.1

- Declare the demo in `pubspec.yaml` so pub.dev shows it on the package page.
  The recording was already in the repository and in the README, but pub.dev
  only renders what the `screenshots:` field points at, so anyone landing on
  the page from search saw text where the demo should have been.

## 0.2.0

- The header is now accessible. `ExpandableButton` exposes the button role and
  the panel's expanded state to the semantics tree, so a screen reader
  announces "collapsed" or "expanded" and announces the change when the user
  presses it. Before this the header was a bare tap target: no role, no state,
  and nothing said when it toggled, which left the widget unusable with
  assistive technology. Every header and header icon goes through
  `ExpandableButton`, so panels and accordion groups get it with no changes,
  and the flag follows the controller when the panel is expanded from code.

## 0.1.1

- Docs: sharpen the pub.dev description to lead with the value and the terms people search.

## 0.1.0

First release, continuing the `expandable` package.

* Keeps the public API of `expandable` 5.0.1, so existing code works after
  changing the import.
* Accordion groups through `ExpandableGroupController`, so sibling panels can be
  made mutually exclusive, with an `allowAllCollapsed` option to keep one panel
  open (expandable issue #8).
* `headerPadding` on `ExpandableThemeData` to control the space around the header
  (expandable issue #72).
* Body taps now toggle a standalone `ExpandablePanel` (expandable issue #50).
* A worked example that compiles and runs (expandable issue #114).
