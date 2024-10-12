//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Charts
import SwiftUI

struct StepPieChart: View {

    @State private var selectedChartValue: Double? = 0

    var chartData: [DateValueChartData]

    var selectedWeekday: DateValueChartData? {
        guard let selectedChartValue else { return nil }
        var total = 0.0
        return chartData.first {
            total += $0.value
            return selectedChartValue <= total
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            let config = ChartContainerConfiguration(
                title: "Averages",
                symbol: "calendar",
                subtitle: "Last 28 days",
                context: .steps,
                isNav: false)

            ChartContainer(config: config) {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.pie",
                        title: "No Data",
                        description:
                            "There is no step count data found in Health app.")
                } else {
                    Chart {
                        ForEach(chartData) { weekday in
                            SectorMark(
                                angle: .value("Average Steps", weekday.value),
                                innerRadius: .ratio(0.618),
                                outerRadius: (selectedWeekday?.date.weekdayInt
                                              == weekday.date.weekdayInt) ? 140 : 110,
                                angularInset: 1
                            )
                            .foregroundStyle(HealthMetricContext.steps.tintColor.gradient)
                            .cornerRadius(5)
                            .opacity(
                                (selectedWeekday?.date.weekdayInt
                                 == weekday.date.weekdayInt) ? 1 : 0.5)
                        }
                    }
                    .chartAngleSelection(
                        value: $selectedChartValue.animation(.easeInOut)
                    )
                    .frame(height: 240)
                    .chartBackground { proxy in
                        GeometryReader { geometry in
                            if proxy.plotFrame != nil {
                                let frame = geometry.frame(in: .local)
                                if let selectedWeekday {
                                    VStack {
                                        Text(selectedWeekday.date.weekdayTitle)
                                            .font(.title3.bold())
                                            .animation(nil)

                                        Text(
                                            selectedWeekday.value,
                                            format: .number.precision(
                                                .fractionLength(0))
                                        )
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                    }
                                    .position(x: frame.midX, y: frame.midY)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedWeekday?.date.weekdayInt)
        .onChange(of: selectedChartValue) { oldValue, newValue in
            if newValue == nil {
                selectedChartValue = oldValue
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: MockData.steps.averageWeekdayCountData)
}
