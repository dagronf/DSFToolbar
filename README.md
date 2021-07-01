# DSFToolbar

![](https://img.shields.io/github/v/tag/dagronf/DSFToolbar) ![](https://img.shields.io/badge/macOS-10.11+-blueviolet) ![](https://img.shields.io/badge/macCatalyst-10.13+-blueviolet) ![](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![](https://img.shields.io/badge/License-MIT-lightgrey) [![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

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

   @objc dynamic var searchEnabled: Bool = true
   @objc dynamic var searchText: String = ""
   ...
   lazy var customToolbar: DSFToolbar = {
      DSFToolbar(
         toolbarIdentifier: NSToolbar.Identifier("Core"),
         allowsUserCustomization: true) {
   
         DSFToolbar.Item(NSToolbarItem.Identifier("item-new"))
            .label("New")
            .isSelectable(true)
            .image(ProjectAssets.ImageSet.toolbar_new_document.template)
            .shouldEnable { [weak self] in
               self?.canAddDocument() ?? false
            }
            .action { [weak self] _ in
               self?.addDocument()
            }
   
         DSFToolbar.Item(NSToolbarItem.Identifier("item-edit"))
            .label("Edit")
            .isSelectable(true)
            .image(ProjectAssets.ImageSet.toolbar_edit_document.template)
            .shouldEnable { [weak self] in
               self?.canEditDocument() ?? false
            }
            .action { [weak self] _ in
               self?.editDocument()
            }
   
         DSFToolbar.FlexibleSpace()
   
         DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
            .label("Search")
            .isSelectable(true)
            .bindIsEnabled(to: self, withKeyPath: \MyViewController.searchEnabled)
            .bindText(self, keyPath: \MyViewController.searchText)
      }
   }()
   ...
   // Attaching the window to the toolbar will make the toolbar appear
   self.customToolbar.attachedWindow = self.view.window
}
```
![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFToolbar/sample.png?raw=true)

And thats it!

## Installation

Use Swift Package Manager.

Add `https://github.com/dagronf/DSFToolbar` to your project.

There are two targets for this library :-

### DSFToolbar (Xcode 12)

The standard project (`DSFToolbar`) for Xcode 12 and later. Backwards compatible back to macOS 10.11 and supporting new features in macOS 11 Big Sur (such as split view tracking)

Backwards compatible back to macOS 10.11.

```swift
// Support for Xcode 12
import DSFToolbar_legacy
```

### DSFToolbar-legacy (Xcode 11)

A target for Xcode 11 for legacy applications that can't move up to Xcode 12 yet. Supports all functionlity _except_ for the new separator toolbar types introduced in macOS 11.  You can actually define the separator in your toolbar definition, it just won't have any effect (to aid migration later to Xcode 12).

Backwards compatible back to macOS 10.11.

```swift
// Support for Xcode 11
import DSFToolbar_legacy
```

## Usage

For the most part, you'll only really need to use [`DSFToolbar.Item`](Markdown/item.md), [`DSFToolbar.Group`](Markdown/group.md) and [`DSFToolbar.Search`](Markdown/search.md) to get 90+% of the toolbar functionality you'll need.

Even moreso if you target 10.15 or later, you can use `DSFToolbar.Group` as a segmented-style control by settings `isBordered(true)`.

# Concepts

## Toolbar

### Customization

A toolbar can me marked as customisable by settings `allowsUserCustomization: true` in the constructor of the toolbar.

## Items

### Default items

A toolbar item can be marked with `isDefault` to indicate that the item should appear on the default toolbar.  An item marked as `isDefault(false)` will not appear initially in the toolbar, but will appear in the customization palette to allow to be added.

### Selectable items

A toolbar item marked as `isSelectable` will show a selection marker when pressed. You can detect the toolbar selection change by providing a block for the `onSelectionChange` property.

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

Items which provide callbacks (for example, responses to clicks) can provide a block action to respond with as part of the declaration.

```swift
self.customToolbar = DSFToolbar(NSToolbar.Identifier("Buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .action { _ in
         Swift.print("Clicked burger!")
      }
   }
```

Capturing `self` in any block can create retain cycles, so make sure you `[weak self]` if you need to capture self within a block

### Block requests

Some toolbar items can request information. For example, you can pass a block that provides the enabled status of an `Image` item during the declaration.

Capturing `self` in any block can create retain cycles, so make sure you `[weak self]` if you need to capture self within a block

```swift
self.customToolbar = DSFToolbar(NSToolbar.Identifier("Enabled-buttons")) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-image-bordered"))
      .label("Burger")
      .shouldEnable { [weak self] in
         return self?.IsBurgerMenuEnabled() ?? false
      }
      .action { _ in
         Swift.print("Clicked burger!")
      }
   }
```

### Bindings

A lot of functionality can be hooked up via bindings in order to pass information to and from a toolbar item. For example, you can hook the content of the Search item to a class variable to observe when the content of the search field changes.

```swift
@objc dynamic var searchText: String = "" {
   didSet {
      // Update the search with the new string
   }
}
   ...
self.customToolbar = DSFToolbar(NSToolbar.Identifier("Search")) {
   DSFToolbar.Search(NSToolbarItem.Identifier("toolbar-search-field"))
      .label("Search")
      .bindText(self, keyPath: \MyViewController.searchText)
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
| [View](Markdown/view.md) | macOS | A toolbar item containing a custom view |

# Demos

You can find pre-made demos under the `Demos` folder

* `DSFToolbar Demo`: Project for Xcode 12 containing targets for macOS and macCatalyst
* `DSFToolbar Xcode 11 Demo`: A simple project for Xcode release versions (Xcode 11)

# Releases

### 2.0.0

* Changed Xcode 12 target to `DSFToolbar`  (was originally `DSFToolbar-beta`). 

	Source code imports must change from `import DSFToolbar_beta` to `import DSFToolbar`

* Changed Xcode 11 target to `DSFToolbar-legacy`  (was originally `DSFToolbar`)

	Source code imports must change from `import DSFToolbar` to `import DSFToolbar_legacy`

If you've used then 0.9.6 version of this library, you will need to migrate your projects to use the new targets. Your source code will also need to be updated to `import` the correct library module for the target.

### 0.9.6

* Initial public release

# License

MIT. Use it for anything you want! Let me know if you do use it somewhere, I'd love to hear about it.

```
MIT License

Copyright (c) 2021 Darren Ford

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
