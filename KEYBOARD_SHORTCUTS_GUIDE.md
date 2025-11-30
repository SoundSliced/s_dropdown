# SDropdown Keyboard Navigation - Quick Reference

## New Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `useKeyboardNavigation` | `bool` | `true` | Enable/disable keyboard navigation |
| `focusNode` | `FocusNode?` | `null` | Optional external FocusNode for focus management |
| `requestFocusOnInit` | `bool` | `false` | Auto-focus the dropdown on initialization |

## Keyboard Shortcuts

| Key | Action | Behavior |
|-----|--------|----------|
| **Arrow Down** | Navigate Down | Opens dropdown if closed, moves to next item if open |
| **Arrow Up** | Navigate Up | Opens dropdown if closed, moves to previous item if open |
| **Enter** | Select/Activate | Opens dropdown if closed, selects highlighted item if open |
| **Space** | Select/Activate | Opens dropdown if closed, selects highlighted item if open |
| **Escape** | Close | Closes dropdown without making a selection |
| **Backspace** | Close | Closes dropdown without making a selection |
| **Tab** | Navigation | Closes dropdown (if open) and moves focus to next element |

## Visual Feedback

When keyboard navigation is enabled and the dropdown has focus:
- **Blue glow** (shadow) around the dropdown
- **Blue border** with 1px width
- Smooth animation (140ms ease-out) when focus changes

## Examples

### Default (keyboard navigation enabled)
```dart
SDropdown(
  items: ['Option 1', 'Option 2', 'Option 3'],
  selectedItem: _selection,
  onChanged: (value) {
    setState(() => _selection = value);
  },
)
```

### Disabled keyboard navigation
```dart
SDropdown(
  items: ['Option 1', 'Option 2', 'Option 3'],
  selectedItem: _selection,
  onChanged: (value) {
    setState(() => _selection = value);
  },
  useKeyboardNavigation: false, // No keyboard shortcuts
)
```

### With external FocusNode
```dart
final FocusNode _myFocusNode = FocusNode();

SDropdown(
  items: ['Option 1', 'Option 2', 'Option 3'],
  selectedItem: _selection,
  onChanged: (value) {
    setState(() => _selection = value);
  },
  focusNode: _myFocusNode, // Use external FocusNode
)

// Later, you can programmatically request focus:
_myFocusNode.requestFocus();
```

### Auto-focus on init
```dart
SDropdown(
  items: ['Option 1', 'Option 2', 'Option 3'],
  selectedItem: _selection,
  onChanged: (value) {
    setState(() => _selection = value);
  },
  requestFocusOnInit: true, // Automatically focuses when widget builds
)
```

## Integration with Existing Code

The keyboard navigation feature is **fully backward compatible**. All existing `SDropdown` widgets will automatically have keyboard navigation enabled without any code changes.

To disable it for specific instances, simply add:
```dart
useKeyboardNavigation: false
```

## Selector2 Widget

The `Selector2` widget now uses `SDropdown`'s built-in keyboard navigation. It passes through the following parameters:
- `isFocusable` → `useKeyboardNavigation`
- `focusNode` → `focusNode`
- `requestFocusOnInit` → `requestFocusOnInit`

This means `Selector2` is now much simpler and delegates all keyboard handling to `SDropdown`.
