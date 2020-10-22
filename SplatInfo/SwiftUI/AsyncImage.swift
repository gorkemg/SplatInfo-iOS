//
//  AsyncImage.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct AsyncImage<Placeholder: View, ResultHolder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (UIImage) -> ResultHolder
    
    init(url: URL, @ViewBuilder placeholder: () -> Placeholder, @ViewBuilder image: @escaping (UIImage) -> ResultHolder) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    var body: some View {
        content.onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let loadedImage = loader.image {
                image(loadedImage)
            } else {
                placeholder
            }
        }
    }
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}
