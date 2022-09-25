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
//    @State var splatoon2Schedule = Splatoon2.Schedule.empty
//    @State var splatoon3Schedule = Splatoon3.Schedule.empty
    let imageLoaderManager = ImageLoaderManager()
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(splatoon2Schedule: $scheduleFetcher.splatoon2Schedule, splatoon3Schedule: $scheduleFetcher.splatoon3Schedule)
                .onAppear {

                    // test example
//                    let coopEvent = Schedule.example.coop.detailedEvents.first
//                    print("CoopEvent: \(coopEvent)")
                    
                    scheduleFetcher.fetchSplatoon2Schedule { result in
                        WidgetCenter.shared.reloadAllTimelines()
                        switch result {
                        case .success(let success):
//                            self.splatoon2Schedule = scheduleFetcher.splatoon2Schedule
                            downloadImages(urls: success.allImageURLs(), asJPEG: true) {
                                print("Splatoon2 Images downloaded")
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
//                            self.splatoon3Schedule = scheduleFetcher.splatoon3Schedule
                            downloadImages(urls: success.coop.allImageURLs(), asJPEG: true) {
                                print("Splatoon 3 Images downloaded")
                            }
                            downloadImages(urls: success.coop.allWeaponImageURLs(), asJPEG: false) {
                                print("Weapons downloaded")
                            }
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
//                    scheduleFetcher.fetchGameModeTimelines { (gameModeTimelines, error) in
//                        schedule = scheduleFetcher.schedule
//                        WidgetCenter.shared.reloadAllTimelines()
//                        guard let timelines = gameModeTimelines else { return }
////                        let urls = [timelines.ranked.allImageURLs(),timelines.turfWar.allImageURLs(),timelines.league.allImageURLs()].flatMap({ $0 })
////                        downloadImages(urls: urls) {
////                            schedule = scheduleFetcher.schedule
////                            WidgetCenter.shared.reloadAllTimelines()
////                        }
//                    }
//                    scheduleFetcher.fetchCoopTimeline { (coopTimeline, error) in
//                        schedule = scheduleFetcher.schedule
//                        WidgetCenter.shared.reloadAllTimelines()
////                        guard let timeline = coopTimeline else { return }
////                        let stageURLs = timeline.allStageImageURLs()
////                        downloadImages(urls: stageURLs) {
////                            WidgetCenter.shared.reloadAllTimelines()
////                        }
////                        let weaponURLs = timeline.allWeaponImageURLs()
////                        downloadImages(urls: weaponURLs, asJPEG: false) {
////                            schedule = scheduleFetcher.schedule
////                            WidgetCenter.shared.reloadAllTimelines()
////                        }
//                    }
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
