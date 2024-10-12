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
    @State private var isShowingPermissionPriming = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isPresentingHealthKitPermissionAlert: Bool = false
    @State private var fetchError: STError = .noData

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
                                     chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat,
                                        chartData: hkManager.weightData)

                        WeightBarChart(selectedStat: selectedStat,
                                       chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightData))
                    }

                }
            }
            .padding()
            .task {
                do {
                    // await hkManager.addSimulatorData()

                    // Make this concurrent
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()

                } catch STError.authNotDetermined {
                    isShowingPermissionPriming = true
                } catch STError.noData {
                    fetchError = .noData
                    isPresentingHealthKitPermissionAlert = true
                } catch {
                    fetchError = .unableToCompleteRequest
                    isPresentingHealthKitPermissionAlert = true
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPriming) {
                // fetch health data
            } content: {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $isPresentingHealthKitPermissionAlert,
                   error: fetchError) { fetchError in
                // Actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(selectedStat.tintColor)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
