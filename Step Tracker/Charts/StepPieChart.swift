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
    @State private var lastSelectedValue: Double = 0
    var chartData: [DateValueChartData]

    var selectedWeekday: DateValueChartData? {
        var total = 0.0
        return chartData.first {
            total += $0.value
            return lastSelectedValue <= total
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ChartContainer(type: .stepWeekdayPie) {
                Chart {
                    ForEach(chartData) { weekday in
                        SectorMark(
                            angle: .value("Average Steps", weekday.value),
                            innerRadius: .ratio(0.618),
                            outerRadius: (selectedWeekday?.date.weekdayInt
                                == weekday.date.weekdayInt) ? 140 : 110,
                            angularInset: 1
                        )
                        .foregroundStyle(
                            HealthMetricContext.steps.tintColor.gradient
                        )
                        .cornerRadius(5)
                        .opacity(
                            (selectedWeekday?.date.weekdayInt
                                == weekday.date.weekdayInt) ? 1 : 0.5)
                    }
                }
                .chartAngleSelection(value: $selectedChartValue)
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geometry in
                        if proxy.plotFrame != nil {
                            let frame = geometry.frame(in: .local)
                            if let selectedWeekday {
                                VStack {
                                    Text(selectedWeekday.date.weekdayTitle)
                                        .font(.title3.bold())
                                        .animation(.none)

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
                .overlay {
                    if chartData.isEmpty {
                        ChartEmptyView(
                            systemImageName: "chart.pie",
                            title: "No Data",
                            description:
                                "There is no step count data found in Health app."
                        )
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedWeekday?.date.weekdayInt)
        .onChange(of: selectedChartValue ?? -1) { oldValue, newValue in
            withAnimation(.easeInOut) {
                if newValue == -1 {
                    lastSelectedValue = oldValue
                } else {
                    lastSelectedValue = newValue
                }
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: MockData.steps.averageWeekdayCountData)
}
