//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Francois Lambert on 5/20/24.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight

    var id: Self { self }

    var title: String {
        switch self {
        case .steps: return "Steps"
        case .weight: return "Weight"
        }
    }

    var tintColor: Color {
        switch self {
        case .steps: return .pink
        case .weight: return .indigo
        }
    }
}

struct DashboardView: View {

    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State var isShowingPermissionPriming = false
    @State var selectedStat: HealthMetricContext = .steps
    @State var selectedDate: Date?

    var selectedHealthMetric: HealthMetric? {
        guard let selectedDate else { return nil }

        return hkManager.stepData.first {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var avgStepCounts: Double {
        guard hkManager.stepData.isEmpty == false else { return 0 }
        let totalSteps = hkManager.stepData.map { $0.value }.reduce(0, +)
        return totalSteps / Double(hkManager.stepData.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

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

                            ForEach(hkManager.stepData) { steps in
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

                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(selectedStat.tintColor)

                            Text("Last 28 days")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                        }
                        .padding(.bottom, 12)

                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .task {
                await hkManager.fetchStepCount()
                isShowingPermissionPriming = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPriming) {
                // fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }

        }
        .tint(selectedStat.tintColor)
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
    DashboardView()
        .environment(HealthKitManager())
}
