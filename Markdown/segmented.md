# Segmented

Display one or more buttons in a single horizontal group.

A segmented control is built using multiple segment items (see Segment below), each representing a 'section' of the segmented control.  You can attach actions individually to each segment, or to the segmented control as a whole.

[Example Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/SegmentedViewController.swift)

## Example

```swift
DSFToolbar.Segmented(NSToolbarItem.Identifier("toolbar-styles-2"),
   type: .Separated,
   switching: .selectAny,
   segmentWidths: 32,
   DSFToolbar.Segmented.Segment()
      .image(ProjectAssets.ImageSet.toolbar_bold.template, scaling: .scaleProportionallyDown)
      .bindEnabled(to: self, withKeyPath: #keyPath(segmentEnabled)),
   DSFToolbar.Segmented.Segment()
      .image(ProjectAssets.ImageSet.toolbar_italic.template, scaling: .scaleProportionallyDown),
   DSFToolbar.Segmented.Segment()
      .image(ProjectAssets.ImageSet.toolbar_underline.template, scaling: .scaleProportionallyDown)
)
.action { selected in 
   Swift.print("Selection is now \(selected)")
}
```

## Properties

[Core propertes](core.md)

## Actions

[Core actions](core.md)

| Action    | Description |
|-----------|---------------------|
| `action`  | The block to call when the state of the segmented control changes.  Passes the current set of selected indexes  |

## Bindings

[Core bindings](core.md)

| Binding   | Type (default)     |  Description |
|----------|-------------|------|
| `bindSelection` | `Set<Int>` | Bind the selection indexes to a key path.

# Segment

A segment is a single section in a segmented control
	
## Properties
	
| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `title`  | `String`    | the title to display
| `image`  | `NSImage`    | the image to display
| `imagePosition`  | `NSControl.ImagePosition`    | The position of the image (eg. left, right etc) |
| `imageScaling`  | `NSImageScaling`    | How the image is scaled when presenting the image |

## Actions

None.
	
## Bindings
	
| Binding   | Type (default)     |  Description |
| `bindEnabled` | `Bool` | Bind the enabled state for the segment
