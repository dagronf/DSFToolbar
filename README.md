# DSFToolbar

A description of this package.

## Why

NSToolbar has an amazing API with incredible flexibility, but I find that it can be too verbose and spread throughout your code with the use of delegates and callbacks.  Even moreso if you want to use actions and bindings on the toolbar objects which just increases the amount of boilerplate code required for each toolbar.

Because of this, I tended to find that I wasn't putting toolbars into my (admittedly basic) apps just because of the boilerplate required.

I was keen to see if I could produce an API that can :-

* use a SwiftUI- style declarative style for defining the toolbar
* provide a block-based or bindings based interaction model
* provide basic functionality for all of the toolbar item types.  For example, segmented controls, search controls
* provide fallback for older versions. For example, if you want to use the new macOS 11 splitview-tracking toolbar items you'd have to litter your code with `if #available(macOS 11, *)` comments.

This class doesn't have the full functionality of the `NSToolbar`/`NSToolbarDelegate`, but provides a decent chunk of the core functionality.

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

## Available toolbar item types

| Type | Description |
|------|-------------|
| Image | Basic toolbar 'image' type. Provides basic image, label, action etc |
| Search | Provides a search text field |
| Segmented | A simple segmented control |
| Separator (macOS 11 only) | Hooks into NSSplitView to track a toolbar separator to a split view separator | 
| Button | A toolbar item containing an `NSButton` |

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


