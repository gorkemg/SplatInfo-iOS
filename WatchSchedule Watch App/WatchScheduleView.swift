//
//  ContentView.swift
//  WatchSchedule Watch App
//
//  Created by Görkem Güclü on 02.10.22.
//

import SwiftUI
import WidgetKit

struct WatchScheduleView: View {
    
    @ObservedObject private var scheduleFetcher = ScheduleFetcher()
    private let imageLoaderManager = ImageLoaderManager()
    private let screenWidth = WKInterfaceDevice.current().screenBounds.width * WKInterfaceDevice.current().screenScale
    private let screenScale = WKInterfaceDevice.current().screenScale
        

    func updateSchedules() {
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.updateSchedules {
            downloadImages(urls: scheduleFetcher.splatoon2Schedule.allImageURLs(), asJPEG: true, resizeOption: .resizeToWidth(screenWidth)) {
                print("Splatoon2 Images downloaded")
                downloadImages(urls: scheduleFetcher.splatoon2Schedule.coop.allWeaponImageURLs(), asJPEG: false, resizeOption: .resizeToWidth(64.0)) {
                    print("Weapons downloaded")
                    WidgetCenter.shared.reloadTimelines(ofKind: kindWatchSplatoon2ScheduleWidgets)
                    print("Splatoon 2 Update finished")
                }
            }
            downloadImages(urls: scheduleFetcher.splatoon3Schedule.allImageURLs(), asJPEG: true, resizeOption: .resizeToWidth(screenWidth)) {
                print("Splatoon 3 Images downloaded")
                downloadImages(urls: scheduleFetcher.splatoon3Schedule.coop.allWeaponImageURLs(), asJPEG: false, resizeOption: .resizeToWidth(64.0)) {
                    print("Weapons downloaded")
                    WidgetCenter.shared.reloadTimelines(ofKind: kindWatchSplatoon3ScheduleWidgets)
                    print("Splatoon 3 Update finished")
                }
            }
        }
    }
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 4.0){
                    NavigationLink(destination: Splatoon3TimelinesView(schedule: $scheduleFetcher.splatoon3Schedule, date: Date())) {
                        Image("Splatoon3_number_icon").frame(height: geo.size.height/2)
                    }
                    NavigationLink(destination: Splatoon2TimelinesView(schedule: $scheduleFetcher.splatoon2Schedule, date: Date())) {
                        Image("Splatoon2_number_icon").frame(height: geo.size.height/2)
                    }
                }
            }
        }
        .onAppear {
            print("Appeared")
            print("Device Screen size: \(WKInterfaceDevice.current().screenBounds) @ \(screenScale)")
            updateSchedules()
        }
    }
    
    func downloadImages(urls: [URL], asJPEG: Bool = true, resizeOption: MultiImageLoader.ResizeOption? = nil, completion: @escaping ()->Void) {
        let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let multiImageLoader = MultiImageLoader(urls: urls, directory: destination)
        multiImageLoader.storeAsJPEG = asJPEG
        multiImageLoader.resizeOption = resizeOption
        imageLoaderManager.imageLoaders.append(multiImageLoader)
        multiImageLoader.load {
            completion()
        }
    }
}

class TimelineUpdater: ObservableObject {

    @State var id = UUID().uuidString
    @Published var updatedDate: Date = Date()
    private var timer: Timer? = nil
    

    func startTimer(timerFired: @escaping ()->Void) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            print("Timer fired")
            self.updatedDate = Date.now
            self.id = UUID().uuidString
            timerFired()
        })
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

struct Splatoon3TimelinesView: View {
    
    @Binding var schedule: Splatoon3.Schedule
    var date: Date

    @State private var selectedPage: Splatoon3.GameModeType = .turfWar

    var timelineTypes: [Splatoon3.TimelineType] {
        let turfWar = Splatoon3.TimelineType.game(mode: .turfWar, timeline: schedule.regular)
        let aOpen = Splatoon3.TimelineType.game(mode: .anarchyBattleOpen, timeline: schedule.anarchyBattleOpen)
        let aSeries = Splatoon3.TimelineType.game(mode: .anarchyBattleSeries, timeline: schedule.anarchyBattleSeries)
//        let league = Splatoon3.TimelineType.game(mode: .league, timeline: schedule.league)
        let x = Splatoon3.TimelineType.game(mode: .x, timeline: schedule.x)
        let salmonRun = Splatoon3.TimelineType.coop(timeline: schedule.coopWithBigRun)
        return [turfWar,aOpen,aSeries,/*league,*/x,salmonRun]
    }
    
    var body: some View {
                
        ZStack(alignment: .bottom){
            TabView(selection: $selectedPage) {
                ForEach(timelineTypes, id:\.self) { timelineType in
                    switch timelineType {
                    case .game(let mode, let timeline):
                        GameSmallTimelineView(gameModeTimeline: GameModeTimeline(mode: .splatoon3(type: mode), timeline: timeline), date: date)
                            .tag(timelineType.modeType)
                    case .coop(let timeline):
                        CoopSmallTimelineView(timeline: timeline)
                            .tag(timelineType.modeType)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack(alignment: .center){
                Spacer()
                HStack(alignment: .bottom, spacing: 1.0) {
                    ForEach(0..<timelineTypes.count, id: \.self) { index in
                        let timelineType = timelineTypes[index]
                        Button {
                            withAnimation {
                                selectedPage = timelineType.modeType
                            }
                        } label: {
                            if timelineType.modeType == selectedPage {
                                VStack(alignment: .center) {
                                    if timelineType.modeType == .anarchyBattleOpen {
                                        Splatoon3TagView(text: "Open")
                                    }else if timelineType.modeType == .anarchyBattleSeries {
                                        Splatoon3TagView(text: "Series")
                                    }else{
                                        Image(timelineType.modeType.logoNameSmall)
                                            .resizable().aspectRatio(contentMode: .fit).frame(width: 24)
                                            .scaleEffect(1.2)
                                    }
                                }
                            }else{
                                Image(timelineType.modeType.logoNameSmall)
                                    .resizable().aspectRatio(contentMode: .fit).frame(width: 24)
                                    .saturation(0.0).opacity(0.8).scaleEffect(0.8)

                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .environmentObject(eventViewSettings)
        .navigationTitle("Splatoon 3")
    }
    
    var eventViewSettings : EventViewSettings = {
        let quality = EventViewSettings()
        quality.settings.useThumbnailQuality = true
        return quality
    }()
}

struct Splatoon2TimelinesView: View {
    
    @Binding var schedule: Splatoon2.Schedule
    var date: Date
    @State private var selectedPage: Splatoon2.GameModeType = .turfWar

    var modes: [Splatoon2.TimelineType] {
        let turfWar = Splatoon2.TimelineType.game(mode: .turfWar, timeline: schedule.regular)
        let ranked = Splatoon2.TimelineType.game(mode: .ranked, timeline: schedule.ranked)
        let league = Splatoon2.TimelineType.game(mode: .league, timeline: schedule.league)
        let salmonRun = Splatoon2.TimelineType.coop(timeline: schedule.coop)
       return [turfWar,ranked,league,salmonRun]
    }

    var body: some View {
        
        ZStack(alignment: .bottom){
            TabView(selection: $selectedPage) {
                ForEach(modes, id:\.self) { mode in
                    switch mode {
                    case .game(let gameMode, let timeline):
                        GameSmallTimelineView(gameModeTimeline: GameModeTimeline(mode: .splatoon2(type: gameMode), timeline: timeline), date: date).tag(mode.modeType)
                    case .coop(let timeline):
                        CoopSmallTimelineView(timeline: timeline).tag(mode.modeType)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack(alignment: .center){
                Spacer()
                Text(date, style: .relative)
                    .splat2Font(size: 9)
                    .drawingGroup()
                HStack(alignment: .bottom, spacing: 1.0) {
                    ForEach(0..<modes.count, id: \.self) { index in
                        let mode = modes[index]
                        Button {
                            withAnimation {
                                selectedPage = mode.modeType
                            }
                        } label: {
                            if mode.modeType == selectedPage {
                                Image(mode.modeType.logoNameSmall)
                                    .resizable().aspectRatio(contentMode: .fit).frame(width: 24)
                                    .scaleEffect(1.2)
                            }else{
                                Image(mode.modeType.logoNameSmall)
                                    .resizable().aspectRatio(contentMode: .fit).frame(width: 24)
                                    .saturation(0.0).opacity(0.8).scaleEffect(0.8)

                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .environmentObject(eventViewSettings)
        .navigationTitle("Splatoon 2")
    }
    
    var eventViewSettings : EventViewSettings = {
        let quality = EventViewSettings()
        quality.settings.useThumbnailQuality = true
        return quality
    }()
}

struct GameSmallTimelineView: View {
    
    let gameModeTimeline: GameModeTimeline
    
    var nextEvent: GameModeEvent? = nil
    let date: Date

    func nextEvent(for event: GameModeEvent) -> GameModeEvent? {
        if let index = gameModeTimeline.timeline.events.firstIndex(of: event) {
            return gameModeTimeline.timeline.events[safe: index+1]
        }
        return nil
    }
    
    var body: some View {
        let events: [GameModeEvent] = gameModeTimeline.timeline.events
        if(events.isEmpty) {
            Text("Events not available: \(events.count)")
                .splat2Font(size: 20)
        }else{
            GeometryReader { geo in
                List(events) { event in

                    GameModeEventView(gameMode: gameModeTimeline.mode, event: event, showTimeframe: true, style: .topBottom, date: Date())
                        .frame(width: geo.size.width, height: geo.size.height)
                        .listRowInsets(EdgeInsets())
                        .cornerRadius(20)
                        .drawingGroup()
                }
                .padding(0)
                .environment(\.defaultMinListRowHeight, geo.size.height)
                .listStyle(.carousel)
            }
            .padding(0)
            .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct CoopSmallTimelineView: View {
    
    let timeline: CoopTimeline
    
    var body: some View {
        let events: [CoopEvent] = timeline.events
        if(events.isEmpty) {
            Text("Events not available: \(events.count)")
                .splat2Font(size: 20)
        }else{
            GeometryReader { geo in
                List(events) { event in

                    CoopTopBottomEventView(event: event, state: event.timeframe.state(date: Date()))
                        .frame(width: geo.size.width, height: geo.size.height)
                        .listRowInsets(EdgeInsets())
                        .cornerRadius(20)
                        .drawingGroup()
                }
                .padding(0)
                .environment(\.defaultMinListRowHeight, geo.size.height)
                .listStyle(.carousel)
            }
            .padding(0)
            .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    @State static var exampleSchedule2 = Splatoon2.Schedule.example
    @State static var exampleSchedule3 = Splatoon3.Schedule.example

    static var previews: some View {
        WatchScheduleView()
            .previewDisplayName("Start")
        Splatoon2TimelinesView(schedule: $exampleSchedule2, date: Date())
            .previewDisplayName("Splatton 2")
        Splatoon3TimelinesView(schedule: $exampleSchedule3, date: Date())
            .previewDisplayName("Splatoon 3")
    }
}
