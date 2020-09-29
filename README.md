# DSFToolbar

A description of this package.

## Core

Core properties and bindings are available to all toolbar item types

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
