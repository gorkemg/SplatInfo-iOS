//
//  ContentView.swift
//  WatchSchedule Watch App
//
//  Created by Görkem Güclü on 02.10.22.
//

import SwiftUI

struct WatchScheduleView: View {
    
    @ObservedObject private var scheduleFetcher = ScheduleFetcher()
    let imageLoaderManager = ImageLoaderManager()

    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                VStack(alignment: .center, spacing: 4.0){
                    NavigationLink(destination: Splatoon3TimelinesView(schedule: $scheduleFetcher.splatoon3Schedule)) {
                        Image("Splatoon3_number_icon").frame(height: geo.size.height/2)
                    }
                    NavigationLink(destination: Splatoon2TimelinesView(schedule: $scheduleFetcher.splatoon2Schedule)) {
                        Image("Splatoon2_number_icon").frame(height: geo.size.height/2)
                    }
                }
            }
        }
        .onAppear {
            print("Appeared")
            scheduleFetcher.fetchSplatoon2Schedule { result in

                switch result {
                case .success(let success):
                    downloadImages(urls: success.allImageURLs(), asJPEG: true) {
                        print("Splatoon2 Images downloaded")
                    }
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            scheduleFetcher.fetchSplatoon3Schedule { result in

                switch result {
                case .success(let success):
                    downloadImages(urls: success.coop.allImageURLs(), asJPEG: true) {
                        print("Splatoon 3 Images downloaded")
                        downloadImages(urls: success.coop.allWeaponImageURLs(), asJPEG: false) {
                            print("Weapons downloaded")
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
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


struct Splatoon3TimelinesView: View {
    
    @Binding var schedule: Splatoon3.Schedule
    @State private var selectedPage: Splatoon3.GameModeType = .turfWar

    var timelineTypes: [Splatoon3.TimelineType] {
        let turfWar = Splatoon3.TimelineType.game(mode: .turfWar, timeline: schedule.regular)
        let aOpen = Splatoon3.TimelineType.game(mode: .anarchyBattleOpen, timeline: schedule.anarchyBattleOpen)
        let aSeries = Splatoon3.TimelineType.game(mode: .anarchyBattleSeries, timeline: schedule.anarchyBattleSeries)
//        let league = Splatoon3.TimelineType.game(mode: .league, timeline: schedule.league)
//        let x = Splatoon3.TimelineType.game(mode: .x, timeline: schedule.x)
        let salmonRun = Splatoon3.TimelineType.coop(timeline: schedule.coop)
        return [turfWar,aOpen,aSeries,/*league,x,*/salmonRun]
    }
    
    var body: some View {
                
        ZStack(alignment: .bottom){
            TabView(selection: $selectedPage) {
                ForEach(timelineTypes, id:\.self) { timelineType in
                    switch timelineType {
                    case .game(_, let timeline):
                        GameSmallTimelineView(timeline: timeline).tag(timelineType.modeType)
                    case .coop(let timeline):
                        CoopSmallTimelineView(timeline: timeline).tag(timelineType.modeType)
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
            .edgesIgnoringSafeArea(.vertical)
        }
        .environmentObject(imageQuality)
    }
    
    var imageQuality : ImageQuality = {
        let quality = ImageQuality()
        quality.thumbnail = true
        return quality
    }()
}

struct Splatoon2TimelinesView: View {
    
    @Binding var schedule: Splatoon2.Schedule
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
                    case .game(_, let timeline):
                        GameSmallTimelineView(timeline: timeline).tag(mode.modeType)
                    case .coop(let timeline):
                        CoopSmallTimelineView(timeline: timeline).tag(mode.modeType)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack(alignment: .center){
                Spacer()
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
            .edgesIgnoringSafeArea(.vertical)
        }
        .environmentObject(imageQuality)
    }
    
    var imageQuality : ImageQuality = {
        let quality = ImageQuality()
        quality.thumbnail = true
        return quality
    }()
}

struct GameSmallTimelineView: View {
    
    let timeline: GameTimeline
    
    var nextEvent: GameModeEvent? = nil
    let date: Date = Date()

    func nextEvent(for event: GameModeEvent) -> GameModeEvent? {
        if let index = timeline.events.firstIndex(of: event) {
            return timeline.events[safe: index+1]
        }
        return nil
    }
    
    var body: some View {
        let events: [GameModeEvent] = timeline.events
        if(events.isEmpty) {
            Text("Events not available: \(events.count)")
                .splat2Font(size: 20)
        }else{
            GeometryReader { geo in
                List(events) { event in

                    GameModeEventView(event: event, /*nextEvent: nextEvent(for: event),*/ showTimeframe: true, style: .topBottom, date: Date())
                        .frame(width: geo.size.width, height: geo.size.height)
                        .listRowInsets(EdgeInsets())
                        .cornerRadius(20)
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
        Splatoon2TimelinesView(schedule: $exampleSchedule2)
        Splatoon3TimelinesView(schedule: $exampleSchedule3)
    }
}
