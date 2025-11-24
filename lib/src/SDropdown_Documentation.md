# SDropdown Widget Documentation (v1.0.0)

## Overview

`SDropdown` is a fully custom dropdown widget built from scratch for String items, providing complete control over dimensions and behavior. It's designed as a native Flutter implementation and uses a small set of optional helper packages for advanced features and responsive sizing.

## Architecture

### Core Components

1. **SDropdown (StatefulWidget)** - Main widget class
2. **_SDropdownState** - State management for dropdown behavior
3. **SDropdownDecoration** - Comprehensive styling configuration
4. **SDropdownExtension** - Utility methods for widget copying

### Key Features

- ✅ **Complete Dimension Control**: Width, height, overlay width, and overlay height
- ✅ **Native Flutter Performance**: Built with CompositedTransformTarget/Follower
- ✅ **Minimal External Dependencies**: Uses a small set of optional helper packages for advanced features (responsive sizing, indexed lists, and animation helpers)
- ✅ **Comprehensive Styling**: Every visual aspect is customizable
- ✅ **Advanced Functionality**: Scroll control, item exclusion, validation, icons
- ✅ **Custom display names**: Use `customItemsNamesDisplayed` to show alternate labels while keeping item values unchanged
- ✅ **Item-specific styles**: Apply per-item text styles with `itemSpecificStyles`
- ✅ **Selection header override**: Use `selectedItemText` to show a custom header for a selected item
- ✅ **Responsive Design**: Support for responsive sizing with .w and .h extensions

## Architecture Deep Dive

### Widget Structure

```
SDropdown
├── SizedBox (widget constraints)
└── Transform.scale (scaling support)
    └── CompositedTransformTarget (positioning anchor)
        └── GestureDetector (dropdown button)
            └── Container (styled button)
                └── Row (button content layout)
```

### Overlay Structure

```
OverlayEntry
└── Box (full-screen container - 100.w × 100.h)
    └── Stack
        ├── Positioned.fill (background tap-to-close)
        │   └── GestureDetector (close on outside tap)
        └── CompositedTransformFollower (positioned overlay)
            └── SizedBox (overlay size constraints)
                └── Material (overlay surface)
                    └── Container (styled overlay)
                        └── Scrollbar
                            └── IndexScrollListViewBuilder (items list)
```

## Key Technical Decisions

### 1. **Overlay Positioning Strategy**

**Problem Solved**: Precise overlay positioning and sizing control

**Solution**: 
- Uses `CompositedTransformTarget`/`CompositedTransformFollower` for pixel-perfect positioning
- Full-screen background container (`Box(100.w, 100.h)`) provides proper layout context
- Stack-based layering separates background handling from content positioning

### 2. **Constraint Management**

**Problem Solved**: Overlay width not respecting specified dimensions

**Solution**:
- Wraps overlay in full-screen container to establish proper constraint context
- Uses `SizedBox` to enforce exact overlay dimensions
- Stack architecture prevents constraint conflicts

### 3. **State Management**

**Problem Solved**: Complex dropdown state and lifecycle management

**Solution**:
- Clean separation of concerns: button state vs overlay state
- Proper overlay lifecycle management with `OverlayEntry`
- Robust cleanup in `dispose()` method

## API Reference

### Constructor Parameters

#### Core Functionality
```dart
SDropdown({
  required List<String> items,           // Items to display
  String? selectedItem,                  // Currently selected item
  Function(String?)? onChanged,          // Selection callback
  String? hintText,                     // Placeholder text
})
```

#### Dimensions
```dart
double? width,                    // Widget width
double? height,                   // Widget height  
double? overlayWidth,             // Overlay width (overrides width)
double? overlayHeight,            // Overlay height
double? scale,                    // Scale factor for entire widget
```

#### Styling
```dart
Color? closedFillColor,           // Button background (closed)
Color? expandedFillColor,         // Button background (expanded)
Border? closedBorder,             // Button border (closed)
Border? expandedBorder,           // Button border (expanded)
BorderRadius? closedBorderRadius, // Button border radius (closed)
BorderRadius? expandedBorderRadius, // Button border radius (expanded)
```

#### Text Styling
```dart
TextStyle? headerTextStyle,       // Selected item text style
TextStyle? hintTextStyle,         // Hint text style
TextStyle? itemTextStyle,         // Dropdown items text style
Map<String, TextStyle>? itemSpecificStyles, // Per-item styling
```

#### Layout & Spacing
```dart
EdgeInsets? closedHeaderPadding,  // Button padding (closed)
EdgeInsets? expandedHeaderPadding, // Button padding (expanded)
EdgeInsets? itemsListPadding,     // List container padding
EdgeInsets? listItemPadding,      // Individual item padding
```

#### Advanced Features
```dart
Widget? prefixIcon,               // Leading icon
Widget? suffixIcon,               // Trailing icon
ScrollController? itemsScrollController, // List scroll control
bool excludeSelected,             // Hide selected item in list
bool canCloseOutsideBounds,       // Allow outside tap to close
bool enabled,                     // Enable/disable widget
String? Function(String?)? validator, // Validation function
SDropdownDecoration? decoration, // Comprehensive styling object
```

## Usage Examples

### Basic Usage
```dart
SDropdown(
  width: 200,
  height: 50,
  items: ['Apple', 'Banana', 'Cherry'],
  selectedItem: selectedValue,
  hintText: 'Select a fruit',
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
)
```

### Advanced Styling
```dart
SDropdown(
  width: 300,
  height: 55,
  overlayWidth: 350,        // Wider overlay than button
  overlayHeight: 200,       // Fixed overlay height
  items: fruits,
  selectedItem: selected,
  onChanged: onChanged,
  decoration: SDropdownDecoration(
    closedFillColor: Colors.blue.shade50,
    expandedFillColor: Colors.white,
    closedBorder: Border.all(color: Colors.blue.shade300),
    expandedBorder: Border.all(color: Colors.blue.shade600, width: 2),
    closedBorderRadius: BorderRadius.circular(12),
    expandedBorderRadius: BorderRadius.circular(8),
    headerStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.blue.shade800,
    ),
    hintStyle: TextStyle(
      fontSize: 16,
      color: Colors.grey.shade600,
      fontStyle: FontStyle.italic,
    ),
  ),
  prefixIcon: Icon(Icons.search, color: Colors.blue),
  excludeSelected: true,
  itemsScrollController: scrollController,
)
```

### Responsive Sizing
```dart
SDropdown(
  width: 80.w,              // 80% of screen width
  height: 6.h,              // 6% of screen height
  overlayWidth: 85.w,       // 85% of screen width
  overlayHeight: 30.h,      // 30% of screen height
  // ... other properties
)
```

## Best Practices

### 1. **Dimension Planning**
```dart
// Plan your dimensions hierarchy:
// overlayWidth > width > button auto-size
// overlayHeight > decoration.overlayHeight > 200 (default)

SDropdown(
  width: 250,           // Button width
  overlayWidth: 300,    // Overlay wider than button
  overlayHeight: 180,   // Fixed overlay height
  // ...
)
```

### 2. **Performance Optimization**
```dart
// Use ScrollController for large lists
final ScrollController _scrollController = ScrollController();

SDropdown(
  itemsScrollController: _scrollController,
  // ...
)

// Don't forget to dispose
@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}
```

### 3. **Styling Consistency**
```dart
// Create reusable decoration objects
final SDropdownDecoration primaryDropdownStyle = SDropdownDecoration(
  closedFillColor: Theme.of(context).primaryColor.withOpacity(0.1),
  expandedFillColor: Colors.white,
  // ... other consistent styling
);

// Reuse across dropdowns
SDropdown(
  decoration: primaryDropdownStyle,
  // ...
)
```

### 4. **Validation Integration**
```dart
SDropdown(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  },
  validateOnChange: true,
  // ...
)
```

## Performance Characteristics

### Memory Usage
- **Lightweight**: Minimal external dependencies (used only for optional helper features in examples), minimal memory footprint
- **Efficient State Management**: Only rebuilds necessary components
- **Proper Cleanup**: Automatic overlay disposal prevents memory leaks

### Rendering Performance
- **Native Flutter**: Uses platform-optimized rendering
- **Minimal Redraws**: Smart state management reduces unnecessary rebuilds
- **Efficient Scrolling**: IndexScrollListViewBuilder with IndexedScrollController for large item lists

### Responsiveness
- **Smooth Animations**: Native Flutter transitions
- **Responsive Design**: Support for percentage-based sizing
- **Touch Optimization**: Proper gesture handling for mobile devices

## Troubleshooting

### Common Issues

1. **Overlay Not Showing**
   - Ensure `items` list is not empty
   - Check if `enabled` is set to `true`
   - Verify overlay is not positioned off-screen

2. **Width Not Respected**
   - Ensure you're using the fixed architecture with `Box` and `Stack`
   - Check that parent widget isn't constraining dimensions
   - Verify `overlayWidth` parameter is set correctly

3. **Items Not Displaying**
  - Check `itemCount` is properly set in IndexScrollListViewBuilder
   - Verify `excludeSelected` setting if selected item is missing
   - Ensure item text styles are visible (not transparent)

### Debug Tips
```dart
// Add debug prints to understand sizing
print("Button size: ${buttonSize.width} x ${buttonSize.height}");
print("Overlay width: $overlayWidth");
print("Overlay height: $overlayHeightValue");
```

## Migration Guide

### From DropdownFlutter
```dart
// Old (DropdownFlutter)
DropdownFlutter<String>(
  items: items,
  decoration: CustomDropdownDecoration(...),
  // ...
)

// New (SDropdown)
SDropdown(
  items: items,
  decoration: SDropdownDecoration(...),
  // ...
)
```

### Key Changes
- `CustomDropdownDecoration` → `SDropdownDecoration`
- More granular control over dimensions
- Native Flutter performance improvements
- Additional styling options available

## Future Enhancements

Potential areas for extension:
- Multi-select support
- Animated transitions
- Keyboard navigation
- Accessibility improvements
- Theme integration
- Custom item builders

## Conclusion

`SDropdown` provides a robust, performant, and highly customizable dropdown solution for Flutter applications. Its native implementation ensures optimal performance while providing complete control over appearance and behavior.

The widget is production-ready and suitable for applications requiring precise dropdown control without external dependencies.
