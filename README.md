# DSFToolbar

A SwiftUI-style declarative `NSToolbar` for macOS.

Requires Xcode 12.

## Why?

NSToolbar has an amazing API with incredible flexibility, but I find that it can be too verbose and spread throughout your code with the use of delegates and callbacks for simpler projects. Even moreso if you want to use actions and bindings on the toolbar objects which just increases the amount of boilerplate code required for each toolbar.

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
@objc dynamic var searchEnabled: Bool = true
@objc dynamic var searchText: String = ""
...
self.customToolbar =
   DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("Core")) {

     DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-document-new"))
       .label("New")
       .image(NSImage(named: "toolbar-document-new")!)
       .enabled { return self.canAddDocument() }
       .action { _ in
          self.addDocument()
      }

     DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-document-edit"))
       .label("Edit")
       .image(NSImage(named: "toolbar-document-edit")!)
       .enabled { return self.canEditDocument() }
       .action { _ in
          self.editDocument()
      }

     DSFToolbar.FlexibleSpace

     DSFToolbar.Search(NSToolbarItem.Identifier("toolbar-search-field"))
       .label("Search")
       .bindIsEnabled(to: self, withKeyPath: #keyPath(searchEnabled))
       .bindText(self, keyPath: #keyPath(searchText))
   }

// Attaching the window to the toolbar will make the toolbar appear
self.customToolbar?.attachedWindow = self.window
```
![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFToolbar/sample.png?raw=true)

And thats it!

## Concepts

### Actions

Items which provide callbacks (for example, responses to clicks) can provide a block action to respond with as part of the declaration.

```swift
self.customToolbar = DSFToolbar.Make(NSToolbar.Identifier("Buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .action { _ in
         Swift.print("Clicked burger!")
      }
   }
```

### Block requests

Some toolbar items can request information. For example, you can pass a block that provides the enabled status of an `Image` item during the declaration.

```swift
self.customToolbar = DSFToolbar.Make(NSToolbar.Identifier("Enabled-buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .enabled {
         return self.IsBurgerMenuEnabled()
      }
      .action { _ in
         Swift.print("Clicked burger!")
      }
   }
```

### Bindings

A lot of functionality can be hooked up via bindings in order to pass information to and from a toolbar item. For example, you can hook the content of the Search item to a class variable to observe when the content of the search field changes.

```swift
@objc dynamic var searchText: String = ""
   ...
self.customToolbar = DSFToolbar.Make(NSToolbar.Identifier("Search")) {
   DSFToolbar.Search(NSToolbarItem.Identifier("toolbar-search-field"))
      .label("Search")
      .bindText(self, keyPath: #keyPath(searchText))
   }
```

## Available toolbar item types

| Type | Description |
|------|-------------|
| [Core](Markdown/core.md) | Core elements available to all toolbar item types |
| [Image](Markdown/image.md) | Basic toolbar 'image' type. Provides basic image, label, action etc |
| [Group](Markdown/group.md) | Group multiple items together to represent a unit |
| [Search](Markdown/search.md) | Provides a search text field |
| [Segmented](Markdown/segmented.md) | A simple segmented control |
| [Separator (macOS 11 only)](Markdown/separator.md) | Hooks into an NSSplitView to track a toolbar separator to a split view separator | 
| [Button](Markdown/button.md) | A toolbar item containing an `NSButton` |
| [PopupButton](Markdown/popup-button.md) | A toolbar item that displays a menu when activated |
| [PopoverButton](Markdown/popover-button.md) | A toolbar item that displays a popover when activated |
| [View](Markdown/view.md) | A toolbar item containing a custom view |

# License

```
MIT License

Copyright (c) 2020 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
