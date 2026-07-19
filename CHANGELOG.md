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
