//
//  StepBarChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import SwiftUI
import Charts

struct StepBarChart: View {

    @State var selectedDate: Date?

    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]

    var avgStepCounts: Double {
        guard chartData.isEmpty == false else { return 0 }
        let totalSteps = chartData.map { $0.value }.reduce(0, +)
        return totalSteps / Double(chartData.count)
    }

    var selectedHealthMetric: HealthMetric? {
        guard let selectedDate else { return nil }

        return chartData.first {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat){
                HStack {
                    VStack(alignment: .leading) {
                        Label("Steps", systemImage: "figure.walk")
                            .font(.title3.bold())
                            .foregroundStyle(selectedStat.tintColor)

                        Text("Avg: \(Int(avgStepCounts)) Steps")
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

            Chart {
                if let selectedHealthMetric {
                    RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart),
                                                              y: .disabled)) { annotationView }
                }

                RuleMark(y: .value("Average", avgStepCounts))
                    .foregroundStyle(.secondary)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))

                ForEach(chartData) { steps in
                    BarMark(
                        x: .value("Date", steps.date, unit: .day),
                        y: .value("Steps", steps.value)
                    )
                    .foregroundStyle(Color.pink.gradient)
                    .opacity(selectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $selectedDate.animation())
            .onChange(of: selectedDate) { oldValue, newValue in
                print(newValue ?? Date())
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)

            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 4)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )

    }
}

#Preview {
    StepBarChart(selectedStat: .steps, chartData: HealthMetric.mockData)
}
