# Separator

Connect a toolbar item to the divider of a splitview so that the toolbar item will move with the splitview separator.

See [Apple's documentation](https://developer.apple.com/documentation/appkit/nstrackingseparatortoolbaritem)

On pre-macOS11 this item is ignored allowing for backwards compatibility

## Properties

[Core properties](core.md)
	
| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `splitView`  | `NSSplitView`    | the NSSplitView instance to track |
| `dividerIndex`  | `Int`    | The divider index (zero-based) in `splitView` to track |


## Actions

[Core actions](core.md)

## Bindings

[Core bindings](core.md)

# Example

```swift
DSFToolbar.Separator(
   NSToolbarItem.Identifier("primary-separator-sep-local"),
   splitView: self.localSplitView,
   dividerIndex: 0)
```

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/SeparatorViewController.swift)
