// AUTOMATICALLY GENERATED USING SQUEAKER. DO NOT EDIT

// SwiftLint configuration

// swiftlint:disable superfluous_disable_command
// swiftlint:disable force_cast
// swiftlint:disable identifier_name
// swiftlint:disable vertical_whitespace
// swiftlint:disable nesting
// swiftlint:disable redundant_string_enum_value

#if os(macOS)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
public typealias PlatformView  = NSView
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
#if os(iOS) || os(tvOS)
public typealias PlatformView  = UIView
#endif
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif
/// The assets defined for the project
internal struct ProjectAssets { }

// MARK: - Image assets

extension ProjectAssets {
	/// Image assets
	enum Image: String {
		case AppIcon = "AppIcon"
		case addImage = "addImage"
		case i1 = "i1"
		case i2 = "i2"
		case i3 = "i3"
		case i4 = "i4"
		case toolbar_backward = "toolbar-backward"
		case toolbar_bold = "toolbar-bold"
		case toolbar_burger = "toolbar-burger"
		case toolbar_button_click = "toolbar-button-click"
		case toolbar_button_direction = "toolbar-button-direction"
		case toolbar_button_person_add = "toolbar-button-person-add"
		case toolbar_button_target = "toolbar-button-target"
		case toolbar_cog = "toolbar-cog"
		case toolbar_comment = "toolbar-comment"
		case toolbar_egg = "toolbar-egg"
		case toolbar_forward = "toolbar-forward"
		case toolbar_italic = "toolbar-italic"
		case toolbar_justify_centre = "toolbar-justify-centre"
		case toolbar_justify_full = "toolbar-justify-full"
		case toolbar_justify_left = "toolbar-justify-left"
		case toolbar_justify_right = "toolbar-justify-right"
		case toolbar_search_enable = "toolbar-search-enable"
		case toolbar_search_hardcode = "toolbar-search-hardcode"
		case toolbar_shape = "toolbar-shape"
		case toolbar_share = "toolbar-share"
		case toolbar_show_sidebar = "toolbar-show-sidebar"
		case toolbar_text_bigger = "toolbar-text-bigger"
		case toolbar_text_indent = "toolbar-text-indent"
		case toolbar_text_outdent = "toolbar-text-outdent"
		case toolbar_text_shape = "toolbar-text-shape"
		case toolbar_text_smaller = "toolbar-text-smaller"
		case toolbar_textbox = "toolbar-textbox"
		case toolbar_underline = "toolbar-underline"
		case toolbar_watermelon = "toolbar-watermelon"

		/// Returns the image as it is defined in the asset file
		@inlinable var image: PlatformImage { PlatformImage(named: self.rawValue)! }

		/// A template version for this image
		@inlinable var template: PlatformImage { self.withRenderingMode(.alwaysTemplate) }

		#if canImport(SwiftUI)
		@available(macOS 10.15, iOS 13, tvOS 13, *)
		@inlinable var Image: SwiftUI.Image { SwiftUI.Image(self.rawValue) }
		#endif

		/// The available image rendering modes
		enum RenderingMode: Int {
			/// Use the default rendering mode for the context where the image is used
			case automatic = 0
			/// Always draw the original image, without treating it as a template
			case alwaysOriginal = 1
			/// Always draw the image as a template image, ignoring its color information
			case alwaysTemplate = 2
		}

		/// Returns a new version of the image that uses the specified rendering mode.
		func withRenderingMode(_ renderingMode: RenderingMode) -> PlatformImage {
			switch renderingMode {
			case .automatic:
				#if os(macOS)
				return SQ_makeNSImageCopy(self.image)
				#else
				return self.image.withRenderingMode(.automatic)
				#endif
			case .alwaysOriginal:
				#if os(macOS)
				return SQ_makeNSImageCopy(self.image, isTemplate: false)
				#else
				return self.image.withRenderingMode(.alwaysOriginal)
				#endif
			case .alwaysTemplate:
				#if os(macOS)
				return SQ_makeNSImageCopy(self.image, isTemplate: true)
				#else
				return self.image.withRenderingMode(.alwaysTemplate)
				#endif
			}
		}
	}
}

// MARK: - Color assets

extension ProjectAssets {
	/// Color assets
	@available(iOS 9, macOS 10.13, *)
	enum Color: String {
		case AccentColor = "AccentColor"

		/// Returns the image as it is defined in the asset file
		@inlinable var color: PlatformColor { PlatformColor(named: self.rawValue)! }

		/// Returns the color as it is defined in the asset file as a CGColor
		@inlinable var cgColor: CGColor { self.color.cgColor }

		#if canImport(SwiftUI)
		/// Returns the color as a SwiftUI-style color object
		@available(macOS 10.15, iOS 13, tvOS 13, *)
		@inlinable var colorUI: SwiftUI.Color { SwiftUI.Color(self.rawValue) }
		#endif
	}
}

// MARK: - XIB assets

extension ProjectAssets {
	class PrimaryViewController {
		#if !os(macOS)
		@inlinable static func UINib(bundle: Bundle = Bundle.main) -> UIKit.UINib {
			return UIKit.UINib.init(nibName: "PrimaryViewController", bundle: bundle)
		}
		#endif
		static let ListItem = NSUserInterfaceItemIdentifier("ListItem")
	}
}

// MARK: - plist assets

extension ProjectAssets {
}


// MARK: - Support functions

#if os(macOS)
// Make a copy of an image with a specific rendering mode
private func SQ_makeNSImageCopy(_ object: NSImage, isTemplate: Bool? = nil) -> NSImage {
	let im = object.copy() as! NSImage
	if let isTemplate = isTemplate {
		im.isTemplate = isTemplate
	}
	return im
}
#endif
