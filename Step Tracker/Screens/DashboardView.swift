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

    var fractionLength: Int {
        switch self {
        case .steps: 0
        case .weight: 1
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
                        StepBarChart(chartData: hkManager.steps.chartData)

                        StepPieChart(chartData: hkManager.steps.averageWeekdayCountData)
                    case .weight:
                        WeightLineChart(chartData: hkManager.weights.chartData)

                        WeightBarChart(chartData: hkManager.weights.averageDailyWeightDiffsData)
                    }
                }
            }
            .padding()
            .task { fetchHealthData() }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPriming) {
                fetchHealthData()
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

    private func fetchHealthData() {
        Task {
            do {
                // await hkManager.generateHealthData()

                // Make this concurrent
                async let steps = hkManager.fetchStepCount()
                async let weights = hkManager.fetchWeights()

                hkManager.steps = try await steps
                hkManager.weights = try await weights

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
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
