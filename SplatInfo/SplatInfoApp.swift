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
    
    private let scheduleFetcher = ScheduleFetcher()
    @State var schedule = Splatoon2Schedule.empty
    let imageLoaderManager = ImageLoaderManager()
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(schedule: schedule)
                .onAppear {

                    // test example
//                    let coopEvent = Schedule.example.coop.detailedEvents.first
//                    print("CoopEvent: \(coopEvent)")
                    
                    scheduleFetcher.fetchGameModeTimelines { (gameModeTimelines, error) in
                        schedule = scheduleFetcher.schedule
                        WidgetCenter.shared.reloadAllTimelines()
                        guard let timelines = gameModeTimelines else { return }
//                        let urls = [timelines.ranked.allImageURLs(),timelines.regular.allImageURLs(),timelines.league.allImageURLs()].flatMap({ $0 })
//                        downloadImages(urls: urls) {
//                            schedule = scheduleFetcher.schedule
//                            WidgetCenter.shared.reloadAllTimelines()
//                        }
                    }
                    scheduleFetcher.fetchCoopTimeline { (coopTimeline, error) in
                        schedule = scheduleFetcher.schedule
                        WidgetCenter.shared.reloadAllTimelines()
//                        guard let timeline = coopTimeline else { return }
//                        let stageURLs = timeline.allStageImageURLs()
//                        downloadImages(urls: stageURLs) {
//                            WidgetCenter.shared.reloadAllTimelines()
//                        }
//                        let weaponURLs = timeline.allWeaponImageURLs()
//                        downloadImages(urls: weaponURLs, asJPEG: false) {
//                            schedule = scheduleFetcher.schedule
//                            WidgetCenter.shared.reloadAllTimelines()
//                        }
                    }
                }.environmentObject(imageQuality)
        }
    }
    
    
    var imageQuality : ImageQuality {
        let quality = ImageQuality()
        quality.thumbnail = false
        return quality
    }
    
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
