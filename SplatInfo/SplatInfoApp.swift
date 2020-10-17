//
//  SplatInfoApp.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.20.
//

import SwiftUI
import Combine
import Foundation

@main
struct SplatInfoApp: App {
    
    private let scheduleFetcher = ScheduleFetcher()
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(schedule: scheduleFetcher.schedule).onAppear {
                scheduleFetcher.fetchGameModeTimelines { (gameModeTimelines, error) in
                }
                scheduleFetcher.fetchCoopTimeline { (coopTimeline, error) in
                }
            }
        }
    }
}

struct ScheduleGrid: View {
    
    let schedule: Schedule
    
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400))
    ]

    var body: some View {
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 50) {
                    GameModeScheduleView(gameModeTimeline: schedule.gameModes.regular)
                    GameModeScheduleView(gameModeTimeline: schedule.gameModes.ranked)
                    GameModeScheduleView(gameModeTimeline: schedule.gameModes.league)
                    CoopScheduleView(coopTimeline: schedule.coop)
                }
                .padding()
            }
        }
    }
}

struct GameModeScheduleView: View {
    let gameModeTimeline : GameModeTimeline
    var body: some View {
        ZStack(alignment: .top) {
            color
            Image("splatoon-card-bg").resizable(resizingMode: .tile)
            VStack {
                if let event = gameModeTimeline.schedule.first {
                    GameModeEventView(gameModeEvent: event)
                }
            }
            .frame(minWidth: 0, idealWidth: 300, maxWidth: .infinity, minHeight: 0, idealHeight: 400, maxHeight: .infinity, alignment: .center)
        }.cornerRadius(30)

    }
    
    var color : Color {
        switch gameModeTimeline.modeType {
        case .regular:
            return Color("RegularModeColor")
        case .ranked:
            return Color("RankedModeColor")
        case .league:
            return Color("LeagueModeColor")
        }
    }
}

struct GameModeEventView: View {
    let gameModeEvent: GameModeEvent
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Image(logo)
                Text(gameModeEvent.mode.name)
                    .multilineTextAlignment(.leading)
                    .font(.largeTitle)
                Spacer()
            }

            VStack (spacing: 10) {
                HStack {
                    Text(gameModeEvent.rule.name)
                        .font(.title2)
                    Spacer()
                    Text("Date")
                }
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                    if let stage = stageA {
                        StageImage(stage: stage)
                    }
                    if let stage = stageB {
                        StageImage(stage: stage)
                    }
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
        .padding(10)
        .foregroundColor(.white)
    }
    
    var stageA : Stage? {
        return gameModeEvent.stages.first
    }
    var stageB : Stage? {
        return gameModeEvent.stages.last
    }
    var logo : String {
        switch gameModeEvent.mode.type {
        case .regular:
            return "regular-logo"
        case .league:
            return "league-logo"
        case .ranked:
            return "ranked-logo"
        }
    }
}

struct CoopScheduleView: View {
    let coopTimeline : CoopTimeline
    var body: some View {
        ZStack(alignment: .top) {
            Color("CoopModeColor")
            Image("splatoon-card-bg").resizable(resizingMode: .tile)
            VStack {
                if let event = coopTimeline.detailedSchedules.first {
//                    GameModeEventView(gameModeEvent: event)
                }
            }
            .frame(minWidth: 0, idealWidth: 300, maxWidth: .infinity, minHeight: 0, idealHeight: 400, maxHeight: .infinity, alignment: .center)
        }.cornerRadius(30)

    }
}

struct StageImage: View {
    let stage : Stage
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: URL(string: stage.imageUrl)!, placeholder: {
                Image("bg-squids").resizable(resizingMode: .tile)
            })
            .cornerRadius(10.0)
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center)

            VStack {
                Text(stage.name)
                    .font(.caption)
                    .padding(2)
            }
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
            .padding(4)
        }
    }
}


struct SplatInfoApp_Previews: PreviewProvider {
    
    let fakeSchedule = Schedule.empty
    
    static var previews: some View {
        Group {
            ScheduleGrid(schedule: Schedule.example).previewDevice(PreviewDevice(rawValue: "iPad Air 2"))
            ScheduleGrid(schedule: Schedule.example).previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}


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

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}


struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder

    init(url: URL, @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
            Group {
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    placeholder
                }
            }
        }
}
