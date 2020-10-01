# DSFToolbar

A SwiftUI-style declarative `NSToolbar` for macOS.

## Why?

NSToolbar has an amazing API with incredible flexibility, but I find that it can be too verbose and spread throughout your code with the use of delegates and callbacks for simpler projects. Even moreso if you want to use actions and bindings on the toolbar objects which just increases the amount of boilerplate code required for each toolbar.

Because of this, I tended to find that I wasn't putting toolbars into my (admittedly basic) apps just because of the boilerplate required.

I was keen to see if I could produce an API that can :-

* use a SwiftUI- style declarative style for defining the toolbar.
* provide a block-based or bindings based interaction model.
* provide basic functionality for all of the toolbar item types.  For example, segmented controls, search controls.
* provide fallback for newer toolbar functionality. For example, if you want to use the new macOS 11 splitview-tracking toolbar items you'd have to litter your code with `if #available(macOS 11, *)` if you want/need to support 10.15 (for example).
* legacy support for minSize/maxSize toolbar items on older macOS versions (before 10.13) if needed.

This module doesn't contain the full functionality of the `NSToolbar`/`NSToolbarDelegate`, but provides a decent chunk of the core functionality.

## Simple Example

```swift
self.customToolbar = 
   DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("Core")) {
   
      DSFToolbar.Image(NSToolbarItem.Identifier("item-new"))
         .label("New")
         .image(…some image…)
         .enabled { return false }
         .action  { Swift.print("Pressed item 1") }
         
      DSFToolbar.Image(NSToolbarItem.Identifier("item-edit"))
         .label("Edit")
         .image(…some image…)
         .enabled { return true }
         .action  { Swift.print("Pressed item 2") }
         
      DSFToolbar.FlexibleSpace
      
      DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
         .label("Search")
         .bindEnabled(to: self, withKeyPath: "searchEnabled")
         .bindText(self, keyPath: "searchText")
   }
   
// Attaching the window to the toolbar will make the toolbar appear
self.customToolbar.attachedWindow = …some window…
```

## Concepts

### Bindings

A lot of functionality can be hooked up via bindings in order to pass information to and from a toolbar item. For example, you can hook the content of the Search item to a class variable to observe when the content of the search field changes.

```swift
@objc dynamic var searchText: String = ""
   ...
self.customToolbar = DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("Search")) {
   DSFToolbar.Search(NSToolbarItem.Identifier("toolbar-search-field"))
      .label("Search")
      .bindText(self, keyPath: "searchText")
```

### Actions



```swift
self.customToolbar = DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("Buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .action { _ in
         Swift.print("Clicked burger!")
      }

```


## Available toolbar item types

| Type | Description |
|------|-------------|
| Image | Basic toolbar 'image' type. Provides basic image, label, action etc |
| Group | Group multiple items together to represent a unit
| Search | Provides a search text field |
| Segmented | A simple segmented control |
| Separator (macOS 11 only) | Hooks into a NSSplitView to track a toolbar separator to a split view separator | 
| Button | A toolbar item containing an `NSButton` |
| View | A toolbar item containing a custom view |

# Available Properties, Bindings and Actions

## Core

Core properties and bindings are available to all toolbar item types.

### Properties

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `label`  | `String`    | The label to be displayed on the toolbar item |
| `paletteLabel`  | `String` (optional)   | The palette label is shown when the user is customizing the toolbar |
| `tooltip`  | `String` (optional) | The tooltip for the toolbar item |
| `isBordered` | `Bool` (false) | Apply a border to the toolbar item (10.15+)  |
| `isDefault` | `Bool` (true) | Mark the item as available on the 'default' toolbar presented to the user  |
| `isSelectable` | `Bool` (false) | Mark the toolbar item as being selectable  |

### Bindings

| Binding   | Type (default)     |  Description |
|----------|-------------|------|
| `bindLabel` | `String` | Bind the label for the toolbar item to a key path
| `bindEnabled` | `Bool` | Bind the enabled state for the toolbar item to a key path

### Legacy (pre 10.13) support

Earlier macOS versions did not support autolayout within the toolbar items and relied on the dev to specify a maximum and minimum size for the toolbar item.  If you need to support older systems you will need to provide these for each item - on 10.13+ these values will be ignored for autolayout constraints.

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `legacySizes`  | `CGSize,CGSize`    | The max and min size for the toolbar item |

## Image

A toolbar 'image' type is the basic type of toolbar items

### Properties

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `image`  | `NSImage`    | the image to display on the toolbar item


### Actions

| Action    | Description |
|-----------|---------------------|
| `action`  | The block to call when the toolbar item is activated (eg. clicked)  |
| `enabled` | Supply a callback block to be called to determine the enabled state of the item |


## Search

A search field toolbar item.  Uses `NSSearchToolbarItem` for macOS 11+, falls back to a embedded `NSSearchField` for earlier macOS versions.

### Properties

| Property   | Type    |  Description |
|----------|-------------|------|
| `delegate`  |  `NSSearchFieldDelegate` | The object to act as the delegate for the search field (overridden by `searchChange`) |

### Actions

| Action    | Description |
|-----------|---------------------|
| `searchChange`  | The block to call when the content of the search field changes  |

### Bindings

| Binding   | Type    |  Description |
|----------|-------------|----------|
| `bindText` | `String` | Bind the search text to a key path

## Group

A group groups a number of toolbar items together into a single unit.


