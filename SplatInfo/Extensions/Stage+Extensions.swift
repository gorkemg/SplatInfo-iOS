//
//  Stage+Extensions.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 29.10.20.
//

import UIKit

extension Stage {
    
    var image : UIImage? {
        return cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL) ?? assetImage
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
        return UIImage(named: "thumb_\(id)") ?? UIImage(named: "\(id)")
    }
}
