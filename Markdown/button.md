# Button

A toolbar item containing an NSButton. You can supply your own NSButton instance if you want (for example, if you're loading from a XIB)

## Properties

[Core properties](core.md)

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `buttonType` | `NSButton.ButtonType` | The type of button (eg. on/off, toggle, momentary etc |
| `bezelStyle`  | `NSButton.BezelStyle` | The style of the button |
| `title`  | `String`    | The title of the button |
| `image`  | `NSImage`    | The image to display on the button |
| `imagePosition`  | `NSControl.ImagePosition`    | The position of the image on the button (eg. left, right etc) |
| `imageScaling`  | `NSImageScaling`    | How the image is scaled when presenting the image on the button |
| `width`  | `CGFloat/CGFloat` | The minimum/maximum widths for the button (autolayout) |

## Actions

[Core actions](core.md)

| Action    | Description |
|-----------|---------------------|
| `action`  | The block to call when the button is activated (eg. clicked)  |

## Bindings

[Core bindings](core.md)

| Binding   | Type (default)     |  Description |
|----------|-------------|-------------|
| `bindTitle` | `String` | Bind the button's title to a key path

# Example

```swift
DSFToolbar.Button(NSToolbarItem.Identifier("button-2"))
   .title("Left")
   .width(minVal: 70)
   .image(ProjectAssets.ImageSet.toolbar_button_click.template)
   .imagePosition(.imageLeft)
   .imageScaling(.scaleProportionallyDown)
   .legacySizes(minSize: NSSize(width: 75, height: 27))
```

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/ButtonViewController.swift)
