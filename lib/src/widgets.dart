part of '../expandable_plus.dart';

/// Builds the widget shown by [ExpandablePanel] from its collapsed and expanded
/// children.
typedef ExpandableBuilder =
    Widget Function(BuildContext context, Widget collapsed, Widget expanded);

/// Shows either [collapsed] or [expanded] depending on the controller state, and
/// animates between the two.
class Expandable extends StatelessWidget {
  /// The widget shown while collapsed.
  final Widget collapsed;

  /// The widget shown while expanded.
  final Widget expanded;

  /// The controller that drives the state.
  ///
  /// When null, it is read from the nearest [ExpandableNotifier].
  final ExpandableController? controller;

  /// The theme used for the transition. Falls back to the ambient theme.
  final ExpandableThemeData? theme;

  /// Creates an [Expandable].
  const Expandable({
    super.key,
    required this.collapsed,
    required this.expanded,
    this.controller,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        this.controller ?? ExpandableController.of(context, required: true);
    final theme = ExpandableThemeData.withDefaults(this.theme, context);

    return AnimatedCrossFade(
      alignment: theme.alignment!,
      firstChild: collapsed,
      secondChild: expanded,
      firstCurve: Interval(
        theme.collapsedFadeStart,
        theme.collapsedFadeEnd,
        curve: theme.fadeCurve!,
      ),
      secondCurve: Interval(
        theme.expandedFadeStart,
        theme.expandedFadeEnd,
        curve: theme.fadeCurve!,
      ),
      sizeCurve: theme.sizeCurve!,
      crossFadeState: (controller?.expanded ?? true)
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: theme.animationDuration!,
    );
  }
}

/// A configurable expandable widget with an optional header and expand icon.
///
/// If no [controller] is given and no [ExpandableNotifier] is found in the tree,
/// the panel creates its own controller.
class ExpandablePanel extends StatelessWidget {
  /// The header, always visible above the expandable body.
  final Widget? header;

  /// The widget shown while collapsed.
  final Widget collapsed;

  /// The widget shown while expanded.
  final Widget expanded;

  /// Builds the body from the collapsed and expanded children.
  ///
  /// When null, an [Expandable] is used.
  final ExpandableBuilder? builder;

  /// The controller for this panel.
  ///
  /// When null, a controller is taken from a surrounding [ExpandableNotifier],
  /// or created if none exists.
  final ExpandableController? controller;

  /// The theme for this panel. Falls back to the ambient theme.
  final ExpandableThemeData? theme;

  /// Creates an [ExpandablePanel].
  const ExpandablePanel({
    super.key,
    this.header,
    required this.collapsed,
    required this.expanded,
    this.controller,
    this.builder,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ExpandableThemeData.withDefaults(this.theme, context);

    Widget buildHeaderRow() {
      CrossAxisAlignment headerCrossAxisAlignment() {
        switch (theme.headerAlignment!) {
          case ExpandablePanelHeaderAlignment.top:
            return CrossAxisAlignment.start;
          case ExpandablePanelHeaderAlignment.center:
            return CrossAxisAlignment.center;
          case ExpandablePanelHeaderAlignment.bottom:
            return CrossAxisAlignment.end;
        }
      }

      Widget wrapWithExpandableButton({
        required Widget? widget,
        required bool wrap,
      }) {
        return wrap
            ? ExpandableButton(theme: theme, child: widget)
            : widget ?? const SizedBox.shrink();
      }

      final paddedHeader = Padding(
        padding: theme.headerPadding!,
        child: header ?? const SizedBox.shrink(),
      );

      if (!theme.hasIcon!) {
        return wrapWithExpandableButton(
          widget: paddedHeader,
          wrap: theme.tapHeaderToExpand!,
        );
      } else {
        final rowChildren = <Widget>[
          Expanded(child: paddedHeader),
          wrapWithExpandableButton(
            widget: ExpandableIcon(theme: theme),
            wrap: !theme.tapHeaderToExpand!,
          ),
        ];
        return wrapWithExpandableButton(
          widget: Row(
            crossAxisAlignment: headerCrossAxisAlignment(),
            children: theme.iconPlacement! == ExpandablePanelIconPlacement.right
                ? rowChildren
                : rowChildren.reversed.toList(),
          ),
          wrap: theme.tapHeaderToExpand!,
        );
      }
    }

    Widget buildBody() {
      Widget wrapBody(Widget child, bool tap) {
        Alignment bodyAlignment() {
          switch (theme.bodyAlignment!) {
            case ExpandablePanelBodyAlignment.left:
              return Alignment.topLeft;
            case ExpandablePanelBodyAlignment.center:
              return Alignment.topCenter;
            case ExpandablePanelBodyAlignment.right:
              return Alignment.topRight;
          }
        }

        final aligned = Align(alignment: bodyAlignment(), child: child);

        if (!tap) {
          return aligned;
        }
        // The tap handler resolves the controller from a context below the
        // ExpandableNotifier that wraps this panel. The original package looked
        // it up from the panel's own build context, which sits above that
        // notifier, so a standalone panel never found a controller and body
        // taps did nothing. See issue #50.
        return Builder(
          builder: (innerContext) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => ExpandableController.of(
              innerContext,
              rebuildOnChange: false,
            )?.toggle(),
            child: aligned,
          ),
        );
      }

      final effectiveBuilder =
          builder ??
          (BuildContext context, Widget collapsed, Widget expanded) {
            return Expandable(
              collapsed: collapsed,
              expanded: expanded,
              theme: theme,
            );
          };

      return effectiveBuilder(
        context,
        wrapBody(collapsed, theme.tapBodyToExpand!),
        wrapBody(expanded, theme.tapBodyToCollapse!),
      );
    }

    Widget buildWithHeader() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeaderRow(), buildBody()],
      );
    }

    final panel = header != null ? buildWithHeader() : buildBody();

    if (controller != null) {
      return ExpandableNotifier(controller: controller, child: panel);
    } else {
      final ambient = ExpandableController.of(context, rebuildOnChange: false);
      if (ambient == null) {
        return ExpandableNotifier(child: panel);
      } else {
        return panel;
      }
    }
  }
}

/// An arrow icon that toggles the enclosing [ExpandableController] when tapped,
/// rotating as the state changes.
class ExpandableIcon extends StatefulWidget {
  /// The theme controlling the icon. Falls back to the ambient theme.
  final ExpandableThemeData? theme;

  /// Creates an [ExpandableIcon].
  const ExpandableIcon({super.key, this.theme});

  @override
  State<ExpandableIcon> createState() => _ExpandableIconState();
}

class _ExpandableIconState extends State<ExpandableIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> animation;
  ExpandableController? controller;

  @override
  void initState() {
    super.initState();
    final theme = ExpandableThemeData.withDefaults(
      widget.theme,
      context,
      rebuildOnChange: false,
    );
    animationController = AnimationController(
      duration: theme.animationDuration,
      vsync: this,
    );
    animation = animationController.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: theme.sizeCurve!)),
    );
    controller = ExpandableController.of(
      context,
      rebuildOnChange: false,
      required: true,
    );
    controller?.addListener(_expandedStateChanged);
    if (controller?.expanded ?? true) {
      animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller?.removeListener(_expandedStateChanged);
    animationController.dispose();
    super.dispose();
  }

  void _expandedStateChanged() {
    final ctrl = controller;
    if (ctrl == null) {
      return;
    }
    if (ctrl.expanded &&
        const [
          AnimationStatus.dismissed,
          AnimationStatus.reverse,
        ].contains(animationController.status)) {
      animationController.forward();
    } else if (!ctrl.expanded &&
        const [
          AnimationStatus.completed,
          AnimationStatus.forward,
        ].contains(animationController.status)) {
      animationController.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = ExpandableController.of(
      context,
      rebuildOnChange: false,
      required: true,
    );
    if (newController != controller) {
      controller?.removeListener(_expandedStateChanged);
      controller = newController;
      controller?.addListener(_expandedStateChanged);
      if (controller?.expanded ?? true) {
        animationController.value = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ExpandableThemeData.withDefaults(widget.theme, context);

    return Padding(
      padding: theme.iconPadding!,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final showSecondIcon =
              theme.collapseIcon! != theme.expandIcon! &&
              animationController.value >= 0.5;
          return Transform.rotate(
            angle:
                theme.iconRotationAngle! *
                (showSecondIcon
                    ? -(1.0 - animationController.value)
                    : animationController.value),
            child: Icon(
              showSecondIcon ? theme.collapseIcon! : theme.expandIcon!,
              color: theme.iconColor!,
              size: theme.iconSize!,
            ),
          );
        },
      ),
    );
  }
}

/// Toggles the enclosing [ExpandableController] when the user taps [child].
class ExpandableButton extends StatelessWidget {
  /// The tappable content.
  final Widget? child;

  /// The theme controlling the ripple. Falls back to the ambient theme.
  final ExpandableThemeData? theme;

  /// Creates an [ExpandableButton].
  const ExpandableButton({super.key, this.child, this.theme});

  @override
  Widget build(BuildContext context) {
    final controller = ExpandableController.of(context, required: true);
    final theme = ExpandableThemeData.withDefaults(this.theme, context);

    final Widget tappable = theme.useInkWell!
        ? InkWell(
            onTap: controller?.toggle,
            borderRadius: theme.inkWellBorderRadius!,
            child: child,
          )
        : GestureDetector(onTap: controller?.toggle, child: child);

    // A tap target alone tells a screen reader nothing about what it does. The
    // two facts a user needs here are that this is a button and whether the
    // panel it controls is currently open, so the announcement changes from
    // "collapsed" to "expanded" when it is pressed. This widget rebuilds on
    // controller changes, so the flag stays current.
    return Semantics(
      button: true,
      expanded: controller?.expanded,
      child: tappable,
    );
  }
}

/// Scrolls its [child] into view when the enclosing [ExpandableController]
/// changes state, so an expanded panel becomes visible in a scroll view.
///
/// See also:
///
///  * [RenderObject.showOnScreen], which does the scrolling.
class ScrollOnExpand extends StatefulWidget {
  /// The widget to keep visible.
  final Widget child;

  /// Whether to scroll into view when expanding.
  final bool scrollOnExpand;

  /// Whether to scroll into view when collapsing.
  final bool scrollOnCollapse;

  /// The theme supplying the scroll animation duration.
  final ExpandableThemeData? theme;

  /// Creates a [ScrollOnExpand].
  const ScrollOnExpand({
    super.key,
    required this.child,
    this.scrollOnExpand = true,
    this.scrollOnCollapse = true,
    this.theme,
  });

  @override
  State<ScrollOnExpand> createState() => _ScrollOnExpandState();
}

class _ScrollOnExpandState extends State<ScrollOnExpand> {
  ExpandableController? _controller;
  int _isAnimating = 0;
  BuildContext? _lastContext;
  ExpandableThemeData? _theme;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController.of(
      context,
      rebuildOnChange: false,
      required: true,
    );
    _controller?.addListener(_expandedStateChanged);
  }

  @override
  void didUpdateWidget(ScrollOnExpand oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newController = ExpandableController.of(
      context,
      rebuildOnChange: false,
      required: true,
    );
    if (newController != _controller) {
      _controller?.removeListener(_expandedStateChanged);
      _controller = newController;
      _controller?.addListener(_expandedStateChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_expandedStateChanged);
    super.dispose();
  }

  void _animationComplete() {
    _isAnimating--;
    if (_isAnimating == 0 && _lastContext != null && mounted) {
      final expanded = _controller?.expanded ?? true;
      if ((expanded && widget.scrollOnExpand) ||
          (!expanded && widget.scrollOnCollapse)) {
        _lastContext?.findRenderObject()?.showOnScreen(
          duration: _animationDuration,
        );
      }
    }
  }

  Duration get _animationDuration {
    return _theme?.scrollAnimationDuration ??
        ExpandableThemeData.defaults.animationDuration!;
  }

  void _expandedStateChanged() {
    if (_theme != null) {
      _isAnimating++;
      Future.delayed(
        _animationDuration + const Duration(milliseconds: 10),
        _animationComplete,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _lastContext = context;
    _theme = ExpandableThemeData.withDefaults(widget.theme, context);
    return widget.child;
  }
}
