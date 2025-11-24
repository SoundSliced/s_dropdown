import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:sizer/sizer.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

import 's_dropdown_decoration.dart';

class SDropdownController {
  _SDropdownState? _state;

  void _attach(_SDropdownState state) {
    _state = state;
  }

  void _detach(_SDropdownState state) {
    if (_state == state) {
      _state = null;
    }
  }

  bool get isExpanded => _state?._isExpanded ?? false;

  void open() {
    _state?._openFromController();
  }

  void close() {
    _state?._closeFromController();
  }

  void toggle() {
    _state?._toggleDropdown();
  }

  void highlightNext() {
    _state?._moveHighlight(1);
  }

  void highlightPrevious() {
    _state?._moveHighlight(-1);
  }

  /// Highlight the item at the given original index (index in the `items` list)
  void highlightAtIndex(int index) {
    _state?._setHighlightAtIndex(index);
  }

  /// Highlight the item with the given value
  void highlightItem(String value) {
    _state?._setHighlightForValue(value);
  }

  /// Select (and highlight) the item at the given original index (index in the `items` list)
  void selectIndex(int index) {
    _state?._selectByIndex(index);
  }

  /// Select (and highlight) the item with the given value
  void selectItem(String value) {
    _state?._selectByValue(value);
  }

  void selectHighlighted() {
    _state?._selectHighlightedItem();
  }

  void closeWithoutSelection() {
    _state?._closeWithoutSelection();
  }

  void ensureHighlightInitialized() {
    _state?._ensureHighlightInitialized();
  }
}

/// A fully custom dropdown widget built from scratch for String items with complete control over dimensions and behavior.
/// This widget provides a native Flutter dropdown implementation with:
/// - Full control over widget width and height
/// - Simplified API focused on String items only
/// - Custom overlay system using CompositedTransformTarget/Follower
/// - Minimal external dependencies: uses a small set of helper packages for responsive sizing, indexed lists, and animation helpers
/// - Comprehensive styling through SDropdownDecoration
/// - Support for item-specific text styles
/// - Scroll controller support for precise positioning
/// - Native Flutter performance and behavior
/// - Smooth roll-up/down animations with fade effects
class SDropdown extends StatefulWidget {
  /// The width of the dropdown widget
  final double? width;

  /// The height of the dropdown widget
  final double? height;

  /// The height of the dropdown overlay when expanded
  final double? overlayHeight;

  /// The width of the dropdown overlay when expanded
  final double? overlayWidth;

  /// Scale factor for the entire widget
  final double? scale;

  /// The list of string items to display
  final List<String> items, customItemsNamesDisplayed;

  /// The currently selected item
  final String? selectedItem, selectedItemText;

  /// Initial selected item (if no controller is used)
  final String? initialItem;

  /// Hint text to display when no item is selected
  final String? hintText;

  /// Callback when selection changes
  final Function(String?)? onChanged;

  /// Text style for dropdown items
  final TextStyle? itemTextStyle;

  /// Text style for the header (selected item)
  final TextStyle? headerTextStyle;

  /// Text style for the hint text
  final TextStyle? hintTextStyle;

  /// Map of item-specific text styles
  final Map<String, TextStyle>? itemSpecificStyles;

  /// Background color of the closed dropdown
  final Color? closedFillColor;

  /// Background color of the expanded dropdown overlay
  final Color? expandedFillColor;

  /// Color for the header when expanded
  final Color? headerExpandedColor;

  /// Border for the closed dropdown
  final Border? closedBorder;

  /// Border for the expanded dropdown overlay
  final Border? expandedBorder;

  /// Border radius for the closed dropdown
  final BorderRadius? closedBorderRadius;

  /// Border radius for the expanded dropdown overlay
  final BorderRadius? expandedBorderRadius;

  /// Padding for the closed header
  final EdgeInsets? closedHeaderPadding;

  /// Padding for the expanded header
  final EdgeInsets? expandedHeaderPadding;

  /// Padding for the items list
  final EdgeInsets? itemsListPadding;

  /// Padding for each list item
  final EdgeInsets? listItemPadding;

  /// Scroll controller for the items list (wrapped internally by an IndexedScrollController)
  final ScrollController? itemsScrollController;

  /// Whether to exclude the selected item from the dropdown list
  final bool excludeSelected;

  /// Whether the dropdown can be closed by tapping outside
  final bool canCloseOutsideBounds;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Alignment of the widget within its parent
  final AlignmentGeometry? alignment;

  /// Maximum lines for text display
  final int maxLines;

  /// Suffix icon for the closed dropdown
  final Widget? suffixIcon;

  /// Prefix icon for the closed dropdown
  final Widget? prefixIcon;

  /// Validator function
  final String? Function(String?)? validator;

  /// Whether to validate on change
  final bool validateOnChange;

  /// Custom decoration for the dropdown
  final SDropdownDecoration? decoration;

  /// Controller used to manage the dropdown programmatically
  final SDropdownController? controller;

  final int? autoScrollMaxFrameDelay;
  final int? autoScrollEndOfFrameDelay;

  const SDropdown({
    super.key,
    required this.items,
    this.customItemsNamesDisplayed = const [],
    this.width,
    this.height,
    this.overlayHeight,
    this.overlayWidth,
    this.scale,
    this.selectedItem,
    this.initialItem,
    this.hintText,
    this.onChanged,
    this.itemTextStyle,
    this.headerTextStyle,
    this.hintTextStyle,
    this.itemSpecificStyles,
    this.closedFillColor,
    this.expandedFillColor,
    this.closedBorder,
    this.expandedBorder,
    this.closedBorderRadius,
    this.expandedBorderRadius,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.itemsScrollController,
    this.excludeSelected = true,
    this.canCloseOutsideBounds = true,
    this.enabled = true,
    this.alignment,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.validateOnChange = true,
    this.decoration,
    this.headerExpandedColor,
    this.selectedItemText,
    this.controller,
    this.autoScrollMaxFrameDelay,
    this.autoScrollEndOfFrameDelay,
  }) : assert(
          initialItem == null,
          'Use selectedItem instead of initialItem',
        );

  @override
  State<SDropdown> createState() => _SDropdownState();
}

class _SDropdownState extends State<SDropdown> {
  String? _currentSelection;
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  IndexedScrollController? _itemsScrollController;
  int? _scrollTargetIndex;

  List<_DropdownOption> _visibleOptions = const [];
  int? _highlightedIndex;
  bool _keyboardNavigationActive = false;

  static const double _itemExtent = 35.0;

  // Animation trigger - toggle to start expand/collapse animation
  bool _animationTrigger = false;

  bool get _canMutateStateNow {
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    return phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;
  }

  void _setStateSafely(VoidCallback mutation, {bool rebuildOverlay = false}) {
    if (!mounted) {
      return;
    }

    setState(mutation);

    void run() {
      if (!mounted) {
        return;
      }
      setState(mutation);
      if (rebuildOverlay) {
        _scheduleOverlayRebuild();
      }
    }

    if (_canMutateStateNow) {
      run();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
    }
  }

  void _scheduleOverlayRebuild() {
    if (_overlayEntry == null) {
      return;
    }

    void mark() {
      if (_overlayEntry == null) {
        return;
      }
      _overlayEntry!.markNeedsBuild();
    }

    if (_canMutateStateNow) {
      mark();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => mark());
    }
  }

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialItem ?? widget.selectedItem;

    if (widget.itemsScrollController != null) {
      _itemsScrollController = IndexedScrollController(
        scrollController: widget.itemsScrollController,
        alignment: 0.2,
      );
    }

    widget.controller?._attach(this);

    _visibleOptions = _computeVisibleOptions();
  }

  @override
  void didUpdateWidget(SDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool selectionChanged = widget.selectedItem != oldWidget.selectedItem;
    if (selectionChanged) {
      _currentSelection = widget.selectedItem;
    }

    if (widget.itemsScrollController != oldWidget.itemsScrollController) {
      if (widget.itemsScrollController != null) {
        _itemsScrollController = IndexedScrollController(
          scrollController: widget.itemsScrollController,
          alignment: 0.2,
        );
      } else {
        _itemsScrollController = null;
      }
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

    if (!widget.enabled && _isExpanded) {
      _closeWithoutSelection();
    }

    final bool itemsChanged = !_stringListEquals(widget.items, oldWidget.items);
    final bool namesChanged = !_stringListEquals(
        widget.customItemsNamesDisplayed, oldWidget.customItemsNamesDisplayed);
    final bool excludeChanged =
        widget.excludeSelected != oldWidget.excludeSelected;

    if (selectionChanged || itemsChanged || namesChanged || excludeChanged) {
      final bool keepHighlight = _isExpanded && !selectionChanged;
      _refreshVisibleOptions(keepHighlight: keepHighlight);

      if (_isExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _ensureHighlightInitialized();
          }
        });
      }
    } else if (_isExpanded) {
      _scheduleOverlayRebuild();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);

    _overlayEntry?.remove();
    _overlayEntry = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Transform.scale(
        scale: widget.scale ?? 1.0,
        alignment: widget.alignment ?? Alignment.center,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: _buildDropdownButton(),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (!widget.enabled) {
      return;
    }

    if (_isExpanded) {
      _closeWithoutSelection();
    } else {
      _showOverlay();
    }
  }

  void _openFromController() {
    if (!widget.enabled || _isExpanded) {
      return;
    }
    _showOverlay();
  }

  void _closeFromController() {
    if (!_isExpanded) {
      return;
    }
    _closeWithoutSelection();
  }

  void _closeWithoutSelection() {
    _removeOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) {
      return;
    }

    _refreshVisibleOptions(keepHighlight: false);

    final OverlayState? overlayState = Overlay.maybeOf(context);
    if (overlayState == null) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(size),
    );

    overlayState.insert(_overlayEntry!);

    _setStateSafely(() {
      _isExpanded = true;
      _keyboardNavigationActive = true;
      _animationTrigger = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensureHighlightInitialized();
      }
    });
  }

  Future<void> _removeOverlay() async {
    if (_overlayEntry == null) {
      return;
    }

    // Trigger reverse animation
    if (mounted) {
      _setStateSafely(() {
        _animationTrigger = false;
      });
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      _setStateSafely(() {
        _isExpanded = false;
        _keyboardNavigationActive = false;
        _highlightedIndex = null;
        _scrollTargetIndex = null;
      });
    } else {
      _isExpanded = false;
      _keyboardNavigationActive = false;
      _highlightedIndex = null;
      _scrollTargetIndex = null;
    }
  }

  void _selectItem(String value) {
    final bool valueChanged = _currentSelection != value;

    if (valueChanged) {
      _setStateSafely(() {
        _currentSelection = value;
      });
    }

    if (widget.validateOnChange) {
      widget.validator?.call(value);
    }

    widget.onChanged?.call(value);

    _closeWithoutSelection();
  }

  void _refreshVisibleOptions({required bool keepHighlight}) {
    final List<_DropdownOption> next = _computeVisibleOptions();
    final bool highlightOutOfRange =
        _highlightedIndex != null && _highlightedIndex! >= next.length;
    final bool shouldResetHighlight = !keepHighlight || highlightOutOfRange;

    if (_isExpanded) {
      final bool optionsChanged = _optionsDiffer(next) || shouldResetHighlight;

      if (optionsChanged) {
        _setStateSafely(() {
          _visibleOptions = next;
          if (shouldResetHighlight) {
            _highlightedIndex = null;
            _scrollTargetIndex = null;
          }
        }, rebuildOverlay: true);
      } else {
        _visibleOptions = next;
        _scheduleOverlayRebuild();
      }
    } else {
      _visibleOptions = next;
      if (shouldResetHighlight) {
        _highlightedIndex = null;
        _keyboardNavigationActive = false;
        _scrollTargetIndex = null;
      }
    }
  }

  List<_DropdownOption> _computeVisibleOptions() {
    final List<_DropdownOption> result = [];
    final List<String> items = widget.items;
    final List<String> customNames = widget.customItemsNamesDisplayed;

    for (int i = 0; i < items.length; i++) {
      final String value = items[i];

      if (widget.excludeSelected && value == _currentSelection) {
        continue;
      }

      final String displayText =
          customNames.length > i && customNames[i].isNotEmpty
              ? customNames[i]
              : value;

      result.add(
        _DropdownOption(
          value: value,
          displayText: displayText,
          originalIndex: i,
        ),
      );
    }

    return result;
  }

  bool _optionsDiffer(List<_DropdownOption> next) {
    if (next.length != _visibleOptions.length) {
      return true;
    }

    for (int i = 0; i < next.length; i++) {
      final _DropdownOption previous = _visibleOptions[i];
      final _DropdownOption current = next[i];
      if (previous.value != current.value ||
          previous.displayText != current.displayText ||
          previous.originalIndex != current.originalIndex) {
        return true;
      }
    }

    return false;
  }

  bool _stringListEquals(List<String> a, List<String> b) {
    if (identical(a, b)) {
      return true;
    }

    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }

  void _ensureHighlightInitialized() {
    if (!_isExpanded || _visibleOptions.isEmpty) {
      return;
    }

    int? nextHighlight = _highlightedIndex;

    if (nextHighlight == null || nextHighlight >= _visibleOptions.length) {
      if (_currentSelection != null) {
        final int selectedIndex = _visibleOptions
            .indexWhere((option) => option.value == _currentSelection);
        if (selectedIndex != -1) {
          nextHighlight = selectedIndex;
        }
      }

      nextHighlight ??= 0;
    }

    if (_highlightedIndex != nextHighlight || !_keyboardNavigationActive) {
      _setStateSafely(() {
        _highlightedIndex = nextHighlight;
        _keyboardNavigationActive = true;
        _scrollTargetIndex = nextHighlight;
      }, rebuildOverlay: true);
    }

    _ensureHighlightedVisible();
  }

  void _moveHighlight(int step) {
    if (!_isExpanded) {
      _openFromController();
      return;
    }

    if (_visibleOptions.isEmpty) {
      return;
    }

    final int currentIndex = _highlightedIndex ?? 0;
    int nextIndex = (currentIndex + step) % _visibleOptions.length;
    if (nextIndex < 0) {
      nextIndex += _visibleOptions.length;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = nextIndex;
      _scrollTargetIndex = nextIndex;
    }, rebuildOverlay: true);
  }

  void _selectHighlightedItem() {
    if (!_isExpanded || _visibleOptions.isEmpty) {
      return;
    }

    final int index = _highlightedIndex ?? 0;
    if (index < 0 || index >= _visibleOptions.length) {
      return;
    }

    _selectItem(_visibleOptions[index].value);
  }

  void _setHighlightAtIndex(int originalIndex) {
    // Map original index (index in widget.items) to visible overlay index
    final int visibleIndex =
        _visibleOptions.indexWhere((o) => o.originalIndex == originalIndex);
    if (visibleIndex == -1) {
      // Item not visible (could be excluded). If overlay is closed, open it to recompute.
      if (!_isExpanded) {
        _openFromController();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final int idx = _visibleOptions
              .indexWhere((o) => o.originalIndex == originalIndex);
          if (idx != -1) {
            _setStateSafely(() {
              _keyboardNavigationActive = true;
              _highlightedIndex = idx;
              _scrollTargetIndex = idx;
            }, rebuildOverlay: true);
          }
        });
      }
      return;
    }

    if (!_isExpanded) {
      _openFromController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setStateSafely(() {
          _keyboardNavigationActive = true;
          _highlightedIndex = visibleIndex;
          _scrollTargetIndex = visibleIndex;
        }, rebuildOverlay: true);
      });
      return;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = visibleIndex;
      _scrollTargetIndex = visibleIndex;
    }, rebuildOverlay: true);
  }

  void _setHighlightForValue(String value) {
    final int visibleIndex =
        _visibleOptions.indexWhere((o) => o.value == value);
    if (visibleIndex == -1) {
      if (!_isExpanded) {
        _openFromController();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final int idx = _visibleOptions.indexWhere((o) => o.value == value);
          if (idx != -1) {
            _setStateSafely(() {
              _keyboardNavigationActive = true;
              _highlightedIndex = idx;
              _scrollTargetIndex = idx;
            }, rebuildOverlay: true);
          }
        });
      }
      return;
    }

    if (!_isExpanded) {
      _openFromController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setStateSafely(() {
          _keyboardNavigationActive = true;
          _highlightedIndex = visibleIndex;
          _scrollTargetIndex = visibleIndex;
        }, rebuildOverlay: true);
      });
      return;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = visibleIndex;
      _scrollTargetIndex = visibleIndex;
    }, rebuildOverlay: true);
  }

  void _selectByIndex(int originalIndex) {
    if (originalIndex < 0 || originalIndex >= widget.items.length) {
      return;
    }
    final String value = widget.items[originalIndex];
    _selectItem(value);
  }

  void _selectByValue(String value) {
    if (!widget.items.contains(value)) {
      return;
    }
    _selectItem(value);
  }

  void _setPointerHighlight(int index) {
    if (!_isExpanded || index < 0 || index >= _visibleOptions.length) {
      return;
    }

    if (_highlightedIndex == index && _keyboardNavigationActive) {
      return;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = index;
      // Don't update _scrollTargetIndex on hover - only keyboard navigation should trigger autoscroll
    }, rebuildOverlay: true);
  }

  void _ensureHighlightedVisible() {
    if (!_isExpanded || _highlightedIndex == null) {
      return;
    }

    final int target = _highlightedIndex!;
    if (_scrollTargetIndex == target) {
      return;
    }

    _setStateSafely(() {
      _scrollTargetIndex = target;
    }, rebuildOverlay: true);
  }

  Widget _buildDropdownButton() {
    final SDropdownDecoration effectiveDecoration =
        SDropdownDecoration.defaultDecoration.merge(
      widget.decoration,
    );

    final SDropdownDecoration finalDecoration = effectiveDecoration.copyWith(
      closedFillColor:
          widget.closedFillColor ?? effectiveDecoration.closedFillColor,
      expandedFillColor:
          widget.expandedFillColor ?? effectiveDecoration.expandedFillColor,
      closedBorder: widget.closedBorder ?? effectiveDecoration.closedBorder,
      expandedBorder:
          widget.expandedBorder ?? effectiveDecoration.expandedBorder,
      closedBorderRadius:
          widget.closedBorderRadius ?? effectiveDecoration.closedBorderRadius,
      expandedBorderRadius: widget.expandedBorderRadius ??
          effectiveDecoration.expandedBorderRadius,
      headerStyle: widget.headerTextStyle ?? effectiveDecoration.headerStyle,
      hintStyle: widget.hintTextStyle ?? effectiveDecoration.hintStyle,
      listItemStyle: widget.itemTextStyle ?? effectiveDecoration.listItemStyle,
      closedSuffixIcon:
          widget.suffixIcon ?? effectiveDecoration.closedSuffixIcon,
      prefixIcon: widget.prefixIcon ?? effectiveDecoration.prefixIcon,
      closedHeaderPadding:
          widget.closedHeaderPadding ?? effectiveDecoration.closedHeaderPadding,
      expandedHeaderPadding: widget.expandedHeaderPadding ??
          effectiveDecoration.expandedHeaderPadding,
      itemsListPadding:
          widget.itemsListPadding ?? effectiveDecoration.itemsListPadding,
      listItemPadding:
          widget.listItemPadding ?? effectiveDecoration.listItemPadding,
      overlayHeight: widget.overlayHeight ?? effectiveDecoration.overlayHeight,
      maxLines: widget.maxLines,
    );

    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        padding: finalDecoration.closedHeaderPadding,
        decoration: BoxDecoration(
          color: _isExpanded
              ? finalDecoration.headerExpandedColor
              : finalDecoration.closedFillColor,
          border: _isExpanded
              ? finalDecoration.expandedBorder
              : finalDecoration.closedBorder,
          borderRadius: _isExpanded
              ? finalDecoration.expandedBorderRadius
              : finalDecoration.closedBorderRadius,
          boxShadow: _isExpanded
              ? finalDecoration.expandedShadow
              : finalDecoration.closedShadow,
        ),
        child: Row(
          children: [
            if (finalDecoration.prefixIcon != null) ...[
              finalDecoration.prefixIcon!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.selectedItemText ??
                    _currentSelection ??
                    widget.hintText ??
                    'Select an option',
                style: _currentSelection != null
                    ? finalDecoration.headerStyle
                    : finalDecoration.hintStyle,
                maxLines: finalDecoration.maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _isExpanded ? 0.5 : 0.0,
              child: _isExpanded
                  ? (finalDecoration.expandedSuffixIcon ??
                      const Icon(Icons.keyboard_arrow_down, size: 20))
                  : (finalDecoration.closedSuffixIcon ??
                      const Icon(Icons.keyboard_arrow_down, size: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(Size buttonSize) {
    final SDropdownDecoration effectiveDecoration =
        SDropdownDecoration.defaultDecoration.merge(
      widget.decoration,
    );

    final SDropdownDecoration finalDecoration = effectiveDecoration.copyWith(
      overlayHeight: widget.overlayHeight ?? effectiveDecoration.overlayHeight,
      overlayWidth: widget.overlayWidth ?? effectiveDecoration.overlayWidth,
      expandedFillColor:
          widget.expandedFillColor ?? effectiveDecoration.expandedFillColor,
      expandedBorder:
          widget.expandedBorder ?? effectiveDecoration.expandedBorder,
      expandedBorderRadius: widget.expandedBorderRadius ??
          effectiveDecoration.expandedBorderRadius,
      itemsListPadding:
          widget.itemsListPadding ?? effectiveDecoration.itemsListPadding,
      listItemPadding:
          widget.listItemPadding ?? effectiveDecoration.listItemPadding,
      listItemStyle: widget.itemTextStyle ?? effectiveDecoration.listItemStyle,
      maxLines: widget.maxLines,
    );

    final double overlayWidth =
        widget.overlayWidth ?? widget.width ?? buttonSize.width;

    const double itemHeight = _itemExtent;
    final double topBottomPadding =
        finalDecoration.itemsListPadding?.vertical ?? 16.0;
    final double calculatedHeight =
        (_visibleOptions.length * itemHeight) + topBottomPadding;

    double overlayHeightValue;
    if (widget.overlayHeight != null) {
      overlayHeightValue = widget.overlayHeight!;
    } else if (finalDecoration.overlayHeight != null) {
      overlayHeightValue = finalDecoration.overlayHeight!;
    } else {
      overlayHeightValue = calculatedHeight;
    }

    if (overlayHeightValue > 170) {
      overlayHeightValue = 170;
    }

    return Sizer(builder: (context, orientation, screenType) {
      return Box(
        width: 100.w,
        height: 100.h,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (widget.canCloseOutsideBounds) {
                    _closeWithoutSelection();
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, buttonSize.height + 4),
              child: STweenAnimationBuilder<double>(
                key: ValueKey(_animationTrigger),
                tween: Tween<double>(
                    begin: 0.0, end: _animationTrigger ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                builder: (context, animValue, child) {
                  return Opacity(
                    opacity: animValue,
                    child: ClipRect(
                      child: SizedBox(
                        width: overlayWidth,
                        height: overlayHeightValue * animValue,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: finalDecoration.expandedFillColor,
                              border: finalDecoration.expandedBorder,
                              borderRadius:
                                  finalDecoration.expandedBorderRadius,
                              boxShadow: finalDecoration.expandedShadow ??
                                  [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                            ),
                            child: IndexScrollListViewBuilder(
                              controller: _itemsScrollController,
                              padding: finalDecoration.itemsListPadding,
                              shrinkWrap: true,
                              itemCount: _visibleOptions.length,
                              indexToScrollTo: _scrollTargetIndex,
                              autoScrollMaxFrameDelay:
                                  widget.autoScrollMaxFrameDelay,
                              autoScrollEndOfFrameDelay:
                                  widget.autoScrollEndOfFrameDelay,
                              physics: const BouncingScrollPhysics(),
                              showScrollbar: true,
                              scrollbarThumbVisibility: true,
                              scrollbarTrackVisibility: true,
                              suppressPlatformScrollbars: true,
                              scrollAlignment: 0.2,
                              itemBuilder: (context, index) {
                                final _DropdownOption option =
                                    _visibleOptions[index];
                                final bool isSelected =
                                    option.value == _currentSelection;
                                final bool isHighlighted =
                                    _keyboardNavigationActive &&
                                        _highlightedIndex == index;

                                final TextStyle itemStyle =
                                    widget.itemSpecificStyles?[option.value] ??
                                        finalDecoration.listItemStyle ??
                                        const TextStyle(fontSize: 14);

                                final ColorScheme colorScheme =
                                    Theme.of(context).colorScheme;
                                final bool isActiveSelection =
                                    isSelected && isHighlighted;
                                final Color highlightColor = colorScheme.primary
                                    .withValues(
                                        alpha: isActiveSelection ? 0.3 : 0.22);
                                final Color selectedColor = colorScheme.primary
                                    .withValues(
                                        alpha: isActiveSelection ? 0.18 : 0.08);
                                final Color resolvedBackground = isSelected
                                    ? highlightColor
                                    : isHighlighted
                                        ? selectedColor
                                        : Colors.transparent;
                                final Color resolvedBorder = isSelected
                                    ? colorScheme.primary.withValues(
                                        alpha: isActiveSelection ? 0.75 : 0.55)
                                    : Colors.transparent;

                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (_) => _setPointerHighlight(index),
                                  onHover: (_) => _setPointerHighlight(index),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _selectItem(option.value),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 120),
                                      curve: Curves.easeOut,
                                      padding: finalDecoration.listItemPadding,
                                      decoration: BoxDecoration(
                                        color: resolvedBackground,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: resolvedBorder,
                                          width: isSelected ? 1 : 0,
                                        ),
                                      ),
                                      child: Text(
                                        option.displayText,
                                        style: itemStyle.copyWith(
                                          fontWeight:
                                              isSelected || isHighlighted
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                        maxLines: finalDecoration.maxLines ?? 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Extension to provide additional utility methods
extension SDropdownExtension on SDropdown {
  /// Creates a copy of this dropdown with modified properties
  SDropdown copyWith({
    double? width,
    double? height,
    double? overlayHeight,
    double? overlayWidth,
    double? scale,
    List<String>? items,
    String? selectedItem,
    String? initialItem,
    String? hintText,
    Function(String?)? onChanged,
    TextStyle? itemTextStyle,
    TextStyle? headerTextStyle,
    TextStyle? hintTextStyle,
    Map<String, TextStyle>? itemSpecificStyles,
    Color? closedFillColor,
    Color? expandedFillColor,
    Border? closedBorder,
    Border? expandedBorder,
    BorderRadius? closedBorderRadius,
    BorderRadius? expandedBorderRadius,
    EdgeInsets? closedHeaderPadding,
    EdgeInsets? expandedHeaderPadding,
    EdgeInsets? itemsListPadding,
    EdgeInsets? listItemPadding,
    ScrollController? itemsScrollController,
    bool? excludeSelected,
    bool? canCloseOutsideBounds,
    bool? enabled,
    AlignmentGeometry? alignment,
    int? maxLines,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? Function(String?)? validator,
    bool? validateOnChange,
    SDropdownDecoration? decoration,
    SDropdownController? controller,
  }) {
    return SDropdown(
      key: key,
      items: items ?? this.items,
      width: width ?? this.width,
      height: height ?? this.height,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      scale: scale ?? this.scale,
      selectedItem: selectedItem ?? this.selectedItem,
      initialItem: initialItem ?? this.initialItem,
      hintText: hintText ?? this.hintText,
      onChanged: onChanged ?? this.onChanged,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      itemSpecificStyles: itemSpecificStyles ?? this.itemSpecificStyles,
      closedFillColor: closedFillColor ?? this.closedFillColor,
      expandedFillColor: expandedFillColor ?? this.expandedFillColor,
      closedBorder: closedBorder ?? this.closedBorder,
      expandedBorder: expandedBorder ?? this.expandedBorder,
      closedBorderRadius: closedBorderRadius ?? this.closedBorderRadius,
      expandedBorderRadius: expandedBorderRadius ?? this.expandedBorderRadius,
      closedHeaderPadding: closedHeaderPadding ?? this.closedHeaderPadding,
      expandedHeaderPadding:
          expandedHeaderPadding ?? this.expandedHeaderPadding,
      itemsListPadding: itemsListPadding ?? this.itemsListPadding,
      listItemPadding: listItemPadding ?? this.listItemPadding,
      itemsScrollController:
          itemsScrollController ?? this.itemsScrollController,
      excludeSelected: excludeSelected ?? this.excludeSelected,
      canCloseOutsideBounds:
          canCloseOutsideBounds ?? this.canCloseOutsideBounds,
      enabled: enabled ?? this.enabled,
      alignment: alignment ?? this.alignment,
      maxLines: maxLines ?? this.maxLines,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      validator: validator ?? this.validator,
      validateOnChange: validateOnChange ?? this.validateOnChange,
      decoration: decoration ?? this.decoration,
      controller: controller ?? this.controller,
      headerExpandedColor: headerExpandedColor,
      selectedItemText: selectedItemText,
      customItemsNamesDisplayed: customItemsNamesDisplayed,
    );
  }
}

class _DropdownOption {
  const _DropdownOption({
    required this.value,
    required this.displayText,
    required this.originalIndex,
  });

  final String value;
  final String displayText;
  final int originalIndex;
}
