# Package engineering rules: expandable_plus

Rules-Version: expandable_plus/a1e2b4436483653d677d399a5f913a7ce0e0cc3df648af283a625fff652096cf
Core-Version: 1
Core-Digest: 1825fa7ff346dca23e65b1b3bf9b2e3e06959f1414bae9952d596d2f62f09b8f
Survey-Digest: f90f45c8a172068c3ed3b9488ba5a7cb4e58efa93c380d2d9a70b399349ec35e
Evidence-Revision: 182e623
Verified-Revision: unverified

Read CONTRIBUTING.md and docs/engineering/debt.json before editing.

## Current architecture
HEAD 182e623 (2026-08-29), version 1.2.5, 32 commits. It is the drop-in successor of the expandable package. The environment constraints are inconsistent: sdk ^3.9.0 but flutter '>=3.10.0'. The only dependency is the Flutter SDK. The package is a single library: lib/expandable_plus.dart contains 'library;', the imports (dart:math, material) and four parts (theme, controller, group, widgets). The theme layer keeps every setting in ExpandableThemeData with the meaning 'null = inherit from above' and resolves it with withDefaults. State layer: a controller based on ValueNotifier<bool>, an InheritedNotifier that hands it to the subtree, and an optional accordion group. Widget layer: Expandable, ExpandablePanel, ExpandableIcon, ExpandableButton, ScrollOnExpand. There is no show filter. Every public name in src is therefore part of the API. There is no hook/ or bin/. AGENTS.md is written for an agent that uses the package.

## Layers and responsibilities
- lib/expandable_plus.dart: The library directive, the single import point (dart:math, material), four part declarations and the package dartdoc.
- lib/src/theme.dart: Layout enums, ExpandableThemeData (22 nullable fields, defaults, combine, withDefaults, of), ExpandableTheme and a private InheritedWidget.
- lib/src/controller.dart, lib/src/group.dart: ExpandableController (ValueNotifier<bool>, of(required:)), ExpandableNotifier and its ownership flag, a private InheritedNotifier, ExpandableGroupController accordion immutables.
- lib/src/widgets.dart: Expandable (AnimatedCrossFade, a lazy option), ExpandablePanel (header/body layout), ExpandableIcon (rotating arrow), ExpandableButton (semantics), ScrollOnExpand.
- tool/, example/: README figures; the accordion demo and the screen reader transcript test.

## Public API and dependency direction
Because of the part structure, every declaration in src that does not start with '_' enters the API: ExpandablePanelIconPlacement, ExpandablePanelHeaderAlignment, ExpandablePanelBodyAlignment; ExpandableThemeData (defaults, empty, combine, withDefaults, of, collapsed/expandedFade* getters, isEmpty/isFull/nullIfEmpty), ExpandableTheme; ExpandableController (expanded, toggle, of), ExpandableNotifier; ExpandableGroupController (allowAllCollapsed, members, expandedMember, collapseAll); the ExpandableBuilder typedef; Expandable, ExpandablePanel, ExpandableIcon, ExpandableButton, ScrollOnExpand. Private names: _ExpandableControllerNotifier, _ExpandableThemeNotifier and the state classes.

There are no imports between the files (part structure). The library imports dart:math and package:flutter/material.dart. Material is required because of Colors/Icons/InkWell. Logical direction: widgets → {controller, theme}. controller ↔ group are mutually linked through the library private _register and _unregister. theme is independent.

## Error, state and platform contracts
- Theme resolution: all fields are nullable. The chain is defaults + combine + withDefaults. Widgets read fields only from the resolved theme with `!`.
- Error contract: ExpandableController.of(required: true) throws FlutterError.fromParts in every build mode (ErrorSummary, ErrorDescription, ErrorHint, describeElement) (controller.dart:51-84). Constructor combinations are checked with asserts (controller.dart:118-122).
- Ownership: the _ownsController flag (controller.dart:131-174).
- Access: static of(context, rebuildOnChange:) chooses between dependOn and findAncestor. Private InheritedNotifier and InheritedWidget.
- Group: a listener map and a try/finally reentrancy guard _isUpdating (group.dart:27-90).
- Accessibility: Semantics(button: true, expanded: ...) (widgets.dart:427-436).
- Opt-in extension: group, lazy and headerPadding do not change the default behavior.
- Streams/cancellation: no Stream. ScrollOnExpand uses a Future.delayed that is not cancelled. It is guarded by a mounted check. No FFI and no platform check. There is no reduced motion support, and the package does not claim it.

## Package rules
### expandable_plus/EP-01 [MUST]
The package is one library built from part files. A new source file is a part of lib/expandable_plus.dart, and imports go only in that file.
Reason: The architecture is this today: all four files start with 'part of'. Moving to separate libraries changes the visibility of private names, which calls for a separate architectural decision.
Evidence: lib/expandable_plus.dart:16-25; lib/src/controller.dart:1; lib/src/group.dart:1; lib/src/theme.dart:1; lib/src/widgets.dart:1
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-02 [MUST]
Every public top-level name in lib/src ships as API because the library has no show filter. Internals take a leading underscore.
Reason: In a part layout the API boundary is drawn only by the '_' prefix. The existing internal types follow this rule.
Evidence: lib/expandable_plus.dart:22-25; lib/src/controller.dart:128, 186; lib/src/theme.dart:404; lib/src/widgets.dart:59, 293, 472
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-03 [MUST]
Keep the expandable public API as a drop-in replacement. New behaviour is opt-in and leaves callers that do not use it unchanged.
Reason: This is the reason the package exists. The group and lazy dartdocs say it explicitly.
Evidence: lib/expandable_plus.dart:3-12; lib/src/group.dart:6-8; lib/src/widgets.dart:38-40; lib/src/theme.dart:183-188
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-04 [MUST]
Every visual or behavioural setting is a nullable ExpandableThemeData field, resolved through withDefaults before use. A new field goes into the constructor, defaults, combine, isFull, == and hashCode in the same change, with a test for each path.
Reason: The theme resolution pattern is the same in all widgets. The field list is repeated in six places and no test today covers all of them (J1, debt E1).
Evidence: lib/src/theme.dart:37-41, 45-94, 192-234, 265-288, 290-344, 361-375; lib/src/widgets.dart:67, 152, 375, 417, 541
Evidence role: current-pattern
Existing violation: expandable_plus-D001

### expandable_plus/EP-05 [MUST]
A widget that cannot work without a controller calls ExpandableController.of(context, required: true). A missing controller throws a FlutterError with summary, description and hint in every build mode, never an assert alone.
Reason: Dartdoc explains that the assert is stripped in release builds and that this leads to silent breakage. The error contract rests on this rationale.
Evidence: lib/src/controller.dart:51-84; lib/src/widgets.dart:66, 317-321, 358-362, 416, 481-485, 492-496
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-06 [MUST]
Dispose only controllers created here, tracked by _ownsController. A caller's controller or group is never disposed.
Reason: The ownership flag exists for this. The group dartdoc leaves dispose to the caller.
Evidence: lib/src/controller.dart:128-174; lib/src/group.dart:13-14, 102-109
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-07 [MUST]
An interactive element exposes its role and state to assistive technology, as ExpandableButton does with button: true and expanded.
Reason: Screen reader output is documented with an example test. Any new interactive element must meet the same bar.
Evidence: lib/src/widgets.dart:427-436; test/semantics_test.dart; example/test/screen_reader_transcript_test.dart
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-08 [MUST]
Keep CI green on format, flutter analyze --fatal-infos and flutter test --exclude-tags golden. Golden tests stay tagged golden.
Reason: This is the current CI gate. Goldens are generated on a single platform and stay tagged for that reason.
Evidence: .github/workflows/ci.yaml; dart_test.yaml:1-6; analysis_options.yaml:3-4
Evidence role: current-pattern
Existing violation: none

### expandable_plus/EP-09 [SHOULD]
Cover a change to accordion rules with test/group_invariant_walk_test.dart and test/group_edge_cases_test.dart.
Reason: The group invariants (at most one open panel at a time; at least one open panel when allowAllCollapsed is false) are protected in these two files.
Evidence: lib/src/group.dart:44-100; test/group_invariant_walk_test.dart; test/group_edge_cases_test.dart
Evidence role: current-pattern
Existing violation: none

## Required verification
- Working directory: repository root; command: flutter pub get; conditions: ci.yaml job build; evidence: .github/workflows/ci.yaml:22.
- Working directory: repository root; command: dart format --output=none --set-exit-if-changed .; conditions: ci.yaml job build; evidence: .github/workflows/ci.yaml:23.
- Working directory: repository root; command: flutter analyze --fatal-infos; conditions: ci.yaml job build; evidence: .github/workflows/ci.yaml:24.
- Working directory: repository root; command: flutter test --exclude-tags golden; conditions: ci.yaml job build; evidence: .github/workflows/ci.yaml:25.
Not verified by the survey:
- Analysis, test and format were not run (read only). CI history was not measured (no network).
- The difference between the working tree and HEAD was not measured. Line evidence refers to HEAD 182e623.
- Debt items E2 and E3 were found by static reading. They were not exercised.
- The freshness of the golden files and a local golden run were not measured.
- It was not measured whether issue #50 and #72 in code comments belong to this repository or to upstream (no network).
- Most test bodies were not read. Only the test names in theme_test and scroll_on_expand_test were read.
- Test coverage percentage and pub archive contents were not measured.

## Existing debt
The complete register is docs/engineering/debt.json.
- expandable_plus-D001 | small | lib/src/theme.dart:45-94, 192-234, 265-288, 290-344; test/theme_test.dart:73-98 | no J1 guard (field list copy)
  Fix: Write a table-driven test: for each field produce a theme with only that field set; verify that combine inherits that field, that isFull returns false when the field is missing, that inequality differs and that the hash differs. Tie the field count to a constant.
  Closure: A table-driven test sets each theme field alone and checks combine inheritance, isFull, inequality and hash difference. The test ties the field count to a constant.
- expandable_plus-D002 | small | lib/src/controller.dart:153-166 | lifecycle bug (potential, static reading)
  Fix: Apply the ownership pattern from photo_zoom: when the controller returns to null, create a newly adopted controller. Test: exercise the supplied → not supplied transition and the behavior after the old controller is disposed.
  Closure: didUpdateWidget adopts a newly created controller when the supplied controller returns to null and reacts to changes in initialExpanded and group. A test drives the supplied-to-null transition and the state after the old controller is disposed.
- expandable_plus-D003 | medium | lib/src/widgets.dart:523-536; test/scroll_on_expand_test.dart:7-47 | undocumented workaround (J12) + untested behavior
  Fix: First write a red test that verifies the scroll offset. Then derive the wait from animationDuration or tie it to the animation completing. If the delay stays, write a comment about which race it prevents.
  Closure: ScrollOnExpand waits for animationDuration or ties the wait to the animation completing, and any remaining delay documents the race it prevents. A red test first verifies the actual scroll offset.
- expandable_plus-D004 | small | lib/src/widgets.dart:475, 512-517, 540 | unnecessary state
  Fix: Remove the field; use context directly behind a mounted check.
  Closure: The _lastContext field is removed and the code reads context behind a mounted check.
- expandable_plus-D005 | small | lib/src/widgets.dart:523-526 | wrong fallback field
  Fix: Switch to defaults.scrollAnimationDuration. The two defaults are equal and behavior does not change.
  Closure: The no-theme fallback reads defaults.scrollAnimationDuration.
- expandable_plus-D006 | small | lib/src/widgets.dart:299-326, 355-371 | duplicate logic
  Fix: Keep the controller binding work in didChangeDependencies only.
  Closure: ExpandableIcon binds the controller and its listener in didChangeDependencies only, with no duplicate binding in initState.
- expandable_plus-D007 | medium | lib/src/widgets.dart:150-277 | cognitive complexity (J2)
  Fix: Extract the header row and the body into private widgets (_PanelHeader, _PanelBody). panel_test acts as the safety net.
  Closure: ExpandablePanel.build delegates the header row and the body to private _PanelHeader and _PanelBody widgets. panel_test passes.
- expandable_plus-D008 | small | lib/src/theme.dart:236-249 | duplicate formula
  Fix: Keep the public API unchanged; let one pair reference the other or write a one-line note on why they are the same.
  Closure: The collapsed and expanded fade pairs share one formula or carry a one-line note on the sameness, with the public API unchanged.
- expandable_plus-D009 | small | pubspec.yaml environment; example/pubspec.yaml | configuration drift
  Fix: Move the flutter base to a version compatible with sdk ^3.9.0; align the example lint version with the root.
  Closure: pubspec.yaml declares a flutter base compatible with sdk ^3.9.0 and the example uses the same lint version as the root.
- expandable_plus-D010 | small | .github/workflows/ci.yaml; AGENTS.md Layout | CI coverage gap
  Fix: Add pub get, analyze and test steps for example as in photo_zoom.
  Closure: CI runs pub get, analyze and test for example, covering the four cases of screen_reader_transcript_test.dart.
