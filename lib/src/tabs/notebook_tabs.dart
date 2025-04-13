import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/rendering.dart';
import 'package:lucid/lucid.dart';

// TODO: tests
//
// Overflow checks:
//   - Initial layout
//      - tabs fit
//      - tabs don't fit
//   - Resize - initially they fit, shrink window until they don't
//   - Using add button
//      - zero tabs, add until they don't fit
//   - Controller addition
//      - zero tabs, add until they don't fit
//
// Activation checks:
//   - Start with zero tabs, add first tab, it's activated, add 2nd tab, it's not activated
//   - Closing the active tab changes to previously active tab
//     - also check what happens if previously active tab is gone
//   - When closing the active tab, and all previously active tabs are gone, make the first tab active
//   - Closing all tabs doesn't break anything

/// A tab bar that displays a variable number of tabs, similar to how
/// tabs appear along the side of a notebook.
///
/// Tabs are displayed in a row. Only one tab may be active at a time.
class NotebookTabBar extends StatefulWidget {
  const NotebookTabBar({
    super.key,
    required this.controller,
    this.paddingStart = 0,
    this.paddingEnd = 0,
    required this.maxTabWidth,
    required this.lightStyle,
    this.darkStyle,
    required this.onAddTabPressed,
  });

  final NotebookTabController controller;

  final double paddingStart;
  final double paddingEnd;

  final double maxTabWidth;

  final NotebookTabBarStyle lightStyle;
  final NotebookTabBarStyle? darkStyle;

  final VoidCallback onAddTabPressed;

  @override
  State<NotebookTabBar> createState() => _NotebookTabBarState();
}

class _NotebookTabBarState extends State<NotebookTabBar> {
  late final NotebookTabBarControllerListener _controllerListener;

  int? _hoveredTab;

  @override
  void initState() {
    super.initState();

    _controllerListener = NotebookTabBarControllerListener(
      onTabAdded: _onTabAdded,
      onTabActivated: _onTabActivated,
      onTabUpdated: _onTabUpdated,
      onTabRemoved: _onTabRemoved,
    );
    widget.controller.addListener(_controllerListener);
  }

  @override
  void didUpdateWidget(NotebookTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_controllerListener);
      widget.controller.addListener(_controllerListener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _onTabAdded(int index, TabDescriptor tab) {
    setState(() {
      // Build the new tab
    });
  }

  void _onTabActivated(TabDescriptor tab) {
    setState(() {
      // Build the newly updated tab
    });
  }

  void _onTabUpdated(int index, {required TabDescriptor newTab, required TabDescriptor oldTab}) {
    setState(() {
      // Build the updated tab
    });
  }

  void _onTabRemoved(int index, TabDescriptor tab) {
    setState(() {
      if (_hoveredTab == index) {
        _hoveredTab = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = LucidBrightness.of(context);
    final style = switch (brightness) {
      Brightness.light => widget.lightStyle,
      Brightness.dark => widget.darkStyle ?? widget.lightStyle,
    };

    return IconTheme(
      data: IconTheme.of(context).copyWith(
        color: style.newTabIconTheme.color,
      ),
      child: Container(
        height: 42,
        color: style.background,
        padding: const EdgeInsets.only(top: 8),
        child: _TabBarLayout(
          children: [
            SizedBox(width: widget.paddingStart),
            for (int i = 0; i < widget.controller.tabs.length; i += 1) ...[
              Tab(
                child: IntrinsicWidth(
                  // ^ Use intrinsic width so that tabs that don't need the "max width", don't
                  //   take up the max width. The issue is that we use a `Row` with an `Expanded`,
                  //   which otherwise will take the max width no matter what.
                  child: NotebookTab(
                    maxWidth: widget.maxTabWidth,
                    background: style.tabStyle.background,
                    isActive: i == widget.controller.activeTabIndex,
                    onTabPressed: () {
                      widget.controller.activateTabAt(i);
                    },
                    onClosePressed: () => widget.controller.removeTabAt(i),
                    onHover: () {
                      setState(() {
                        _hoveredTab = i;
                      });
                    },
                    onExit: () {
                      setState(() {
                        _hoveredTab = null;
                      });
                    },
                    child: _buildTab(
                      context,
                      widget.controller.getTabAt(i).id,
                      i,
                      style.newTabIconTheme,
                      TextStyle(
                        color: widget.controller.activeTabIndex == i //
                            ? style.tabStyle.activeTabTextColor
                            : style.tabStyle.inactiveTabTextColor,
                        fontSize: 12,
                      ),
                      isActive: widget.controller.activeTabIndex == i,
                    ),
                  ),
                ),
              ),
              _buildDividerAfter(context, i, style.dividerColor),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment(-1.0, -0.5),
                child: Builder(
                  // ^ To access the icon theme.
                  builder: (context) {
                    return IconButton(
                      icon: Icons.add,
                      iconSize: 18,
                      iconColor: IconTheme.of(context).color!,
                      onPressed: widget.onAddTabPressed,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: widget.paddingEnd),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String id,
    int index,
    IconThemeData iconTheme,
    TextStyle textStyle, {
    required bool isActive,
  }) {
    final tab = widget.controller.getTabAt(index);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 4, bottom: 8),
        child: Row(
          children: [
            if (tab.icon != null)
              IconTheme(
                data: iconTheme,
                child: Icon(
                  tab.icon,
                  size: 18,
                ),
              ),
            if (tab.image != null)
              Image(
                image: tab.image!,
                width: 18,
                height: 18,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tab.title,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: textStyle,
              ),
            ),
            const SizedBox(width: 4),
            Builder(
              // ^ To access the icon theme.
              builder: (context) {
                return IconButton(
                  icon: Icons.clear,
                  iconSize: 14,
                  iconColor: IconTheme.of(context).color!,
                  onPressed: () => widget.controller.removeTabAt(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerAfter(BuildContext context, int tabIndex, Color color) {
    if (tabIndex == widget.controller.activeTabIndex! - 1 || tabIndex == widget.controller.activeTabIndex) {
      return const SizedBox(width: 1);
    }
    if (_hoveredTab != null && (tabIndex == _hoveredTab! - 1 || tabIndex == _hoveredTab!)) {
      return const SizedBox(width: 1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: VerticalDivider(
        width: 1,
        thickness: 2,
        indent: 8,
        endIndent: 8,
        color: color,
      ),
    );
  }
}

class NotebookTabBarStyle {
  const NotebookTabBarStyle({
    required this.background,
    required this.tabStyle,
    required this.dividerColor,
    required this.newTabIconTheme,
  });

  /// The color of the bar that appears behind the tabs.
  final Color background;

  /// The styles applied to individual tabs in the tab bar.
  final NotebookTabStyle tabStyle;

  /// The color of the vertical dividers between tabs.
  final Color dividerColor;

  /// The theme applied to tab control icons within the toolbar (but not applied
  /// to content within the tabs).
  final IconThemeData newTabIconTheme;
}

class NotebookTabStyle {
  const NotebookTabStyle({
    required this.background,
    required this.activeTabTextColor,
    required this.activeTabContentIconTheme,
    required this.activeTabCloseIconTheme,
    required this.inactiveTabTextColor,
    required this.inactiveTabContentIconTheme,
    required this.inactiveTabCloseIconTheme,
  });

  /// The color of each tab.
  final Color background;

  /// The color of text in the active tab.
  final Color activeTabTextColor;

  final IconThemeData activeTabContentIconTheme;

  final IconThemeData activeTabCloseIconTheme;

  /// The color of text in inactive tabs.
  final Color inactiveTabTextColor;

  final IconThemeData inactiveTabContentIconTheme;

  final IconThemeData inactiveTabCloseIconTheme;
}

class NotebookTabController {
  NotebookTabController({
    List<TabDescriptor>? initialTabs,
  }) : _tabs = initialTabs ?? [] {
    if (_tabs.isNotEmpty) {
      activateTabAt(0);
    }
  }

  void dispose() {
    _listeners.clear();
  }

  int get tabCount => _tabs.length;

  Iterable<TabDescriptor> get tabs => _tabs;
  final List<TabDescriptor> _tabs;

  int? get activeTabIndex => _activeTab != null ? _tabs.indexOf(_activeTab!) : null;
  void activateTabAt(int index) {
    activateTab(_tabs[index]);
  }

  TabDescriptor? get activeTab => _activeTab;
  TabDescriptor? _activeTab;
  void activateTab(TabDescriptor tab) {
    if (tab == _activeTab) {
      return;
    }

    _activeTab = tab;
    _activeTabHistory.add(tab);

    for (final listener in _listeners) {
      listener.onTabActivated(tab);
    }
  }

  final _activeTabHistory = <TabDescriptor>[];

  void _selectNewActiveTab() {
    if (_tabs.isEmpty) {
      return;
    }

    if (_activeTabHistory.isEmpty) {
      activateTabAt(0);
      return;
    }

    activateTab(_activeTabHistory.removeLast());
  }

  void _removeTabFromHistory(TabDescriptor tab) {
    _activeTabHistory.removeWhere((element) => element == tab);
  }

  TabDescriptor getTabAt(int index) => _tabs[index];

  void updateTabDescriptorAt(int index, TabDescriptor tab) {
    assert(index < _tabs.length,
        "Tried to update tab descriptor at index $index, but there are only ${_tabs.length} tabs. ($tab)");
    if (tab == _tabs[index]) {
      // They're the same. Nothing to update.
      return;
    }

    updateTabDescriptor(_tabs[index].id, tab);
  }

  void updateTabDescriptor(String id, TabDescriptor tab) {
    assert(_tabs.where((existingTab) => existingTab.id == id).isNotEmpty,
        "Tried to update tab descriptor for ID ($id), but there's no existing tab with that ID.");

    final index = _tabs.indexWhere((existingTab) => existingTab.id == id);
    final oldTab = _tabs[index];
    _tabs[index] = tab;

    if (_activeTab?.id == tab.id) {
      _activeTab = tab;
    }

    for (final listener in _listeners) {
      listener.onTabUpdated(index, newTab: tab, oldTab: oldTab);
    }
  }

  void addTabAt(int index, TabDescriptor tab) {
    if (_tabs.where((existingTab) => existingTab.id == tab.id).isNotEmpty) {
      throw Exception("Can't add tab because there's already a tab with the same ID. Tried to add $tab");
    }

    _tabs.insert(index, tab);

    for (final listener in _listeners) {
      listener.onTabAdded(index, tab);
    }

    // This is our first tab. Activate it by default.
    if (_activeTab == null) {
      activateTabAt(0);
    }
  }

  void addTab(TabDescriptor tab) {
    if (_tabs.where((existingTab) => existingTab.id == tab.id).isNotEmpty) {
      throw Exception("Can't add tab because there's already a tab with the same ID. Tried to add $tab");
    }

    addTabAt(_tabs.length, tab);
  }

  void removeTabAt(int index) {
    assert(index < _tabs.length, "Tried to remove tab at index $index, but there are only ${_tabs.length} tabs.");
    removeTab(_tabs[index]);
  }

  void removeTab(TabDescriptor tab) {
    final index = _tabs.indexOf(tab);
    assert(index >= 0, "Tried to remove tab ($tab) but there's no such tab in this controller.");

    _tabs.remove(tab);
    _removeTabFromHistory(tab);

    if (_tabs.isEmpty || _activeTab == tab) {
      _activeTab = null;
      _selectNewActiveTab();
    }

    for (final listener in _listeners) {
      listener.onTabRemoved(index, tab);
    }
  }

  final _listeners = <NotebookTabBarControllerListener>{};

  void addListener(NotebookTabBarControllerListener listener) => _listeners.add(listener);

  void removeListener(NotebookTabBarControllerListener listener) => _listeners.remove(listener);
}

class NotebookTabBarControllerListener {
  NotebookTabBarControllerListener({
    OnTabAdded? onTabAdded,
    OnTabActivated? onTabActivated,
    OnTabUpdated? onTabUpdated,
    OnTabRemoved? onTabRemoved,
  })  : _onTabAdded = onTabAdded,
        _onTabActivated = onTabActivated,
        _onTabUpdated = onTabUpdated,
        _onTabRemoved = onTabRemoved;

  final OnTabAdded? _onTabAdded;
  final OnTabActivated? _onTabActivated;
  final OnTabUpdated? _onTabUpdated;
  final OnTabRemoved? _onTabRemoved;

  void onTabAdded(int index, TabDescriptor tab) => _onTabAdded?.call(index, tab);

  void onTabActivated(TabDescriptor tab) => _onTabActivated?.call(tab);

  void onTabUpdated(int index, {required TabDescriptor newTab, required TabDescriptor oldTab}) =>
      _onTabUpdated?.call(index, newTab: newTab, oldTab: oldTab);

  void onTabRemoved(int index, TabDescriptor tab) => _onTabRemoved?.call(index, tab);
}

typedef OnTabAdded = void Function(int index, TabDescriptor tab);
typedef OnTabActivated = void Function(TabDescriptor tab);
typedef OnTabUpdated = void Function(int index, {required TabDescriptor newTab, required TabDescriptor oldTab});
typedef OnTabRemoved = void Function(int index, TabDescriptor tab);

class TabDescriptor {
  const TabDescriptor({
    required this.id,
    this.icon,
    this.image,
    required this.title,
  }) : assert(icon == null || image == null, "You can provide an icon, or an image, but not both");

  final String id;

  final IconData? icon;
  final ImageProvider? image;

  final String title;
}

typedef TabBuilder = Widget Function(BuildContext, String id, int index);

class NotebookTab extends StatefulWidget {
  const NotebookTab({
    super.key,
    required this.maxWidth,
    required this.background,
    this.isActive = false,
    this.onTabPressed,
    this.onClosePressed,
    this.onHover,
    this.onExit,
    required this.child,
  });

  final double maxWidth;
  final Color background;
  final bool isActive;

  final VoidCallback? onTabPressed;
  final VoidCallback? onClosePressed;
  final VoidCallback? onHover;
  final VoidCallback? onExit;

  final Widget child;

  @override
  State<NotebookTab> createState() => _NotebookTabState();
}

class _NotebookTabState extends State<NotebookTab> {
  bool _isHovered = false;

  void _onHover(PointerHoverEvent _) {
    setState(() {
      _isHovered = true;
      widget.onHover?.call();
    });
  }

  void _onExit(PointerExitEvent _) {
    setState(() {
      _isHovered = false;
      widget.onExit?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: _onHover,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTabPressed,
        child: SizedBox(
          height: double.infinity,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildTabBackground(),
                ),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBackground() {
    if (!widget.isActive && !_isHovered) {
      return const SizedBox();
    }

    return CustomPaint(
      painter: _TabShapePainter(
        color: widget.isActive ? widget.background : widget.background.withValues(alpha: 0.1),
      ),
    );
  }
}

class _TabShapePainter extends CustomPainter {
  _TabShapePainter({
    required this.color,
    this.cornerRadius = 8.0,
  });

  final Color color;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      // Draw the primary rectangle, with curved top corners.
      ..addRRect(RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: Radius.circular(cornerRadius),
        topRight: Radius.circular(cornerRadius),
      ))
      // Draw bottom left curve.
      ..moveTo(0, size.height)
      ..lineTo(-cornerRadius, size.height)
      ..arcToPoint(Offset(0, size.height - cornerRadius), radius: Radius.circular(cornerRadius), clockwise: false)
      // Draw bottom right curve.
      ..moveTo(size.width, size.height)
      ..lineTo(size.width + cornerRadius, size.height)
      ..arcToPoint(Offset(size.width, size.height - cornerRadius), radius: Radius.circular(cornerRadius))
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _TabBarLayout extends MultiChildRenderObjectWidget {
  const _TabBarLayout({
    super.key,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTabBarLayout();
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTabBarLayout renderObject) {
    super.updateRenderObject(context, renderObject);
  }
}

class _RenderTabBarLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is _RenderTabLayoutParentData) {
      return;
    }

    child.parentData = _RenderTabLayoutParentData();
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final children = getChildrenAsList();

    if (maxWidth.isFinite) {
      double desiredWidth = 0;
      for (final child in children) {
        final drySize =
            child.computeDryLayout(BoxConstraints(maxHeight: constraints.maxHeight, maxWidth: double.infinity));
        desiredWidth += drySize.width;
      }

      if (desiredWidth > maxWidth) {
        _layoutWithShrunkenTabs(children);
        return;
      }
    }

    _layoutWithIntrinsicSizes(children);
  }

  void _layoutWithShrunkenTabs(List<RenderBox> children) {
    // Layout the non-tab children at their desired sizes.
    double availableWidth = constraints.maxWidth;
    int tabCount = 0;
    for (final child in children) {
      if ((child.parentData as _RenderTabLayoutParentData).isTab) {
        // This is a tab. We need to wait to layout this child until we
        // know how much width we have for tabs.
        tabCount += 1;
        continue;
      }

      // This is a non-tab child. It should be sized, as desired.
      final intrinsicWidth = child.computeMinIntrinsicWidth(constraints.maxHeight);
      child.layout(
        BoxConstraints.tight(Size(intrinsicWidth, constraints.maxHeight)),
        parentUsesSize: true,
      );
      availableWidth -= child.size.width;
    }

    // Spread the tabs out across the available width.
    final tabWidth = availableWidth / tabCount;
    double x = 0;
    for (final child in children) {
      if ((child.parentData as _RenderTabLayoutParentData).isTab) {
        child.layout(
          BoxConstraints.tight(
            Size(tabWidth, constraints.maxHeight),
          ),
          parentUsesSize: true,
        );
      } else {
        // We already laid out this child.
      }

      (child.parentData as _RenderTabLayoutParentData).offset = Offset(x, 0);
      x += child.size.width;
    }

    // We always take up all available space.
    size = constraints.biggest;
  }

  void _layoutWithIntrinsicSizes(List<RenderBox> children) {
    double x = 0;
    for (final child in children) {
      child.layout(
        BoxConstraints(
          maxWidth: constraints.maxWidth - x,
          minHeight: constraints.maxHeight,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      (child.parentData as _RenderTabLayoutParentData).offset = Offset(x, 0);

      x += child.size.width;
    }

    // We always take up all available space.
    size = constraints.biggest;
  }

  @override
  bool hitTest(HitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result as BoxHitTestResult, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class Tab extends ParentDataWidget<_RenderTabLayoutParentData> {
  const Tab({
    super.key,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    (renderObject.parentData as _RenderTabLayoutParentData).isTab = true;
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _TabBarLayout;
}

class _RenderTabLayoutParentData extends ContainerBoxParentData<RenderBox> {
  bool isTab = false;
}
