//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/11/24.
//

import Charts
import SwiftUI

struct WeightLineChart: View {
    @State var selectedDate: Date?

    var chartData: [DateValueChartData]

    var selectedData: DateValueChartData? {
        chartData.selectedData(in: selectedDate)
    }

    var body: some View {
        VStack {
            ChartContainer(type: .weightLine(average: chartData.average)) {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(
                            data: selectedData, context: .weight)
                    }

                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)

                    ForEach(chartData) { weight in
                        Plot {
                            AreaMark(
                                x: .value("Day", weight.date, unit: .day),
                                yStart: .value("Value", weight.value),
                                yEnd: .value("Min Value", chartData.minValue)
                            )
                            .foregroundStyle(
                                Gradient(colors: [
                                    HealthMetricContext.weight.tintColor.opacity(
                                        0.5), .clear,
                                ])
                            )
                            .interpolationMethod(.catmullRom)

                            LineMark(
                                x: .value("Day", weight.date, unit: .day),
                                y: .value("Value", weight.value)
                            )
                            .foregroundStyle(HealthMetricContext.weight.tintColor)
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)
                        }
                        .accessibilityLabel(weight.date.accessibilityDate)
                        .accessibilityValue("\(weight.value.formatted(.number.precision(.fractionLength(1)))) pounds")
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(
                            format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel()
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
    WeightLineChart(chartData: MockData.weights.chartData)
}
