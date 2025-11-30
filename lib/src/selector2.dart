import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';

class Selector2 extends StatefulWidget {
  final double? width, height, scale, dropdownHeight;
  final TextStyle? itemTextStyle, hintTextStyle, headerTextStyle;
  final Map<String, TextStyle>? itemSpecificStyles;
  final List<String> items, customItemsNamesDisplayed;
  final String? hintText, selectedItem, headerSelectedItemText;
  final void Function(String?)? onChanged;
  final Color? closedFillColor;
  final AlignmentGeometry? alignment;
  final EdgeInsets? closedHeaderPadding;
  final BorderRadius? closedHeaderBorderRadius;
  final BorderRadius? expandedBorderRadius;
  final Border? closedBorder;
  final Color? expandedFillColor;
  final Color? headerExpandedColor;
  final bool isFocusable;
  final FocusNode? focusNode;
  final bool requestFocusOnInit;
  final int? autoScrollMaxFrameDelay;
  final int? autoScrollEndOfFrameDelay;
  const Selector2({
    super.key,
    required this.items,
    this.customItemsNamesDisplayed = const [],
    this.itemTextStyle,
    this.hintTextStyle,
    this.headerTextStyle,
    this.hintText,
    this.selectedItem,
    this.headerSelectedItemText,
    this.onChanged,
    this.width,
    this.height,
    this.scale,
    this.dropdownHeight,
    this.closedFillColor,
    this.alignment,
    this.closedHeaderPadding,
    this.closedHeaderBorderRadius,
    this.expandedBorderRadius,
    this.closedBorder,
    this.expandedFillColor,
    this.headerExpandedColor,
    this.itemSpecificStyles,
    this.isFocusable = true,
    this.focusNode,
    this.requestFocusOnInit = false,
    this.autoScrollMaxFrameDelay,
    this.autoScrollEndOfFrameDelay,
  });

  @override
  State<Selector2> createState() => _Selector2State();
}

class _Selector2State extends State<Selector2> {
  String? _selection;
  ScrollController _scrollController = ScrollController();
  bool _scrollControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _selection = widget.selectedItem;
    _initScrollController();
  }

  void _initScrollController() {
    if (_scrollControllerInitialized) {
      _scrollController.dispose();
    }
    _scrollController =
        ScrollController(initialScrollOffset: _getScrollOffset());
    _scrollControllerInitialized = true;
  }

  double _getScrollOffset() {
    if (_selection != null) {
      final int index = widget.items.indexOf(_selection!);
      if (index >= 0) {
        return 40.0 * index; // approximate item height * index
      }
    }
    return 0.0;
  }

  @override
  void didUpdateWidget(covariant Selector2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      _selection = widget.selectedItem;
      _initScrollController();
    }
  }

  @override
  void dispose() {
    if (_scrollControllerInitialized) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SDropdown(
      width: widget.width ?? 200,
      height: widget.height ?? 60,
      scale: widget.scale ?? 1,
      alignment: widget.alignment ?? Alignment.center,
      items: widget.items,
      customItemsNamesDisplayed: widget.customItemsNamesDisplayed,
      selectedItem: _selection,
      autoScrollMaxFrameDelay: widget.autoScrollMaxFrameDelay,
      autoScrollEndOfFrameDelay: widget.autoScrollEndOfFrameDelay,
      selectedItemText: widget.headerSelectedItemText,
      hintText: widget.hintText ?? 'NONE',
      onChanged: (newSelection) {
        if (newSelection != null && newSelection != _selection) {
          if (!mounted) return;
          setState(() {
            _selection = newSelection;
          });
          widget.onChanged?.call(newSelection);
          _initScrollController();
        }
      },
      overlayHeight: widget.dropdownHeight ?? 230,
      closedHeaderPadding: widget.closedHeaderPadding,
      itemsScrollController: _scrollController,
      closedFillColor: widget.closedFillColor,
      expandedFillColor: widget.expandedFillColor,
      headerExpandedColor: widget.headerExpandedColor,
      headerTextStyle: widget.headerTextStyle ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      hintTextStyle: widget.hintTextStyle ??
          TextStyle(color: Colors.black.withValues(alpha: 0.5)),
      itemTextStyle: widget.itemTextStyle ?? const TextStyle(fontSize: 14),
      itemSpecificStyles: widget.itemSpecificStyles,
      excludeSelected: false,
      closedBorderRadius:
          widget.closedHeaderBorderRadius ?? BorderRadius.circular(10),
      expandedBorderRadius:
          widget.expandedBorderRadius ?? BorderRadius.circular(10),
      closedBorder: widget.closedBorder,
      useKeyboardNavigation: widget.isFocusable,
      focusNode: widget.focusNode,
      requestFocusOnInit: widget.requestFocusOnInit,
    );
  }
}
