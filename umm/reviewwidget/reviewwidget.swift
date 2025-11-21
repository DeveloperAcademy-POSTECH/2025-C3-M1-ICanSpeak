//
//  reviewwidget.swift
//  reviewwidget
//
//  Created by MINJEONG on 8/27/25.
//

import WidgetKit
import SwiftUI

// MARK: - Entry
struct SimpleEntry: TimelineEntry {
    var date: Date
} // date 없음

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // 갱신 필요 없으니 엔트리 하나만
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

// MARK: - View
struct ReviewWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
            // MARK: - Small Widget UI
        case .systemSmall:
            ZStack {
                
                Image("widgetback")
                    .offset(y: 20)
                
                VStack(alignment: .leading) {
                    Image("widgeticon")
                        .padding(.vertical, 7)
                    
                    VStack(alignment: .leading) {
                        Text("오늘")
                        Text("학습한 단어")
                    }
                    .font(.sdregular19)
                    .foregroundColor(.txt07)
                    .bold()
                    .padding(.bottom,5)
                    
                    Text("복습하기")
                        .font(.sdregular16)
                        .foregroundStyle(.txt04)
                    
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            }
            .containerBackground(for: .widget) {
                Color(.txt01)
            }
            // MARK: - Medium Widget UI
//        case .systemMedium:

        default:
            EmptyView()
      
        }
    }
}

// MARK: - Widget
struct reviewwidget: Widget {
    let kind: String = "reviewwidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ReviewWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 학습한 단어")
        .description("앱을 열어 오늘 학습했던 단어들을 다시 살펴보며 복습해 보세요")
        .supportedFamilies([.systemSmall])
    }
}
#Preview(as: .systemSmall) {
    reviewwidget()
} timeline: {
    SimpleEntry(date: Date())
}
