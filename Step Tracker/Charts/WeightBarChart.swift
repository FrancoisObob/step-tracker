//
//  WeightBarChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/11/24.
//

import Charts
import SwiftUI

struct WeightBarChart: View {
    @State var selectedDate: Date?

    var chartData: [DateValueChartData]

    var selectedData: DateValueChartData? {
        chartData.selectedData(in: selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading) {
            ChartContainer(type: .weightDiffBar) {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(
                            data: selectedData, context: .weight)
                    }

                    ForEach(chartData) { weightDiff in
                        Plot {
                            BarMark(
                                x: .value("Date", weightDiff.date, unit: .day),
                                y: .value("Weights", weightDiff.value)
                            )
                            .foregroundStyle(
                                weightDiff.value >= 0
                                ? HealthMetricContext.weight.tintColor
                                    .gradient
                                : Color.mint.gradient
                            )
                            .opacity(selectedData == nil || weightDiff.date == selectedData?.date ? 1.0 : 0.3)
                        }
                        .accessibilityLabel(weightDiff.date.weekdayTitle)
                        .accessibilityValue("\(weightDiff.value.formatted()) pounds")
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(
                            format: .dateTime.weekday(), centered: true)
                    }

                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel(
                            (value.as(Double.self) ?? 0).formatted(
                                .number.notation(.compactName)))
                    }
                }
                .overlay {
                    if chartData.isEmpty {
                        ChartEmptyView(
                            systemImageName: "chart.bar",
                            title: "No Data",
                            description:
                                "There is no weight data found in Health app.")
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDate?.weekdayInt)
    }
}

#Preview {
    WeightBarChart(chartData: MockData.weights.averageDailyWeightDiffsData)
}
