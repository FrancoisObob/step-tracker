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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)


                    switch selectedStat {
                    case .steps:
                        StepBarChart(selectedStat: selectedStat,
                                     chartData: hkManager.stepData)

                        StepPieChart(selectedStat: selectedStat,
                                     chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData) )
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat,
                                        chartData: hkManager.weightData)
                    }

                }
            }
            .padding()
            .task {
//                await hkManager.addSimulatorData()
                await hkManager.fetchStepCount()
                await hkManager.fetchWeights()
                ChartMath.averageDailyWeightDiffs(for: hkManager.weightData)
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
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
