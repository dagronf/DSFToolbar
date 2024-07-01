# Item

A standard toolbar item type.

If you supply an action for an item object then it will be enabled by default.  You can override this behaviour by 
providing either a `willEnable` block or a `bindEnabled()` to enable or disable an item when required.

## Properties

[Core properties](core.md)

| Property   | Type (default)     |  Description                  |
|:-----------|:-------------------|:------------------------------|
| `image`    | `NSImage`          | the image to display on the toolbar item |


## Actions

[Core actions](core.md)

| Action        | Description          |
|:--------------|:---------------------|
| `action`      | The block to call when the toolbar item is activated (eg. clicked)  |
| `willEnable`  | Supply a callback block to be called to determine the enabled state of the item |

## Bindings

[Core bindings](core.md)

## Bindings

| Binding     | Type (default)  | Description                             |
|:------------|:----------------|:----------------------------------------|
| `bindImage` | `DSFImage`      | Bind the image for the toolbar item     |

# Example

```swift
DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-watermelon"))
   .label("Watermelon")
   .image(ProjectAssets.ImageSet.toolbar_watermelon.image)
   .willEnable { [weak self] in
      self?.isWatermelonEnabled() ?? false
   }
   .action { _ in
      Swift.print("Got grouped watermelon!")
   }
```

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/ImagesViewController.swift)
