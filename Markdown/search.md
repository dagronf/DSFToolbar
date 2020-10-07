# Search

A search field toolbar item.  Uses `NSSearchToolbarItem` for macOS 11+, falls back to a embedded `NSSearchField` for earlier macOS versions.

## Properties

[Core properties](core.md)

| Property   | Type    |  Description |
|----------|-------------|------|
| `delegate`  |  `NSSearchFieldDelegate` | The object to act as the delegate for the search field (overridden by `searchChange`) |

## Actions

[Core actions](core.md)

| Action    | Description |
|-----------|---------------------|
| `onSearchTextChange`  | The block to call when the content of the search field changes  |

## Bindings

[Core bindings](core.md)

| Binding   | Type    |  Description |
|----------|-------------|----------|
| `bindText` | `String` | Bind the search text to a key path. This is a two-way binding, allowing programmatic changes to propagate to the search control and vice-versa

# Examples

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/SearchViewController.swift)

## A two-way binding to a variable

```swift
@objc dynamic var searchText: String = "" {
   didSet {
      self.searchTermUpdated()
   }
}

...

DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
   .label("Search")
   .bindText(self, keyPath: #keyPath(searchText))
```

## Reacting to search field changes

```swift
@objc dynamic var searchText: String = "" {

...

DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
   .label("Search")
   .searchChange { [weak self] field, value in
      self?.updateSearchTerm(value)
   }
```
