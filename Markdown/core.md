# Core

Core properties and bindings are available to all toolbar item types.

## Properties

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `label`  | `String`    | The label to be displayed on the toolbar item |
| `paletteLabel`  | `String` (optional)   | The palette label is shown when the user is customizing the toolbar |
| `tooltip`  | `String` (optional) | The tooltip for the toolbar item |
| `isBordered` | `Bool` (false) | Apply a border to the toolbar item (10.15+)  |
| `isDefault` | `Bool` (true) | Mark the item as available on the 'default' toolbar presented to the user  |
| `isSelectable` | `Bool` (false) | Mark the toolbar item as being selectable  |

## Bindings

| Binding   | Type (default)     |  Description |
|----------|-------------|------|
| `bindLabel` | `String` | Bind the label for the toolbar item to a key path
| `bindEnabled` | `Bool` | Bind the enabled state for the toolbar item to a key path

## Legacy (pre 10.13) support

Earlier macOS versions did not support autolayout within the toolbar items and relied on the dev to specify a maximum and minimum size for the toolbar item.  If you need to support older systems you will need to provide these for each item - on 10.13+ these values will be ignored for autolayout constraints.

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `legacySizes`  | `CGSize,CGSize`    | The max and min size for the toolbar item |
