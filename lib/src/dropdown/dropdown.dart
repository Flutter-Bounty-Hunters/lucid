import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:lucid/src/infrastructure/sheets.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
    this.controller,
    this.popoverLeaderAnchor = Alignment.bottomCenter,
    this.popoverFollowerAnchor = Alignment.topCenter,
    required this.popoverBuilder,
    required this.child,
  });

  final DropdownController? controller;

  final Alignment popoverLeaderAnchor;
  final Alignment popoverFollowerAnchor;

  final WidgetBuilder popoverBuilder;

  final Widget child;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  final _tapGroupId = "dropdown_${Random().nextInt(1000)}";

  final _link = LeaderLink();
  final _overlayPortalController = OverlayPortalController();

  late DropdownController _dropdownController;

  @override
  void initState() {
    super.initState();

    _dropdownController = widget.controller ?? DropdownController();
    _dropdownController.addListener(_onControllerChange);

    if (_dropdownController.wantsToShow) {
      // The dropdown controller that was provided to us wants to show the dropdown.
      // However, OverlayPortalController throws an error when being told to show()
      // immediately, so do it at the end of the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onControllerChange();
      });
    }
  }

  @override
  void didUpdateWidget(Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _dropdownController.removeListener(_onControllerChange);
      _dropdownController = widget.controller ?? DropdownController();
      _dropdownController.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    _dropdownController.removeListener(_onControllerChange);
    if (widget.controller == null) {
      _dropdownController.dispose();
    }

    _overlayPortalController.hide();
    super.dispose();
  }

  void _onControllerChange() {
    if (_dropdownController.wantsToShow) {
      _overlayPortalController.show();
    } else {
      _overlayPortalController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: (overlayContext) {
        return TapRegion(
          groupId: _tapGroupId,
          onTapOutside: (_) => _dropdownController.hide(),
          child: Follower.withOffset(
            link: _link,
            leaderAnchor: widget.popoverLeaderAnchor,
            followerAnchor: widget.popoverFollowerAnchor,
            offset: Offset(0, 8),
            child: widget.popoverBuilder(context),
          ),
        );
      },
      child: TapRegion(
        groupId: _tapGroupId,
        child: Leader(
          link: _link,
          child: ButtonSheet(
            padding: EdgeInsets.zero,
            onActivated: () => setState(() {
              _dropdownController.toggle();
            }),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class DropdownController with ChangeNotifier {
  bool get wantsToShow => _wantsToShow;
  bool _wantsToShow = false;

  void show() {
    if (_wantsToShow) {
      return;
    }

    _wantsToShow = true;
    notifyListeners();
  }

  void hide() {
    if (!_wantsToShow) {
      return;
    }

    _wantsToShow = false;
    notifyListeners();
  }

  void toggle() {
    if (_wantsToShow) {
      hide();
    } else {
      show();
    }
  }
}
