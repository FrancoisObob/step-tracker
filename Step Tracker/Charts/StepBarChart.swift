//
//  StepBarChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Charts
import SwiftUI

struct StepBarChart: View {

    @State private var selectedDate: Date?

    var chartData: [DateValueChartData]

    var selectedData: DateValueChartData? {
        chartData.selectedData(in: selectedDate)
    }

    var body: some View {
        ChartContainer(
            title: "Steps",
            symbol: "figure.walk",
            subtitle: "Avg: \(Int(chartData.avgStepCounts)) Steps",
            context: .steps,
            isNav: true
        ) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.bar", title: "No Data",
                    description:
                        "There is no step count data found in Health app.")

            } else {
                Chart {
                    if let selectedData {
                        RuleMark(
                            x: .value(
                                "Selected Metric", selectedData.date,
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
                                context: .steps)
                        }
                    }

                    RuleMark(y: .value("Average", chartData.avgStepCounts))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))

                    ForEach(chartData) { steps in
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(HealthMetricContext.steps.tintColor)
                        .opacity(
                            selectedDate == nil
                                || steps.date == selectedData?.date
                                ? 1.0 : 0.3)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate.animation())
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
                        AxisValueLabel(
                            (value.as(Double.self) ?? 0).formatted(
                                .number.notation(.compactName)))
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDate?.weekdayInt)
    }
}

#Preview {
    StepBarChart(chartData: MockData.steps.chartData)
}
