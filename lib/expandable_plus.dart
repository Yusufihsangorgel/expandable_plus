/// Expandable and collapsible panels for Flutter.
///
/// `expandable_plus` is a maintained, drop-in continuation of the `expandable`
/// package. It keeps the original public API, so existing code keeps working
/// after you change the import, and it adds a few things the original was
/// missing:
///
///  * Accordion groups, so sibling panels can be made mutually exclusive. See
///    [ExpandableGroupController].
///  * A configurable [ExpandableThemeData.headerPadding].
///  * A fix for body taps not toggling a standalone [ExpandablePanel].
///
/// Most apps need either [ExpandablePanel] for a ready-made panel, or the
/// combination of [ExpandableNotifier], [Expandable] and [ExpandableButton] for
/// a custom layout.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'src/theme.dart';
part 'src/controller.dart';
part 'src/group.dart';
part 'src/widgets.dart';
