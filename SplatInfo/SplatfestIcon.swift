//
//  SplatfestIcon.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 12.11.22.
//

import UIKit
import PocketSVG

struct SplatfestIcon {
    
    private static func snapshotImage(for layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func iconForSplatfest(_ fest: Splatoon3.Schedule.Splatfest.Fest) -> UIImage? {
        guard let iconURL = iconURLForSplatfest(fest) else { return nil }
        let svgLayer = SVGLayer(contentsOf: iconURL)
        svgLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let image = self.snapshotImage(for: svgLayer)
        return image
    }
    
    static func iconURLForSplatfest(_ fest: Splatoon3.Schedule.Splatfest.Fest) -> URL? {
        let teams = fest.teams
        guard let team1 = teams.first, let team2 = teams.second, let team3 = teams.third else { return nil }
        guard let tricolorURL = Bundle.main.url(forResource: "tricolor.rgb", withExtension: ".svg") else { return nil }
        guard let data = try? Data(contentsOf: tricolorURL) else { return nil }
        guard var xml = String(data: data, encoding: .utf8) else { return nil }
        xml.replace("{color1.r}", with: "\(team1.color.r*255)")
        xml.replace("{color1.g}", with: "\(team1.color.g*255)")
        xml.replace("{color1.b}", with: "\(team1.color.b*255)")
//        xml.replace("{color1.a}", with: "\(team1.color.a)")
        xml.replace("{color2.r}", with: "\(team2.color.r*255)")
        xml.replace("{color2.g}", with: "\(team2.color.g*255)")
        xml.replace("{color2.b}", with: "\(team2.color.b*255)")
//        xml.replace("{color2.a}", with: "\(team2.color.a)")
        xml.replace("{color3.r}", with: "\(team3.color.r*255)")
        xml.replace("{color3.g}", with: "\(team3.color.g*255)")
        xml.replace("{color3.b}", with: "\(team3.color.b*255)")
//        xml.replace("{color3.a}", with: "\(team3.color.a)")
        let newFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(fest.id).svg")
        guard let data = xml.data(using: .utf8) else { return nil }
        guard ((try? data.write(to: newFileURL)) != nil) else { return nil }
        return newFileURL
    }
}

extension String {
    mutating func replace(_ originalString: String, with newString: String) {
        self = self.replacingOccurrences(of: originalString, with: newString)
    }
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return NSString(format:"#%06x", rgb) as String
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

}
