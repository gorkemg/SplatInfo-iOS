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
                    
                    scheduleFetcher.updateSchedules {

                        downloadImages(urls: scheduleFetcher.splatoon2Schedule.allImageURLs(), asJPEG: true) {
                            print("Splatoon2 Images downloaded")
                            downloadImages(urls: scheduleFetcher.splatoon2Schedule.coop.allWeaponImageURLs(), asJPEG: false) {
                                print("Weapons downloaded")
                                WidgetCenter.shared.reloadTimelines(ofKind: kindSplatoon2ScheduleWidget)
                            }
                        }
                        downloadImages(urls: scheduleFetcher.splatoon3Schedule.coop.allImageURLs(), asJPEG: true) {
                            print("Splatoon 3 Images downloaded")
                            downloadImages(urls: scheduleFetcher.splatoon3Schedule.coop.allWeaponImageURLs(), asJPEG: false) {
                                print("Weapons downloaded")
                                WidgetCenter.shared.reloadTimelines(ofKind: kindSplatoon3ScheduleWidget)
                            }
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
    
    func testScheduleUpdate() {
        
        let currentSchedule = scheduleFetcher.splatoon2Schedule
        let changingDates = currentSchedule.eventChangingDates()
        for date in changingDates {
            print("Schedule for date: \(date)")
            let schedule = currentSchedule.upcomingSchedule(after: date)
            print(schedule)
        }
    }
}

struct Previews_SplatInfoApp_Previews: PreviewProvider {
    
    let scheduleFetcher = ScheduleFetcher()
    @State static var exampleSchedule = Splatoon2.Schedule.example
    @State static var exampleSchedule3 = Splatoon3.Schedule.example
    
    static var previews: some View {
        
        ScheduleGrid(splatoon2Schedule: $exampleSchedule, splatoon3Schedule: $exampleSchedule3)
    }
}
