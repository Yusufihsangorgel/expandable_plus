part of '../expandable_plus.dart';

/// Controls whether one or more [Expandable] widgets are expanded or collapsed.
///
/// A controller is a [ValueNotifier] of a `bool`, where `true` means expanded.
/// Provide it to a subtree with an [ExpandableNotifier], or pass it directly to
/// [Expandable] or [ExpandablePanel].
///
/// Pass a [group] to make the controller part of an accordion, where expanding
/// one member collapses the others. See [ExpandableGroupController].
class ExpandableController extends ValueNotifier<bool> {
  /// Creates a controller.
  ///
  /// The controller starts expanded when [initialExpanded] is true, and
  /// collapsed otherwise. When a [group] is given, the controller joins that
  /// accordion group.
  ExpandableController({bool? initialExpanded, this.group})
    : super(initialExpanded ?? false) {
    group?._register(this);
  }

  /// The accordion group this controller belongs to, or `null` when it is not
  /// part of a group.
  final ExpandableGroupController? group;

  /// Whether the state is currently expanded.
  bool get expanded => value;

  /// Sets the expanded state.
  set expanded(bool exp) {
    value = exp;
  }

  /// Flips the state between expanded and collapsed.
  void toggle() {
    expanded = !expanded;
  }

  @override
  void dispose() {
    group?._unregister(this);
    super.dispose();
  }

  /// Returns the controller provided by the nearest [ExpandableNotifier]
  /// ancestor, or `null` when there is none.
  ///
  /// When [rebuildOnChange] is true (the default), the calling widget rebuilds
  /// when the controller changes. Set [required] to true to assert that a
  /// controller is present.
  static ExpandableController? of(
    BuildContext context, {
    bool rebuildOnChange = true,
    bool required = false,
  }) {
    final notifier = rebuildOnChange
        ? context
              .dependOnInheritedWidgetOfExactType<
                _ExpandableControllerNotifier
              >()
        : context
              .findAncestorWidgetOfExactType<_ExpandableControllerNotifier>();
    assert(
      notifier != null || !required,
      'ExpandableNotifier is not found in the widget tree',
    );
    return notifier?.notifier;
  }
}

/// Provides an [ExpandableController] to a widget subtree.
///
/// Use it to make several [Expandable] widgets share a single controller, or to
/// supply a controller to an [ExpandablePanel].
class ExpandableNotifier extends StatefulWidget {
  /// The controller to provide.
  ///
  /// When null, a controller is created from [initialExpanded] and [group].
  final ExpandableController? controller;

  /// The initial expanded state used when [controller] is not provided.
  ///
  /// Must not be combined with [controller].
  final bool? initialExpanded;

  /// The accordion group joined by the controller created for you.
  ///
  /// Must not be combined with [controller]; set the group on the controller
  /// itself in that case.
  final ExpandableGroupController? group;

  /// The subtree that can access the provided controller.
  final Widget child;

  /// Creates an [ExpandableNotifier].
  const ExpandableNotifier({
    super.key,
    this.controller,
    this.initialExpanded,
    this.group,
    required this.child,
  }) : assert(!(controller != null && initialExpanded != null)),
       assert(
         !(controller != null && group != null),
         'Set the group on the controller when you provide your own controller.',
       );

  @override
  State<ExpandableNotifier> createState() => _ExpandableNotifierState();
}

class _ExpandableNotifierState extends State<ExpandableNotifier> {
  ExpandableController? controller;

  /// Whether [controller] was created by this state (as opposed to being
  /// supplied by [ExpandableNotifier.controller]).
  ///
  /// Only a controller this state created is disposed by this state; a
  /// caller-supplied controller stays owned by its caller.
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    final provided = widget.controller;
    if (provided != null) {
      controller = provided;
    } else {
      controller = ExpandableController(
        initialExpanded: widget.initialExpanded ?? false,
        group: widget.group,
      );
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(ExpandableNotifier oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      if (_ownsController) {
        controller?.dispose();
      }
      setState(() {
        controller = widget.controller;
        _ownsController = false;
      });
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ExpandableControllerNotifier(
      controller: controller,
      child: widget.child,
    );
  }
}

/// Makes an [ExpandableController] available to descendants via inheritance.
class _ExpandableControllerNotifier
    extends InheritedNotifier<ExpandableController> {
  const _ExpandableControllerNotifier({
    required ExpandableController? controller,
    required super.child,
  }) : super(notifier: controller);
}
