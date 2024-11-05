// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let accentPop = ColorAsset(name: "accentPop")
    internal static let blue10 = ColorAsset(name: "blue10")
    internal static let blue100 = ColorAsset(name: "blue100")
    internal static let blue20 = ColorAsset(name: "blue20")
    internal static let blue30 = ColorAsset(name: "blue30")
    internal static let blue40 = ColorAsset(name: "blue40")
    internal static let blue50 = ColorAsset(name: "blue50")
    internal static let blue60 = ColorAsset(name: "blue60")
    internal static let blue70 = ColorAsset(name: "blue70")
    internal static let blue80 = ColorAsset(name: "blue80")
    internal static let blue90 = ColorAsset(name: "blue90")
    internal static let brand10 = ColorAsset(name: "brand10")
    internal static let brand100 = ColorAsset(name: "brand100")
    internal static let brand20 = ColorAsset(name: "brand20")
    internal static let brand30 = ColorAsset(name: "brand30")
    internal static let brand40 = ColorAsset(name: "brand40")
    internal static let brand50 = ColorAsset(name: "brand50")
    internal static let brand60 = ColorAsset(name: "brand60")
    internal static let brand70 = ColorAsset(name: "brand70")
    internal static let brand80 = ColorAsset(name: "brand80")
    internal static let brand90 = ColorAsset(name: "brand90")
    internal static let green10 = ColorAsset(name: "green10")
    internal static let green100 = ColorAsset(name: "green100")
    internal static let green20 = ColorAsset(name: "green20")
    internal static let green30 = ColorAsset(name: "green30")
    internal static let green40 = ColorAsset(name: "green40")
    internal static let green50 = ColorAsset(name: "green50")
    internal static let green60 = ColorAsset(name: "green60")
    internal static let green70 = ColorAsset(name: "green70")
    internal static let green80 = ColorAsset(name: "green80")
    internal static let green90 = ColorAsset(name: "green90")
    internal static let grey10 = ColorAsset(name: "grey10")
    internal static let grey100 = ColorAsset(name: "grey100")
    internal static let grey20 = ColorAsset(name: "grey20")
    internal static let grey30 = ColorAsset(name: "grey30")
    internal static let grey40 = ColorAsset(name: "grey40")
    internal static let grey50 = ColorAsset(name: "grey50")
    internal static let grey60 = ColorAsset(name: "grey60")
    internal static let grey70 = ColorAsset(name: "grey70")
    internal static let grey80 = ColorAsset(name: "grey80")
    internal static let grey90 = ColorAsset(name: "grey90")
    internal static let red10 = ColorAsset(name: "red10")
    internal static let red100 = ColorAsset(name: "red100")
    internal static let red20 = ColorAsset(name: "red20")
    internal static let red30 = ColorAsset(name: "red30")
    internal static let red40 = ColorAsset(name: "red40")
    internal static let red50 = ColorAsset(name: "red50")
    internal static let red60 = ColorAsset(name: "red60")
    internal static let red70 = ColorAsset(name: "red70")
    internal static let red80 = ColorAsset(name: "red80")
    internal static let red90 = ColorAsset(name: "red90")
    internal static let white = ColorAsset(name: "white")
    internal static let yellow10 = ColorAsset(name: "yellow10")
    internal static let yellow100 = ColorAsset(name: "yellow100")
    internal static let yellow20 = ColorAsset(name: "yellow20")
    internal static let yellow30 = ColorAsset(name: "yellow30")
    internal static let yellow40 = ColorAsset(name: "yellow40")
    internal static let yellow50 = ColorAsset(name: "yellow50")
    internal static let yellow60 = ColorAsset(name: "yellow60")
    internal static let yellow70 = ColorAsset(name: "yellow70")
    internal static let yellow80 = ColorAsset(name: "yellow80")
    internal static let yellow90 = ColorAsset(name: "yellow90")
  }
  internal enum Images {
    internal static let image = ImageAsset(name: "Image")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
