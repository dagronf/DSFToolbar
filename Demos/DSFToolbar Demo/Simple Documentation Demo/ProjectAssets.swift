// AUTOMATICALLY GENERATED USING SQUEAKER. DO NOT EDIT

import AppKit

class ProjectAssets {
	enum ImageSet: String {
		case toolbar_new_document = "toolbar-new-document"
		case toolbar_edit_document = "toolbar-edit-document"
		case toolbar_new_note = "toolbar-new-note"
		case toolbar_remove_note = "toolbar-remove-note"
		case toolbar_view_data = "toolbar-view-data"
		case toolbar_view_outline = "toolbar-view-outline"
		case toolbar_view_regular = "toolbar-view-regular"
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
}
