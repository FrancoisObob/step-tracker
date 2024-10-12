//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/12/24.
//

import SwiftUI

struct ChartContainerConfiguration {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
}

struct ChartContainer<Content: View>: View {
    let config: ChartContainerConfiguration

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            if config.isNav {
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
        NavigationLink(value: config.context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }

    var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context.tintColor)

            Text(config.subtitle)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
}

#Preview {
    ChartContainer(config: ChartContainerConfiguration(title: "Test title", symbol: "figure.walk", subtitle: "Test Subtitle", context: .steps, isNav: false)) {
        Text("Chart goes here")
            .frame(height: 150)
    }
}
