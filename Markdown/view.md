# View

A toolbar item containing a custom view

### DSFToolbarViewControllerProtocol

By implementing DSFToolbarViewControllerProtocol in your view controller, you can receive information back from the toolbar indicating state changes.

```swift
/// Called when the enabled state of the toolbarItem is changing
func setEnabled(_ state: Bool)

/// Called when the toolbar item is created and added to the toolbar
func willShow()

/// Called when the toolbar item is closing, and the view needs will go away
func willClose()
```


## Properties

[Core properties](core.md)
	
| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `viewController `  | `NSViewController`  | the view controller for the view to display |

## Actions

[Core actions](core.md)

## Bindings

[Core bindings](core.md)

# Example

```swift
DSFToolbar.View(
   NSToolbarItem.Identifier("customview1"), 
   viewController: self.customViewController)
     .label("Input Levels")
     .bindIsEnabled(to: self, withKeyPath: #keyPath(customViewEnabled))
```

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/custom-view/CustomViewController.swift)
