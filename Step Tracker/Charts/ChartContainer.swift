//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/12/24.
//

import SwiftUI

struct ChartContainer<Content: View>: View {

    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            if isNav {
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
        NavigationLink(value: context) {
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
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context.tintColor)

            Text(subtitle)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
}

#Preview {
    ChartContainer(title: "Test title", symbol: "figure.walk", subtitle: "Test Subtitle", context: .steps, isNav: false) {
        Text("Chart goes here")
            .frame(height: 150)
    }
}
