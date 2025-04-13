import 'package:flutter/widgets.dart';
import 'package:lucid/lucid.dart';

class DropdownList<ItemType> extends StatefulWidget {
  const DropdownList({
    super.key,
    required this.items,
    this.selectedItem,
    this.hint,
    this.popoverLeaderAnchor = Alignment.bottomLeft,
    this.popoverFollowerAnchor = Alignment.topLeft,
    required this.buttonBuilder,
    required this.listItemBuilder,
    this.closeOnItemSelection = false,
    required this.onItemSelectionRequested,
    this.divider,
  });

  final List<ItemType> items;

  final ItemType? selectedItem;
  final Widget? hint;

  final Alignment popoverLeaderAnchor;
  final Alignment popoverFollowerAnchor;

  final DropdownButtonItemBuilder<ItemType> buttonBuilder;

  final DropdownListItemBuilder<ItemType> listItemBuilder;
  final bool closeOnItemSelection;
  final DropdownItemSelector<ItemType> onItemSelectionRequested;

  final Widget? divider;

  @override
  State<DropdownList<ItemType>> createState() => _DropdownListState<ItemType>();
}

class _DropdownListState<ItemType> extends State<DropdownList<ItemType>> {
  final _controller = DropdownController();

  @override
  Widget build(BuildContext context) {
    return Dropdown(
      controller: _controller,
      popoverLeaderAnchor: widget.popoverLeaderAnchor,
      popoverFollowerAnchor: widget.popoverFollowerAnchor,
      popoverBuilder: (popoverContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300, maxHeight: 200),
          child: Sheet(
            padding: EdgeInsets.zero,
            child: ListView.builder(
              itemCount: widget.items.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.listItemBuilder(
                      context,
                      widget.items[index],
                      widget.selectedItem,
                      (item) {
                        widget.onItemSelectionRequested(item);

                        if (widget.closeOnItemSelection) {
                          _controller.hide();
                        }
                      },
                    ),
                    if (index < widget.items.length - 1) //
                      widget.divider ?? const SizedBox(),
                  ],
                );
              },
            ),
          ),
        );
      },
      child: widget.selectedItem != null || widget.hint == null //
          ? widget.buttonBuilder(context, widget.selectedItem)
          : widget.hint!,
    );
  }
}

/// A widget builder that builds the content that appears within a dropdown button.
///
/// A dropdown button is a button that, when clicked, opens a popover with items to
/// choose from.
typedef DropdownButtonItemBuilder<ItemType> = Widget Function(BuildContext context, ItemType? item);

/// A widget builder that builds a single item within a dropdown list popover.
typedef DropdownListItemBuilder<ItemType> = Widget Function(
  BuildContext context,
  ItemType item,
  ItemType? selectedItem,
  DropdownItemSelector<ItemType> selectItem,
);

/// A callback that instructs a dropdown list to select the given [selectedItem].
///
/// Clients can pass a `null` [selectedItem] to deselect any currently selected
/// item.
typedef DropdownItemSelector<ItemType> = void Function(ItemType? selectedItem);
