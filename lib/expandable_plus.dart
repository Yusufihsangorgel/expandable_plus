/// Expandable and collapsible panels for Flutter.
///
/// `expandable_plus` is a maintained continuation of the `expandable`
/// package. It keeps the original type names, constructor parameters and
/// default values. Most code compiles after you change the import. A few
/// behaviours differ, and the README's migration section lists them. It also
/// adds a few things the original was missing:
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

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

part 'src/theme.dart';
part 'src/controller.dart';
part 'src/group.dart';
part 'src/widgets.dart';
