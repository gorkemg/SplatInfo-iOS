//
//  SplatInfoApp.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.20.
//

import SwiftUI
import WidgetKit

@main
struct SplatInfoApp: App {
    
    @ObservedObject private var scheduleFetcher = ScheduleFetcher()

    let imageLoaderManager = ImageLoaderManager()
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(splatoon2Schedule: $scheduleFetcher.splatoon2Schedule, splatoon3Schedule: $scheduleFetcher.splatoon3Schedule)
                .onAppear {
                    
                    scheduleFetcher.fetchSplatoon2Schedule { result in
                        WidgetCenter.shared.reloadAllTimelines()
                        switch result {
                        case .success(let success):
                            downloadImages(urls: success.allImageURLs(), asJPEG: true) {
                                print("Splatoon2 Images downloaded")
                                WidgetCenter.shared.reloadTimelines(ofKind: kindSplatoon2ScheduleWidget)
                            }
                            break
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                    scheduleFetcher.fetchSplatoon3Schedule { result in
                        WidgetCenter.shared.reloadAllTimelines()
                        switch result {
                        case .success(let success):
                            downloadImages(urls: success.coop.allImageURLs(), asJPEG: true) {
                                print("Splatoon 3 Images downloaded")
                                downloadImages(urls: success.coop.allWeaponImageURLs(), asJPEG: false) {
                                    print("Weapons downloaded")
                                    WidgetCenter.shared.reloadTimelines(ofKind: kindSplatoon3ScheduleWidget)
                                }
                            }
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }.environmentObject(imageQuality)
        }
    }
    
    
    var imageQuality : ImageQuality = {
        let quality = ImageQuality()
        quality.thumbnail = false
        return quality
    }()
    
    func downloadImages(urls: [URL], asJPEG: Bool = true, completion: @escaping ()->Void) {
        let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let multiImageLoader = MultiImageLoader(urls: urls, directory: destination)
        multiImageLoader.storeAsJPEG = asJPEG
        imageLoaderManager.imageLoaders.append(multiImageLoader)
        multiImageLoader.load {
            completion()
        }
    }
}
