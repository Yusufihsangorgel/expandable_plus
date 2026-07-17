part of '../expandable_plus.dart';

/// Coordinates a set of [ExpandableController]s so that at most one is expanded
/// at a time, like an accordion.
///
/// This is opt-in. A controller joins a group by passing it to
/// [ExpandableController.new] or to [ExpandableNotifier.new]. Controllers that
/// are not in a group are unaffected, so existing code keeps its behaviour.
///
/// When a member expands, every other member collapses. Set [allowAllCollapsed]
/// to `false` to keep at least one member expanded at all times.
///
/// The group holds listeners on its members, so call [dispose] when you are done
/// with it (for example in your `State.dispose`).
class ExpandableGroupController extends ChangeNotifier {
  /// Creates an accordion group.
  ///
  /// When [allowAllCollapsed] is `false`, the group keeps one member expanded:
  /// collapsing the only expanded member re-expands it.
  ExpandableGroupController({this.allowAllCollapsed = true});

  /// Whether every member may be collapsed at the same time.
  ///
  /// When `false`, the group always keeps one member expanded.
  final bool allowAllCollapsed;

  final Map<ExpandableController, VoidCallback> _listeners =
      <ExpandableController, VoidCallback>{};
  bool _isUpdating = false;

  /// The controllers that currently belong to this group, in join order.
  Iterable<ExpandableController> get members => _listeners.keys;

  /// The expanded member, or `null` when every member is collapsed.
  ExpandableController? get expandedMember {
    for (final member in _listeners.keys) {
      if (member.expanded) {
        return member;
      }
    }
    return null;
  }

  void _register(ExpandableController controller) {
    if (_listeners.containsKey(controller)) {
      return;
    }
    void listener() => _onMemberChanged(controller);
    _listeners[controller] = listener;
    controller.addListener(listener);
    if (controller.expanded) {
      _onMemberChanged(controller);
    }
  }

  void _unregister(ExpandableController controller) {
    final listener = _listeners.remove(controller);
    if (listener != null) {
      controller.removeListener(listener);
    }
  }

  void _onMemberChanged(ExpandableController changed) {
    if (_isUpdating) {
      return;
    }
    _isUpdating = true;
    try {
      if (changed.expanded) {
        for (final member in _listeners.keys.toList()) {
          if (!identical(member, changed)) {
            member.expanded = false;
          }
        }
      } else if (!allowAllCollapsed && expandedMember == null) {
        changed.expanded = true;
      }
    } finally {
      _isUpdating = false;
    }
    notifyListeners();
  }

  /// Collapses every member of the group.
  ///
  /// When [allowAllCollapsed] is `false`, the group immediately re-expands the
  /// member collapsed last, so one member stays open.
  void collapseAll() {
    for (final member in _listeners.keys.toList()) {
      member.expanded = false;
    }
  }

  @override
  void dispose() {
    for (final entry in _listeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _listeners.clear();
    super.dispose();
  }
}
