# DSFToolbar

![tag](https://img.shields.io/github/v/tag/dagronf/DSFToolbar)
![Swift](https://img.shields.io/badge/Swift-5.4-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-magenta.svg)](https://github.com/dagronf/ColorPaletteCodable/blob/master/LICENSE) 
![SPM](https://img.shields.io/badge/spm-compatible-maroon.svg)

![macOS](https://img.shields.io/badge/macOS-10.13+-darkblue)
![macCatalyst](https://img.shields.io/badge/macCatalyst-2+-orangered)

A SwiftUI-style declarative `NSToolbar` for macOS and Mac Catalyst.

## Why?

NSToolbar has an amazing API with incredible flexibility, but I find that it can be too verbose and spread throughout your code with the use of delegates and callbacks for simpler projects and I have trouble keeping tabs on all the individual components. Even moreso if you want to use actions and bindings on the toolbar objects which just increases the amount code required for each toolbar.

Because of this, I tended to find that I wasn't putting toolbars into my (admittedly basic) apps.

I was keen to see if I could produce an API that can :-

* use a SwiftUI- style declarative style for defining the toolbar.
* provide a block-based or bindings based interaction model.
* provide basic functionality for all of the toolbar item types.  For example, segmented controls, search controls.
* provide fallback for newer toolbar functionality. For example, if you want to use the new macOS 11 splitview-tracking toolbar items you'd have to litter your code with `if #available(macOS 11, *)` if you want/need to support 10.15 (for example).
* legacy support for minSize/maxSize toolbar items on older macOS versions (before 10.13) if needed.

This module doesn't contain the full functionality of the `NSToolbar`/`NSToolbarDelegate`, but provides a decent chunk of the core functionality.

## TL;DR - Show me something!

If you're familiar with SwiftUI syntax you'll feel comfortable with the declaration style.

```swift
class MyViewController: NSViewController {
   // A binder to enable/disable the search field
   let searchEnabled = ValueBinder(true)
   // The search text binding to the content of the search toolbar item
   let searchText = ValueBinder("") { newValue in
      Swift.print("Search text is now \(newValue)")
   }
   ...
   lazy var customToolbar: DSFToolbar = {
      DSFToolbar(
         toolbarIdentifier: NSToolbar.Identifier("Core"),
         allowsUserCustomization: true
      ) {
         DSFToolbar.Item("item-new")
            .label("New")
            .isSelectable(true)
            .image(ProjectAssets.ImageSet.toolbar_new_document.template)
            .willEnable { [weak self] in
               self?.canAddDocument() ?? false
            }
            .action { [weak self] _ in
               self?.addDocument()
            }

         DSFToolbar.Item("item-edit")
            .label("Edit")
            .isSelectable(true)
            .image(ProjectAssets.ImageSet.toolbar_edit_document.template)
            .willEnable { [weak self] in
               self?.canEditDocument() ?? false
            }
            .action { [weak self] _ in
               self?.editDocument()
            }

         DSFToolbar.FlexibleSpace()

         DSFToolbar.Search("search-field")
            .label("Search")
            .isSelectable(true)
            .bindIsEnabled(searchEnabled)
            .bindText(self.searchText)
      }
   }()
   ...
   // Attaching the window to the toolbar will make the toolbar appear
   self.customToolbar.attachedWindow = self.view.window
}
```
![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFToolbar/sample.png?raw=true)

And thats it!

## Usage

For the most part, you'll only really need to use [`DSFToolbar.Item`](Markdown/item.md), [`DSFToolbar.Group`](Markdown/group.md) and [`DSFToolbar.Search`](Markdown/search.md) to get 90+% of the toolbar functionality you'll need.

Even moreso if you target 10.15 or later, you can use `DSFToolbar.Group` as a segmented-style control by settings 
`isBordered(true)`.

# Concepts

## Toolbar

### Customization

A toolbar can be marked as customisable by settings `allowsUserCustomization: true` in the constructor of the toolbar.

Additionally you can set or bind to the toolbar's display mode (eg. `.iconAndLabel`, `.labelOnly`) by calling
`displayMode()` or binding using `bindDisplayMode()` on your `DSFToolbar` instance.

## Items

### Default items

A toolbar item can be marked with `isDefault` to indicate that the item should appear on the default toolbar.
An item marked as `isDefault(false)` will not appear initially in the toolbar, but will appear in the customization
palette to allow to be added.

### Selectable items

A toolbar item marked as `isSelectable` will show a selection marker when pressed. You can detect the toolbar selection
change by providing a block for the `onSelectionChange` property.

```swift
self.customToolbar = DSFToolbar(NSToolbar.Identifier("My Toolbar")) {
      ...
   }
   .onSelectionChange { newToolbarSelection in
      // Do something when the selection changes
   }
```

## Items and Interaction

### Actions

Items which provide callbacks (for example, responses to clicks) can provide a block action to respond with as part of
the declaration.

```swift
self.customToolbar = DSFToolbar(NSToolbar.Identifier("Buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .action { _ in
         Swift.print("Clicked burger!")
      }
   }
```

Capturing `self` in any block can create retain cycles, so make sure you `[weak self]` if you need to capture self
within a block

### Block requests

Some toolbar items can request information. For example, you can pass a block that provides the enabled status of an 
`Image` item during the declaration.

Capturing `self` in any block can create retain cycles, so make sure you `[weak self]` if you need to capture self
within a block

```swift
self.customToolbar = DSFToolbar(NSToolbar.Identifier("Enabled-buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .willEnable { [weak self] in
         return self?.IsBurgerMenuEnabled() ?? false
      }
      .action { _ in
         Swift.print("Clicked burger!")
      }
   }
```

### Bindings

A lot of functionality can be hooked up via bindings in order to pass information to and from a toolbar item. 
For example, you can hook the content of the Search item to a class variable to observe when the content of the 
search field changes.

This library uses [DSFValueBinders](https://github.com/dagronf/DSFValueBinders) to provide two-way bindings between 
local properties and toolbar items.

```swift
let searchText = ValueBinder("") {
   // Update the search with the new string
}
   ...
self.customToolbar = DSFToolbar("Search") {
   DSFToolbar.Search("toolbar-search-field")
      .label("Search")
      .bindSearchText(self.searchText)
   }
```

### Cleanup

When you are finished with a toolbar, you need to call `close()` on the toolbar object. This will remove any bindings or observers or custom controls that were set up during the creation of the toolbar.

```swift
self.customToolbar.close()
```

## Available toolbar item types

### Common

| Type | Description |
|------|-------------|
| [Core](Markdown/core.md) | Core elements available to all toolbar item types |

### Controls

| Type | Available | Description |
|------|:--------:|-------------|
| [Item](Markdown/item.md) | macOS<br/>macCatalyst | Basic toolbar 'image' type. Provides basic image, label, action etc.  Most of the time you'll want this. |
| [Group](Markdown/group.md) | macOS<br/>macCatalyst | Group multiple items together to represent a common unit.<br/> This can also be used as a segmented control style (in catalyst and 10.15) by setting `isBordered(true)` on the group. |
| [Search](Markdown/search.md) | macOS<br/>macCatalyst | Provides a search text field |
| [Segmented](Markdown/segmented.md) | macOS<br/>macCatalyst | A simple segmented control |
| [Separator](Markdown/separator.md) | macOS11+<br/>macCatalyst | Hooks into an NSSplitView to track a toolbar separator to a split view separator | 
| [Button](Markdown/button.md) | macOS | A toolbar item containing an `NSButton` |
| [PopupButton](Markdown/popup-button.md) | macOS | A toolbar item that displays a menu when activated |
| [PopoverButton](Markdown/popover-button.md) | macOS | A toolbar item that displays a popover when activated |
| PopupMenu | macOS | A toolbar item that displays a selectable menu item |
| [View](Markdown/view.md) | macOS | A toolbar item containing a custom view |

# Demos

You can find pre-made demos under the `Demos` folder

* `DSFToolbar Demo`: Project for Xcode 12 containing targets for macOS and macCatalyst

# License

MIT. Use it for anything you want! Let me know if you do use it somewhere, I'd love to hear about it.

```
MIT License

Copyright (c) 2024 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to 
the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
