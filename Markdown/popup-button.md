# PopupButton

A toolbar item that displays a menu when activated.

## Properties

[Core properties](core.md)

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `menu` | `NSMenu` | The menu to display when the button is activated |
| `title`  | `String` | The title of the button |
| `image`  | `NSImage` | The image to display on the button |
| `imagePosition`  | `NSControl.ImagePosition` | The position of the image on the button (eg. left, right etc) |

## Actions

[Core actions](core.md)

## Bindings

[Core bindings](core.md)


# Example

```swift
DSFToolbar.PopupButton(
   NSToolbarItem.Identifier("PopupButton"), 
   menu: self.popupMenu)
     .label("Popup")
     .image(ProjectAssets.ImageSet.toolbar_cog.template)
     .bindIsEnabled(to: self, withKeyPath: \MyViewController.popupMenuEnabled)
```

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/popover-popup/PopupMenuViewcontroller.swift)
