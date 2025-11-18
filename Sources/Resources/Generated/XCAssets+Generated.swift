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
    internal enum Base {
      internal static let black = ColorAsset(name: "base/black")
      internal static let white = ColorAsset(name: "base/white")
    }
    internal enum Brand {
      internal enum Primary {
        internal static let _100 = ColorAsset(name: "brand/primary/100")
        internal static let _200 = ColorAsset(name: "brand/primary/200")
        internal static let _300 = ColorAsset(name: "brand/primary/300")
        internal static let _400 = ColorAsset(name: "brand/primary/400")
        internal static let _50 = ColorAsset(name: "brand/primary/50")
        internal static let _500 = ColorAsset(name: "brand/primary/500")
        internal static let _600 = ColorAsset(name: "brand/primary/600")
        internal static let _700 = ColorAsset(name: "brand/primary/700")
        internal static let _800 = ColorAsset(name: "brand/primary/800")
        internal static let _900 = ColorAsset(name: "brand/primary/900")
        internal static let _950 = ColorAsset(name: "brand/primary/950")
        internal static let base = ColorAsset(name: "brand/primary/base")
      }
      internal enum Secondary {
        internal static let _100 = ColorAsset(name: "brand/secondary/100")
        internal static let _200 = ColorAsset(name: "brand/secondary/200")
        internal static let _300 = ColorAsset(name: "brand/secondary/300")
        internal static let _400 = ColorAsset(name: "brand/secondary/400")
        internal static let _50 = ColorAsset(name: "brand/secondary/50")
        internal static let _500 = ColorAsset(name: "brand/secondary/500")
        internal static let _600 = ColorAsset(name: "brand/secondary/600")
        internal static let _700 = ColorAsset(name: "brand/secondary/700")
        internal static let _800 = ColorAsset(name: "brand/secondary/800")
        internal static let _900 = ColorAsset(name: "brand/secondary/900")
        internal static let _950 = ColorAsset(name: "brand/secondary/950")
        internal static let base = ColorAsset(name: "brand/secondary/base")
      }
    }
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
    internal enum Info {
      internal static let _100 = ColorAsset(name: "info/100")
      internal static let _200 = ColorAsset(name: "info/200")
      internal static let _300 = ColorAsset(name: "info/300")
      internal static let _400 = ColorAsset(name: "info/400")
      internal static let _50 = ColorAsset(name: "info/50")
      internal static let _500 = ColorAsset(name: "info/500")
      internal static let _600 = ColorAsset(name: "info/600")
      internal static let _700 = ColorAsset(name: "info/700")
      internal static let _800 = ColorAsset(name: "info/800")
      internal static let _900 = ColorAsset(name: "info/900")
      internal static let _950 = ColorAsset(name: "info/950")
      internal static let base = ColorAsset(name: "info/base")
    }
    internal enum Negative {
      internal static let _100 = ColorAsset(name: "negative/100")
      internal static let _200 = ColorAsset(name: "negative/200")
      internal static let _300 = ColorAsset(name: "negative/300")
      internal static let _400 = ColorAsset(name: "negative/400")
      internal static let _50 = ColorAsset(name: "negative/50")
      internal static let _500 = ColorAsset(name: "negative/500")
      internal static let _600 = ColorAsset(name: "negative/600")
      internal static let _700 = ColorAsset(name: "negative/700")
      internal static let _800 = ColorAsset(name: "negative/800")
      internal static let _900 = ColorAsset(name: "negative/900")
      internal static let _950 = ColorAsset(name: "negative/950")
      internal static let base = ColorAsset(name: "negative/base")
    }
    internal enum Neutral {
      internal static let _100 = ColorAsset(name: "neutral/100")
      internal static let _200 = ColorAsset(name: "neutral/200")
      internal static let _300 = ColorAsset(name: "neutral/300")
      internal static let _400 = ColorAsset(name: "neutral/400")
      internal static let _50 = ColorAsset(name: "neutral/50")
      internal static let _500 = ColorAsset(name: "neutral/500")
      internal static let _600 = ColorAsset(name: "neutral/600")
      internal static let _700 = ColorAsset(name: "neutral/700")
      internal static let _800 = ColorAsset(name: "neutral/800")
      internal static let _900 = ColorAsset(name: "neutral/900")
      internal static let _950 = ColorAsset(name: "neutral/950")
      internal static let base = ColorAsset(name: "neutral/base")
    }
    internal enum Positive {
      internal static let _100 = ColorAsset(name: "positive/100")
      internal static let _200 = ColorAsset(name: "positive/200")
      internal static let _300 = ColorAsset(name: "positive/300")
      internal static let _400 = ColorAsset(name: "positive/400")
      internal static let _50 = ColorAsset(name: "positive/50")
      internal static let _500 = ColorAsset(name: "positive/500")
      internal static let _600 = ColorAsset(name: "positive/600")
      internal static let _700 = ColorAsset(name: "positive/700")
      internal static let _800 = ColorAsset(name: "positive/800")
      internal static let _900 = ColorAsset(name: "positive/900")
      internal static let _950 = ColorAsset(name: "positive/950")
      internal static let base = ColorAsset(name: "positive/base")
    }
    internal enum Warning {
      internal static let _100 = ColorAsset(name: "warning/100")
      internal static let _200 = ColorAsset(name: "warning/200")
      internal static let _300 = ColorAsset(name: "warning/300")
      internal static let _400 = ColorAsset(name: "warning/400")
      internal static let _50 = ColorAsset(name: "warning/50")
      internal static let _500 = ColorAsset(name: "warning/500")
      internal static let _600 = ColorAsset(name: "warning/600")
      internal static let _700 = ColorAsset(name: "warning/700")
      internal static let _800 = ColorAsset(name: "warning/800")
      internal static let _900 = ColorAsset(name: "warning/900")
      internal static let _950 = ColorAsset(name: "warning/950")
      internal static let base = ColorAsset(name: "warning/base")
    }
  }
  internal enum Images {
    internal static let blankFile = ImageAsset(name: "blankFile")
    internal static let clockBadgeZzz = ImageAsset(name: "clockBadgeZzz")
    internal static let closedConversation = ImageAsset(name: "closedConversation")
    internal static let inactivityIcon = ImageAsset(name: "inactivityIcon")
    internal static let listPickerIcon = ImageAsset(name: "listPickerIcon")
    internal static let lottieHourglass = DataAsset(name: "lottie_hourglass")
    internal static let offline = ImageAsset(name: "offline")
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

internal struct DataAsset {
  internal fileprivate(set) var name: String

  @available(iOS 9.0, tvOS 9.0, watchOS 6.0, macOS 10.11, *)
  internal var data: NSDataAsset {
    guard let data = NSDataAsset(asset: self) else {
      fatalError("Unable to load data asset named \(name).")
    }
    return data
  }
}

@available(iOS 9.0, tvOS 9.0, watchOS 6.0, macOS 10.11, *)
internal extension NSDataAsset {
  convenience init?(asset: DataAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS) || os(watchOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(macOS)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}

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
