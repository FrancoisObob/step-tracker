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
            ChartContainer(
                title: "Average Weight Change",
                symbol: "figure",
                subtitle: "Per Weekday (Last 28 days)",
                context: .weight,
                isNav: false
            ) {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.bar",
                        title: "No Data",
                        description:
                            "There is no weight data found in Health app.")
                } else {
                    Chart {
                        if let selectedData {
                            RuleMark(
                                x: .value(
                                    "Selected Weekday", selectedData.date,
                                    unit: .day)
                            )
                            .foregroundStyle(.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(
                                position: .top,
                                spacing: 0,
                                overflowResolution: .init(
                                    x: .fit(to: .chart),
                                    y: .disabled)
                            ) {
                                ChartAnnotationView(
                                    data: selectedData,
                                    context: .weight)
                            }
                        }

                        ForEach(chartData) { weightDiff in
                            BarMark(
                                x: .value("Date", weightDiff.date, unit: .day),
                                y: .value("Weights", weightDiff.value)
                            )
                            .foregroundStyle(
                                weightDiff.value >= 0
                                ? HealthMetricContext.weight.tintColor.gradient
                                    : Color.mint.gradient
                            )
                            .opacity(
                                selectedData == nil
                                    || weightDiff.date == selectedData?.date
                                    ? 1.0 : 0.3)
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
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDate?.weekdayInt)
    }
}

#Preview {
    WeightBarChart(chartData: MockData.weights.averageDailyWeightDiffsData)
}
