//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/12/24.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Double)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar

    var title: String {
        switch self {
        case .stepBar: 
            return "Steps"
        case .stepWeekdayPie:
            return "Averages"
        case .weightLine:
            return "Weight"
        case .weightDiffBar:
            return "Average Weight Change"
        }
    }

    var symbol: String {
        switch self {
        case .stepBar: 
            return "figure.walk"
        case .stepWeekdayPie:
            return "calendar"
        case .weightLine:
            return "figure"
        case .weightDiffBar:
            return "figure"
        }
    }

    var subtitle: String {
        switch self {
        case .stepBar(let average): 
            return "Avg: \(Int(average)) Steps"
        case .stepWeekdayPie:
            return "Last 28 days"
        case .weightLine(let average):
            return "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            return "Per Weekday (Last 28 days)"
        }
    }
    var context: HealthMetricContext {
        switch self {
        case .stepBar, .stepWeekdayPie: return .steps
        case .weightDiffBar, .weightLine: return .weight
        }
    }
    
    var isNav: Bool {
        switch self {
        case .stepBar, .weightLine: return true
        case .stepWeekdayPie, .weightDiffBar: return false
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(Int(average)) steps"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine(let average):
            "Line chart, average weight: \(average.formatted(.number.precision(.fractionLength(1)))) pounds, goal weight of: 155 pounds"
        case .weightDiffBar:
            "Bar chart, average weight difference per weekday"
        }
    }
}

struct ChartContainer<Content: View>: View {
    let type: ChartType

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            if type.isNav {
                navigationLinkView
            } else {
                titleView
            }

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(
                Color(.secondarySystemBackground))
        )
    }

    var navigationLinkView: some View {
        NavigationLink(value: type.context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityHint("Tap for data in list view")
    }

    var titleView: some View {
        VStack(alignment: .leading) {
            Label(type.title, systemImage: type.symbol)
                .font(.title3.bold())
                .foregroundStyle(type.context.tintColor)

            Text(type.subtitle)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(type.accessibilityLabel)
        .accessibilityElement(children: .ignore)
    }
}

#Preview {
    ChartContainer(type: .stepBar(average: 1234)) {
        Text("Chart goes here")
            .frame(height: 150)
    }
}
