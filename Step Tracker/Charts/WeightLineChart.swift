//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/11/24.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    var selectedStat: HealthMetricContext

    var chartData: [HealthMetric]

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat){
                HStack {
                    VStack(alignment: .leading) {
                        Label("Weight", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(selectedStat.tintColor)

                        Text("Avg: 180 lbs")
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

            Chart {
                ForEach(chartData) { weight in
                    AreaMark(
                        x: .value("Day", weight.date, unit: .day),
                        y: .value("Value", weight.value)
                    )
                    .foregroundStyle(Gradient(colors: [selectedStat.tintColor.opacity(0.5), .clear]))

                    LineMark(
                        x: .value("Day", weight.date, unit: .day),
                        y: .value("Value", weight.value)
                    )
                    .foregroundStyle(selectedStat.tintColor)
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
