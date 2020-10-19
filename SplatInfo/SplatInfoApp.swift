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
    @State var schedule = Schedule.empty
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(schedule: schedule).onAppear {
                scheduleFetcher.fetchGameModeTimelines { (gameModeTimelines, error) in
                    schedule = scheduleFetcher.schedule
                }
                scheduleFetcher.fetchCoopTimeline { (coopTimeline, error) in
                    schedule = scheduleFetcher.schedule
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
                    GameModeTimelineView(timeline: .gameModeTimeline(timeline: schedule.gameModes.regular))
                    GameModeTimelineView(timeline: .gameModeTimeline(timeline: schedule.gameModes.ranked))
                    GameModeTimelineView(timeline: .gameModeTimeline(timeline: schedule.gameModes.league))
                    GameModeTimelineView(timeline: .coopTimeline(timeline: schedule.coop))
                }
                .padding()
            }
        }
    }
}


struct GameModeTimelineView: View {
    
    public enum TimelineType {
        case gameModeTimeline(timeline: GameModeTimeline)
        case coopTimeline(timeline: CoopTimeline)
    }
    
    let timeline : TimelineType
    
    var body: some View {
        ZStack(alignment: .top) {
            color
            bgImage
            VStack {
                switch timeline {
                case .gameModeTimeline(timeline: let timeline):
                    if let event = timeline.schedule.first {
                        GameModeEventView(gameModeEvent: event)
                    }
                case .coopTimeline(timeline: let timeline):
                    CoopEventView(coopTimeline: timeline)
                }
            }
            .frame(minWidth: 0, idealWidth: 300, maxWidth: .infinity, minHeight: 0, idealHeight: 400, maxHeight: .infinity, alignment: .center)
        }.cornerRadius(30)

    }
    
    var color : Color {
        switch timeline {
        case .gameModeTimeline(timeline: let timeline):
            switch timeline.modeType {
            case .regular:
                return Color("RegularModeColor")
            case .ranked:
                return Color("RankedModeColor")
            case .league:
                return Color("LeagueModeColor")
            }
        case .coopTimeline(timeline: let timeline):
            return Color("CoopModeColor")
        }
    }
    
    var bgImage : Image {
        switch timeline {
        case .gameModeTimeline(timeline: let timeline):
            return Image("splatoon-card-bg").resizable(resizingMode: .tile)
        case .coopTimeline(timeline: let timeline):
            return Image("bg-spots").resizable(resizingMode: .tile)
        }
    }
}

struct CoopEventView: View {
    let coopTimeline: CoopTimeline
    
    var body: some View {
        VStack {
            TitleView(title: "Salmon Run", logoName: "mr-grizz-logo")
            ForEach(coopTimeline.detailedSchedules, id: \.id) { detail in
                CoopEventDetailsView(details: detail)
            }
        }
        .padding(10)
        .foregroundColor(.white)
    }
}

struct CoopEventDetailsView: View {
    let details : CoopEventDetail
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Open or Soon")
                Text("Time remaining")
            }
            TimeframeView(timeframe: details.timeframe, datesEnabled: true)
            HStack {
                if let stage = details.stage {
                    StageImage(stage: stage)
                }
                VStack {
                    Text("Available Weapons")
                    LazyVGrid(columns: columns, content: {
                        ForEach(weapons, id: \.id) { item in
                            AsyncImage(url: URL(string: item.imageUrl)!) {
                                Text("*")
                            } image: { (uiImage) in
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    })
                }
            }
        }
    }
        

    var weapons : [WeaponDetails] {
        var weaponDetails : [WeaponDetails] = []
        for weapon in details.weapons {
            switch weapon {
            case .weapon(details: let details):
                weaponDetails.append(details)
            case .coopSpecialWeapon(details: let details):
                weaponDetails.append(details)
            }
        }
        return weaponDetails
    }
}

struct TimeframeView: View {
    let timeframe: EventTimeframe
    var datesEnabled: Bool = false

    var body: some View {
        Text(timeframeString)
    }

    var timeframeString : String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = datesEnabled ? .short : .none
        dateFormatter.timeStyle = .short
        let startString = dateFormatter.string(from: timeframe.startDate)
        let endString = dateFormatter.string(from: timeframe.endDate)
        return "\(startString) - \(endString)"
    }
}

struct TitleView: View {
    let title: String
    let logoName: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40)
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.largeTitle)
            Spacer()
        }
    }
}

struct GameModeEventView: View {
    let gameModeEvent: GameModeEvent
    
    var body: some View {
        VStack {
            TitleView(title: gameModeEvent.mode.name, logoName: logo)

            VStack (spacing: 10) {
                HStack {
                    Text(gameModeEvent.rule.name)
                        .font(.title2)
                    Spacer()
                    TimeframeView(timeframe: gameModeEvent.timeframe)
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

struct StageImage: View {
    let stage : Stage
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: URL(string: stage.imageUrl)!) {
                Image("bg-squids").resizable(resizingMode: .tile)
            } image: { (uiImage) in
                Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit)
            }
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
        }.aspectRatio(16/10, contentMode: .fit)
    }
}


struct SplatInfoApp_Previews: PreviewProvider {
    
    static let exampleSchedule = Schedule.example
    
    static var previews: some View {
        Group {
            ScheduleGrid(schedule: exampleSchedule).previewDevice(PreviewDevice(rawValue: "iPad Air 2"))
            ScheduleGrid(schedule: exampleSchedule).previewDevice(PreviewDevice(rawValue: "iPhone SE"))
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
