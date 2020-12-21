//
//  SplatoonKit+Extensions.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI
import UIKit

extension Stage {
    
    var image : UIImage? {
        return assetImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
    }

    var thumbImage : UIImage? {
        return assetThumbImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
    }

    func cachedImage(directory: URL? = URL(fileURLWithPath: NSTemporaryDirectory())) -> UIImage? {
        let fileManager = FileManager.default
        let imageURL = URL(string: imageUrl)
        if let dir = directory, let url = imageURL {
            let fileURL = dir.appendingPathComponent(url.lastPathComponent)
            if fileManager.fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            }else{
                // try JPEG
                let jpegURL = fileURL.deletingPathExtension().appendingPathExtension("jpeg")
                if fileManager.fileExists(atPath: jpegURL.path) {
                    return UIImage(contentsOfFile: jpegURL.path)
                }
            }
        }
        return nil
    }
    
    var assetImage: UIImage? {
        return UIImage(named: "\(id)") ?? UIImage(named: "\(id)")
    }

    var assetThumbImage: UIImage? {
        return UIImage(named: "thumb_\(id)") ?? UIImage(named: "\(id)")
    }
}

extension GameModeType {

    var color : Color {
        switch self {
        case .regular:
            return Color.regularModeColor
        case .ranked:
            return Color.rankedModeColor
        case .league:
            return Color.leagueModeColor
        }
    }
}

extension CoopEvent {

    var color : Color {
        return Color.coopModeColor
    }
}

extension EventTimeframe {

    func relativeTimeText(date: Date) -> Text {
        return relativeTimeText(state: state(date: date))
    }

    func relativeTimeText(state: TimeframeActivityState) -> Text {
        switch state {
        case .active:
            return Text(" since ") + Text(startDate, style: .relative)
        case .soon:
            return Text(" in ") + Text(startDate, style: .relative)
        case .over:
            return Text(" ended ") + Text(endDate, style: .relative) + Text(" ago")
        }
    }
}
