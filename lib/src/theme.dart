part of '../expandable_plus.dart';

/// Determines the placement of the expand/collapse icon in [ExpandablePanel].
enum ExpandablePanelIconPlacement {
  /// The icon is shown on the left side of the header.
  left,

  /// The icon is shown on the right side of the header.
  right,
}

/// Determines how the header is aligned relative to the expand/collapse icon in
/// [ExpandablePanel].
enum ExpandablePanelHeaderAlignment {
  /// The header and the icon are aligned at their top edges.
  top,

  /// The header and the icon are aligned at their centers.
  center,

  /// The header and the icon are aligned at their bottom edges.
  bottom,
}

/// Determines the horizontal alignment of the body in [ExpandablePanel].
enum ExpandablePanelBodyAlignment {
  /// The body is aligned to the left.
  left,

  /// The body is centered.
  center,

  /// The body is aligned to the right.
  right,
}

/// Visual and behavioural configuration for the expandable widgets.
///
/// Every field is nullable. A `null` value means "inherit from an enclosing
/// [ExpandableTheme], or from [ExpandableThemeData.defaults]". Use [withDefaults]
/// to resolve a theme against the surrounding [BuildContext].
class ExpandableThemeData {
  /// Creates a theme. Any field left unset falls back to an enclosing
  /// [ExpandableTheme] or to [defaults] when the theme is resolved.
  const ExpandableThemeData({
    this.iconColor,
    this.useInkWell,
    this.animationDuration,
    this.scrollAnimationDuration,
    this.crossFadePoint,
    this.fadeCurve,
    this.sizeCurve,
    this.alignment,
    this.headerAlignment,
    this.bodyAlignment,
    this.iconPlacement,
    this.tapHeaderToExpand,
    this.tapBodyToExpand,
    this.tapBodyToCollapse,
    this.hasIcon,
    this.iconSize,
    this.iconPadding,
    this.iconRotationAngle,
    this.expandIcon,
    this.collapseIcon,
    this.inkWellBorderRadius,
    this.headerPadding,
  });

  /// The fallback theme used when a value is not provided anywhere else.
  static final ExpandableThemeData defaults = ExpandableThemeData(
    iconColor: Colors.black54,
    useInkWell: true,
    inkWellBorderRadius: BorderRadius.zero,
    animationDuration: const Duration(milliseconds: 300),
    scrollAnimationDuration: const Duration(milliseconds: 300),
    crossFadePoint: 0.5,
    fadeCurve: Curves.linear,
    sizeCurve: Curves.fastOutSlowIn,
    alignment: Alignment.topLeft,
    headerAlignment: ExpandablePanelHeaderAlignment.top,
    bodyAlignment: ExpandablePanelBodyAlignment.left,
    iconPlacement: ExpandablePanelIconPlacement.right,
    tapHeaderToExpand: true,
    tapBodyToExpand: false,
    tapBodyToCollapse: false,
    hasIcon: true,
    iconSize: 24.0,
    iconPadding: const EdgeInsets.all(8.0),
    iconRotationAngle: -math.pi,
    expandIcon: Icons.expand_more,
    collapseIcon: Icons.expand_more,
    headerPadding: EdgeInsets.zero,
  );

  /// A theme with every field left unset. Equal to `const ExpandableThemeData()`.
  static final ExpandableThemeData empty = const ExpandableThemeData();

  /// The color of the expand/collapse icon.
  final Color? iconColor;

  /// Whether to use an [InkWell] in the header, for a ripple effect on tap.
  final bool? useInkWell;

  /// The duration of the transition between the collapsed and expanded states.
  final Duration? animationDuration;

  /// The duration of the scroll animation used by [ScrollOnExpand].
  final Duration? scrollAnimationDuration;

  /// The point in the cross-fade timeline (from 0 to 1) where the collapsed and
  /// expanded widgets are half-visible.
  ///
  /// If set to 0, the expanded widget is shown at full opacity as soon as the
  /// size transition starts. This is useful when the collapsed widget is empty,
  /// or when showing text that is partially visible while collapsed.
  ///
  /// If set to 0.5, the expanded and collapsed widgets are shown at half opacity
  /// in the middle of the size animation, with a cross-fade across the whole
  /// transition.
  ///
  /// If set to 1, the expanded widget is shown only at the very end of the size
  /// animation.
  ///
  /// When collapsing, the effect is reversed.
  final double? crossFadePoint;

  /// The alignment of the widgets while animating between states.
  final AlignmentGeometry? alignment;

  /// The curve of the fade animation between states.
  final Curve? fadeCurve;

  /// The curve of the size animation between states.
  final Curve? sizeCurve;

  /// The vertical alignment of the header relative to the icon in
  /// [ExpandablePanel].
  final ExpandablePanelHeaderAlignment? headerAlignment;

  /// The horizontal alignment of the body in [ExpandablePanel].
  final ExpandablePanelBodyAlignment? bodyAlignment;

  /// The placement of the expand/collapse icon in [ExpandablePanel].
  final ExpandablePanelIconPlacement? iconPlacement;

  /// Whether tapping the header of [ExpandablePanel] toggles the state.
  final bool? tapHeaderToExpand;

  /// Whether tapping the body of [ExpandablePanel] expands it.
  final bool? tapBodyToExpand;

  /// Whether tapping the body of [ExpandablePanel] collapses it.
  final bool? tapBodyToCollapse;

  /// Whether an icon is shown in the header of [ExpandablePanel].
  final bool? hasIcon;

  /// The size of the expand/collapse icon.
  final double? iconSize;

  /// The padding around the expand/collapse icon.
  final EdgeInsets? iconPadding;

  /// The icon rotation angle in clockwise radians.
  ///
  /// For example, pass `math.pi` to rotate the icon by 180 degrees clockwise
  /// when it toggles.
  final double? iconRotationAngle;

  /// The icon shown in the collapsed state.
  final IconData? expandIcon;

  /// The icon shown in the expanded state.
  ///
  /// If it is the same as [expandIcon], that icon is shown upside-down while
  /// expanded.
  final IconData? collapseIcon;

  /// The border radius of the header [InkWell] when [useInkWell] is true.
  final BorderRadius? inkWellBorderRadius;

  /// The padding around the header of [ExpandablePanel].
  ///
  /// Defaults to [EdgeInsets.zero], which matches the original `expandable`
  /// package. Use it to add space around the header, or keep it zero to remove
  /// any surrounding padding.
  final EdgeInsetsGeometry? headerPadding;

  /// Returns a theme where each field of [theme] falls back to the same field
  /// of [defaults].
  static ExpandableThemeData combine(
    ExpandableThemeData? theme,
    ExpandableThemeData? defaults,
  ) {
    if (defaults == null || defaults.isEmpty()) {
      return theme ?? empty;
    } else if (theme == null || theme.isEmpty()) {
      return defaults;
    } else if (theme.isFull()) {
      return theme;
    } else {
      return ExpandableThemeData(
        iconColor: theme.iconColor ?? defaults.iconColor,
        useInkWell: theme.useInkWell ?? defaults.useInkWell,
        inkWellBorderRadius:
            theme.inkWellBorderRadius ?? defaults.inkWellBorderRadius,
        animationDuration:
            theme.animationDuration ?? defaults.animationDuration,
        scrollAnimationDuration:
            theme.scrollAnimationDuration ?? defaults.scrollAnimationDuration,
        crossFadePoint: theme.crossFadePoint ?? defaults.crossFadePoint,
        fadeCurve: theme.fadeCurve ?? defaults.fadeCurve,
        sizeCurve: theme.sizeCurve ?? defaults.sizeCurve,
        alignment: theme.alignment ?? defaults.alignment,
        headerAlignment: theme.headerAlignment ?? defaults.headerAlignment,
        bodyAlignment: theme.bodyAlignment ?? defaults.bodyAlignment,
        iconPlacement: theme.iconPlacement ?? defaults.iconPlacement,
        tapHeaderToExpand:
            theme.tapHeaderToExpand ?? defaults.tapHeaderToExpand,
        tapBodyToExpand: theme.tapBodyToExpand ?? defaults.tapBodyToExpand,
        tapBodyToCollapse:
            theme.tapBodyToCollapse ?? defaults.tapBodyToCollapse,
        hasIcon: theme.hasIcon ?? defaults.hasIcon,
        iconSize: theme.iconSize ?? defaults.iconSize,
        iconPadding: theme.iconPadding ?? defaults.iconPadding,
        iconRotationAngle:
            theme.iconRotationAngle ?? defaults.iconRotationAngle,
        expandIcon: theme.expandIcon ?? defaults.expandIcon,
        collapseIcon: theme.collapseIcon ?? defaults.collapseIcon,
        headerPadding: theme.headerPadding ?? defaults.headerPadding,
      );
    }
  }

  /// The start of the fade interval for the collapsed widget.
  double get collapsedFadeStart =>
      crossFadePoint! < 0.5 ? 0 : (crossFadePoint! * 2 - 1);

  /// The end of the fade interval for the collapsed widget.
  double get collapsedFadeEnd =>
      crossFadePoint! < 0.5 ? 2 * crossFadePoint! : 1;

  /// The start of the fade interval for the expanded widget.
  double get expandedFadeStart =>
      crossFadePoint! < 0.5 ? 0 : (crossFadePoint! * 2 - 1);

  /// The end of the fade interval for the expanded widget.
  double get expandedFadeEnd => crossFadePoint! < 0.5 ? 2 * crossFadePoint! : 1;

  /// Returns `null` if this theme is empty, otherwise returns this theme.
  ExpandableThemeData? nullIfEmpty() {
    return isEmpty() ? null : this;
  }

  /// Whether every field of this theme is unset.
  bool isEmpty() {
    return this == empty;
  }

  /// Whether every field of this theme is set.
  ///
  /// When true, the theme can be used as-is without falling back to any
  /// defaults.
  bool isFull() {
    return iconColor != null &&
        useInkWell != null &&
        inkWellBorderRadius != null &&
        animationDuration != null &&
        scrollAnimationDuration != null &&
        crossFadePoint != null &&
        fadeCurve != null &&
        sizeCurve != null &&
        alignment != null &&
        headerAlignment != null &&
        bodyAlignment != null &&
        iconPlacement != null &&
        tapHeaderToExpand != null &&
        tapBodyToExpand != null &&
        tapBodyToCollapse != null &&
        hasIcon != null &&
        iconSize != null &&
        iconPadding != null &&
        iconRotationAngle != null &&
        expandIcon != null &&
        collapseIcon != null &&
        headerPadding != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ExpandableThemeData &&
        iconColor == other.iconColor &&
        useInkWell == other.useInkWell &&
        inkWellBorderRadius == other.inkWellBorderRadius &&
        animationDuration == other.animationDuration &&
        scrollAnimationDuration == other.scrollAnimationDuration &&
        crossFadePoint == other.crossFadePoint &&
        fadeCurve == other.fadeCurve &&
        sizeCurve == other.sizeCurve &&
        alignment == other.alignment &&
        headerAlignment == other.headerAlignment &&
        bodyAlignment == other.bodyAlignment &&
        iconPlacement == other.iconPlacement &&
        tapHeaderToExpand == other.tapHeaderToExpand &&
        tapBodyToExpand == other.tapBodyToExpand &&
        tapBodyToCollapse == other.tapBodyToCollapse &&
        hasIcon == other.hasIcon &&
        iconSize == other.iconSize &&
        iconPadding == other.iconPadding &&
        iconRotationAngle == other.iconRotationAngle &&
        expandIcon == other.expandIcon &&
        collapseIcon == other.collapseIcon &&
        headerPadding == other.headerPadding;
  }

  @override
  int get hashCode => Object.hashAll([
    iconColor,
    useInkWell,
    inkWellBorderRadius,
    animationDuration,
    scrollAnimationDuration,
    crossFadePoint,
    fadeCurve,
    sizeCurve,
    alignment,
    headerAlignment,
    bodyAlignment,
    iconPlacement,
    tapHeaderToExpand,
    tapBodyToExpand,
    tapBodyToCollapse,
    hasIcon,
    iconSize,
    iconPadding,
    iconRotationAngle,
    expandIcon,
    collapseIcon,
    headerPadding,
  ]);

  /// Returns the theme from the nearest [ExpandableTheme] ancestor, or
  /// [defaults] when there is none.
  ///
  /// When [rebuildOnChange] is true (the default), the calling widget rebuilds
  /// when the ambient theme changes.
  static ExpandableThemeData of(
    BuildContext context, {
    bool rebuildOnChange = true,
  }) {
    final notifier = rebuildOnChange
        ? context.dependOnInheritedWidgetOfExactType<_ExpandableThemeNotifier>()
        : context.findAncestorWidgetOfExactType<_ExpandableThemeNotifier>();
    return notifier?.themeData ?? defaults;
  }

  /// Resolves [theme] against the ambient theme and the built-in [defaults], so
  /// the returned theme has every field set.
  static ExpandableThemeData withDefaults(
    ExpandableThemeData? theme,
    BuildContext context, {
    bool rebuildOnChange = true,
  }) {
    if (theme != null && theme.isFull()) {
      return theme;
    }
    return combine(
      combine(theme, of(context, rebuildOnChange: rebuildOnChange)),
      defaults,
    );
  }
}

/// Provides an [ExpandableThemeData] to a widget subtree.
///
/// Nested [ExpandableTheme] widgets combine, with inner values overriding outer
/// ones.
class ExpandableTheme extends StatelessWidget {
  /// The theme to provide to descendants.
  final ExpandableThemeData data;

  /// The subtree that reads the theme.
  final Widget child;

  /// Creates an [ExpandableTheme].
  const ExpandableTheme({super.key, required this.data, required this.child});

  @override
  Widget build(BuildContext context) {
    final notifier = context
        .dependOnInheritedWidgetOfExactType<_ExpandableThemeNotifier>();
    return _ExpandableThemeNotifier(
      themeData: ExpandableThemeData.combine(data, notifier?.themeData),
      child: child,
    );
  }
}

/// Carries an [ExpandableThemeData] down the tree via inheritance.
class _ExpandableThemeNotifier extends InheritedWidget {
  const _ExpandableThemeNotifier({
    required this.themeData,
    required super.child,
  });

  final ExpandableThemeData? themeData;

  @override
  bool updateShouldNotify(covariant _ExpandableThemeNotifier oldWidget) {
    return oldWidget.themeData != themeData;
  }
}
