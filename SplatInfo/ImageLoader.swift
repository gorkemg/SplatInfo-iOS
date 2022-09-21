//
//  ImageLoader.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import UIKit
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL

    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    var isCachingOnDiskEnabled = true
    var cacheDirectory: URL? = URL(fileURLWithPath: NSTemporaryDirectory())

    deinit {
        cancel()
    }
    
    init(url: URL) {
        self.url = url
    }

    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }

    func load() {
        if let image = cache?[url] {
            print("ImageLoader: using Cache for \(url)")
            self.image = image
            return
        }else if let image = loadFromDisk(filename: url.lastPathComponent) {
            print("ImageLoader: using diskCache for \(url)")
            self.image = image
            return
        }
        download()
    }
    
    func download() {
        print("ImageLoader: Downloading image: \(url)")
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in
                if let image = $0, let url = self?.url {
                    self?.cacheOnDisk(image, filename: url.lastPathComponent)
                    if let fileUrl = self?.cacheFileURL(filename: url.lastPathComponent) {
                        if let downscaledImage = self?.downsample(imageAt: fileUrl, to: CGSize(width: image.size.width/2, height: image.size.height/2), scale: image.scale) {
                            self?.cacheOnDisk(downscaledImage, filename: url.lastPathComponent)
                            self?.cache(downscaledImage)
                            return
                        }
                    }
                }
                self?.cache($0)
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
            }
    }

    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    func loadFromDisk(filename: String) -> UIImage? {
        if !isCachingOnDiskEnabled { return nil }
        let filePath = cacheFileURL(filename: filename)
        if let jpegURL = filePath?.deletingPathExtension().appendingPathExtension("jpeg"), FileManager.default.fileExists(atPath: jpegURL.path) {
            return  UIImage(contentsOfFile: jpegURL.path)
        }
        if let path = filePath, FileManager.default.fileExists(atPath: path.path) {
            return UIImage(contentsOfFile: path.path)
        }
        return nil
    }
    
    func cacheOnDisk(_ image: UIImage, filename: String) {
        if !isCachingOnDiskEnabled { return }
        let filePath = cacheFileURL(filename: filename)
        if let path = filePath, let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: path)
            copyCacheFileToAppGroupDirectory(filename)
        }
    }
    
    private func cacheFileURL(filename: String) -> URL? {
        return cacheDirectory?.appendingPathComponent(filename)
    }
    
    private func copyCacheFileToAppGroupDirectory(_ filename: String) {
        let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName)
        NSLog("sharedContainerURL = \(String(describing: sharedContainerURL))")
        if let sourceURL = cacheFileURL(filename: filename) {
            if let destinationURL = sharedContainerURL?.appendingPathComponent(filename) {
                try? FileManager().copyItem(at: sourceURL, to: destinationURL)
            }
        }
    }

    
    // Downsampling large images for display at smaller size
    func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            // Should include kCGImageSourceCreateThumbnailWithTransform: true in the options dictionary. Otherwise, the image result will appear rotated when an image is taken from camera in the portrait orientation.
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}



class MultiImageLoader {
    
    let urls : [URL]
    @Published var finishedURLs : [URL] = []
    let directory: URL
    var resizeImages = true
    var storeAsJPEG = true
    var useCachedImage = true
    

    var downloadTasks: [URLSessionDownloadTask] = []
    
    init(urls: [URL], directory: URL) {
        self.urls = urls
        self.directory = directory
    }
    
    func load(completion: @escaping ()->Void) {
        let count = urls.count
        var counter = 0
        let fileManager = FileManager.default

        for url in urls {
            
            let fileURL = self.directory.appendingPathComponent(url.lastPathComponent)
            let jpegURL = fileURL.deletingPathExtension().appendingPathExtension("jpeg")
            if fileManager.fileExists(atPath: fileURL.path) {
                if self.useCachedImage {
                    print("MultiImageLoader: usingCache for (\(url)")
                    self.finishedURLs.append(url)
                    counter += 1
                    if count == counter {
                        completion()
                    }
                    continue
                }
                try? fileManager.removeItem(at: fileURL)
                
            }else if fileManager.fileExists(atPath: jpegURL.path) {
                if self.useCachedImage {
                    print("MultiImageLoader: usingCache for (\(url)")
                    self.finishedURLs.append(url)
                    counter += 1
                    if count == counter {
                        completion()
                    }
                    continue
                }
                try? fileManager.removeItem(at: fileURL)
            }

            print("MultiImageLoader: Downloading (\(url)")
            let task = URLSession.shared.downloadTask(with: url) { [weak self] location, response, error in

                guard let self = self else { return }
                guard let tempLocation = location, error == nil else {
                    print("Error downloading message: \(String(describing: error))")
                    return
                }
                
                counter += 1

                do {
                    if self.storeAsJPEG, let image = UIImage(contentsOfFile: tempLocation.path), let data = image.jpegData(compressionQuality: 0.8) {
                        try? data.write(to: jpegURL)
                    }else{
                        try fileManager.moveItem(at: tempLocation, to: fileURL)
                    }
                } catch {
                    print("Error downloading message: \(error)")
                }
                print("\(count) == \(counter)")
                self.finishedURLs.append(url)
                if count == counter {
                    completion()
                }
            }
            downloadTasks.append(task)
            task.resume()
        }
    }    
}

class ImageLoaderManager {

    var imageLoaders: [MultiImageLoader] = []

}
