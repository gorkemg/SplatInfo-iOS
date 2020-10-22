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
            self.image = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in self?.cache($0) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
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
