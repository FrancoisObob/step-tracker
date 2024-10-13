//
//  ChartEmptyView.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/12/24.
//

import SwiftUI

struct ChartEmptyView: View {
    let systemImageName: String
    let title: String
    let description: String

    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(8)

            Text(title)
                .font(.callout.bold())

            Text(description)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    ChartEmptyView(
        systemImageName: "chart.bar", title: "No Data",
        description: "There is no step count data from the Health app.")
}
