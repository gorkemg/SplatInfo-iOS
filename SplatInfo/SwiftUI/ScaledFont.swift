//
//  ScaledFont.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat

    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    
    func scaledFont(name: String, size: CGFloat) -> some View {
        return self.modifier(ScaledFont(name: name, size: size))
    }

    func scaledSplat1Font(size: CGFloat) -> some View {
        return self.modifier(ScaledFont(name: "Splatoon1", size: size))
    }
    
    func scaledSplat2Font(size: CGFloat) -> some View {
        return self.modifier(ScaledFont(name: "Splatoon2", size: size))
    }
        
    func splat1Font(size: CGFloat) -> some View {
        return scaledSplat1Font(size: size).shadow(color: .black, radius: 1, x: 0.0, y: 1.0)
    }
    
    func splat2Font(size: CGFloat) -> some View {
        return scaledSplat2Font(size: size).shadow(color: .black, radius: 1, x: 0.0, y: 1.0)
    }

    func isInWidget() -> Bool {
        guard let extesion = Bundle.main.infoDictionary?["NSExtension"] as? [String: String] else { return false }
        guard let widget = extesion["NSExtensionPointIdentifier"] else { return false }
        return widget == "com.apple.widgetkit-extension"
    }
}
