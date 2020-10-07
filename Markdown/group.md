# Group

A group groups a number of toolbar items together into a single unit.

## Properties

[Core properties](core.md)

| Property   | Type (default)     |  Description |
|----------|-------------|------|
| `selectionMode`  | `SelectionMode`    | the style of the group (momentary, select any, select one) (10.15+ only)

## Actions

[Core actions](core.md)

## Bindings

[Core bindings](core.md)

# Example

```swift
DSFToolbar.Group(NSToolbarItem.Identifier("food-grouped"), selectionMode: .selectAny) {
   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-egg-2"))
      .label("Egg")
      .image(ProjectAssets.ImageSet.toolbar_egg.image)
      .action { _ in
         Swift.print("Got grouped egg!")
      }

   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-watermelon-2"))
      .label("Watermelon")
      .image(ProjectAssets.ImageSet.toolbar_watermelon.image)
      .action { _ in
         Swift.print("Got grouped watermelon!")
      }

   DSFToolbar.Image(NSToolbarItem.Identifier("toolbar-burger-2"))
      .label("Burger")
      .image(ProjectAssets.ImageSet.toolbar_burger.image)
      .action { _ in
         Swift.print("Got grouped burger!")
      }
}
```

[Sample Code](../Demos/DSFToolbar%20Demo/DSFToolbar%20Demo/panes/ButtonViewController.swift)
