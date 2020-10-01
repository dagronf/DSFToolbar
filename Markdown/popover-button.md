# PopoverButton

A toolbar item that displays a popover when activated.

[Example Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/popover-popup/PopupMenuViewcontroller.swift)

## Example

```swift
DSFToolbar.PopoverButton(NSToolbarItem.Identifier("Popover View"), popoverContentController: self.popovercontent)
   .label("Popover View")
   .image(ProjectAssets.ImageSet.toolbar_cog.template)
   .bindEnabled(to: self, withKeyPath: #keyPath(popoverViewEnabled))
```

## Properties

[Core properties](core.md)

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `viewController `  | `NSViewController`  | the view controller for the view to display in the popover |
| `image`  | `NSImage` | The image to display on the button |


## Actions

[Core actions](core.md)

## Bindings

[Core bindings](core.md)
