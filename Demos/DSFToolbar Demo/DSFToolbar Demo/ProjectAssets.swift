// AUTOMATICALLY GENERATED USING SQUEAKER. DO NOT EDIT

import AppKit

class ProjectAssets {
	enum ImageSet: String {
		case toolbar_bold = "toolbar-bold"
		case toolbar_burger = "toolbar-burger"
		case toolbar_justify_centre = "toolbar-justify-centre"
		case toolbar_button_person_add = "toolbar-button-person-add"
		case toolbar_search_hardcode = "toolbar-search-hardcode"
		case toolbar_watermelon = "toolbar-watermelon"
		case toolbar_search_enable = "toolbar-search-enable"
		case toolbar_underline = "toolbar-underline"
		case toolbar_justify_left = "toolbar-justify-left"
		case toolbar_button_direction = "toolbar-button-direction"
		case toolbar_cog = "toolbar-cog"
		case addImage = "addImage"
		case toolbar_button_target = "toolbar-button-target"
		case toolbar_button_click = "toolbar-button-click"
		case toolbar_egg = "toolbar-egg"
		case toolbar_justify_full = "toolbar-justify-full"
		case toolbar_justify_right = "toolbar-justify-right"
		case toolbar_italic = "toolbar-italic"
		case AppIcon = "AppIcon"
		@inlinable var image: NSImage {
			return NSImage(named: NSImage.Name(self.rawValue))!
		}
		@inlinable var template: NSImage {
			let im = self.image.copy() as! NSImage
			im.isTemplate = true
			return im
		}
	}
	@available(iOS 9, macOS 10.13, *)
	enum ColorSet: String {
		case AccentColor = "AccentColor"
		@inlinable var color: NSColor {
			return NSColor(named: self.rawValue)!
		}
		@inlinable var cgColor: CGColor {
			return color.cgColor
		}
	}
}
