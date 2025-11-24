# s_dropdown

A native Flutter dropdown widget (SDropdown) focused on String items with full control over dimensions, layout, and styling.

Current version: 1.0.0

## Installation

For local development, add the following to your package's `pubspec.yaml`:

```yaml
dependencies:
  s_dropdown:
    path: ../
```

For published package usage, simply depend on `s_dropdown` from pub.dev (if published).

## Usage

Import the package and use `SDropdown` inside a `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';

// Basic example
SDropdown(
  items: ['Apple', 'Banana', 'Cherry'],
  hintText: 'Select a fruit',
  width: 240,
  height: 52,
  onChanged: (value) {
    // handle selection
  },
  controller: SDropdownController(),
)
```

### Advanced usage examples

Decorated dropdown with overlay sizing and custom item names:

```dart
SDropdown(
  items: ['a', 'b', 'c'],
  selectedItem: 'a',
  selectedItemText: 'Apple',
  customItemsNamesDisplayed: ['Apple', 'Banana', 'Cherry'],
  overlayWidth: 350,
  overlayHeight: 180,
  decoration: SDropdownDecoration(
    closedFillColor: Colors.white,
    expandedBorder: Border.all(color: Colors.blueAccent, width: 1.5),
  ),
)
```

Validator and item-specific styles with responsive sizing:

```dart
Form(
  child: SDropdown(
    items: ['Apple', 'Banana', 'Cherry'],
    hintText: 'Pick a fruit',
    width: 70.w,
    height: 6.h,
    itemSpecificStyles: {'Cherry': TextStyle(color: Colors.purple)},
    validateOnChange: true,
    validator: (v) => v == null ? 'Please select' : null,
  ),
)
```

Programmatic usage with `SDropdownController`:

```dart
final controller = SDropdownController();

SDropdown(
  items: ['A', 'B', 'C'],
  controller: controller,
);

// Toggle programmatically
controller.open();
controller.highlightNext();
controller.selectHighlighted();
```

## Features

- Full control over dropdown/button width, height, and overlay dimensions
- Native overlay positioning using CompositedTransformTarget/Follower
- No external runtime dependencies beyond Flutter (sizer may be used for examples)
- Advanced styling with `SDropdownDecoration`
- Keyboard & pointer interaction, highlight management, and overlay controls via `SDropdownController`

### Advanced features

- `excludeSelected` - hide the currently selected item from the overlay list
- `customItemsNamesDisplayed` - show custom display strings for items while keeping their logical values
- `itemSpecificStyles` - apply special text style per item
- `selectedItemText` - override the header display text for a selected item (useful when `customItemsNamesDisplayed` is used)
- `overlayWidth` / `overlayHeight` - explicitly control overlay sizing independent of the button
- `validateOnChange` and `validator` - integrate with basic validation flows
- `SDropdownController` - programmatic expansion, collapse, toggling, and highlight navigation
- `copyWith` - copy a widget with modified properties to reuse existing settings

## Example

See the `example/` folder for a runnable Flutter example: it includes a small app that demonstrates common usages and `SDropdownController` actions.

## Running tests

Run the widget tests with:

```bash
flutter test
```

## License

This package is licensed under the MIT License. See `LICENSE` for details.

## Repository

https://github.com/SoundSliced/s_dropdown

