# Search

A search field toolbar item.  Uses `NSSearchToolbarItem` for macOS 11+, falls back to a embedded `NSSearchField` for earlier macOS versions.

[Example Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/SearchViewController.swift)

## Properties

[Core properties](core.md)

| Property   | Type    |  Description |
|----------|-------------|------|
| `delegate`  |  `NSSearchFieldDelegate` | The object to act as the delegate for the search field (overridden by `searchChange`) |

## Actions

[Core actions](core.md)

| Action    | Description |
|-----------|---------------------|
| `searchChange`  | The block to call when the content of the search field changes  |

## Bindings

[Core bindings](core.md)

| Binding   | Type    |  Description |
|----------|-------------|----------|
| `bindText` | `String` | Bind the search text to a key path
