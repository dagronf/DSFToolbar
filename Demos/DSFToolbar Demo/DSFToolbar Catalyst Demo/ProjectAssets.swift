// AUTOMATICALLY GENERATED USING SQUEAKER. DO NOT EDIT

import UIKit

class ProjectAssets {
	enum ImageSet: String {
		case toolbar_burger = "toolbar-burger"
		case toolbar_watermelon = "toolbar-watermelon"
		case AppIcon = "AppIcon"
		case toolbar_bold = "toolbar-bold"
		case toolbar_underline = "toolbar-underline"
		case toolbar_italic = "toolbar-italic"
		@inlinable var image: UIImage {
			return UIImage(named: self.rawValue)!
		}
		func image(renderingMode: UIImage.RenderingMode) -> UIImage {
			return image.withRenderingMode(renderingMode)
		}
	}
	@available(iOS 9, macOS 10.13, *)
	enum ColorSet: String {
		case AccentColor = "AccentColor"
		@inlinable var color: UIColor {
			return UIColor(named: self.rawValue)!
		}
		@inlinable var cgColor: CGColor {
			return color.cgColor
		}
	}
}
