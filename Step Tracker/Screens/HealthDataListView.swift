//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/3/24.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager

    @State private var isShowingAddData = false
    @State private var selectedDate: Date = .now
    @State private var valueToAdd: String = ""

    var metric: HealthMetricContext

    var listData: [HealthMetric] {
        metric == .steps ? hkManager.stepData : hkManager.weightData
    }

    var body: some View {
        List(listData) { data in
            HStack {
                Text(data.date, format: .dateTime.month().day().year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date",
                           selection: $selectedDate,
                           in: .distantPast...Date(),
                           displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            do {
                                switch metric {
                                case .steps:
                                    try await hkManager.addStepData(for: selectedDate,
                                                                value: Double(valueToAdd)!)
                                    try await hkManager.fetchStepCount()
                                case .weight:
                                    try await hkManager.addWeightData(for: selectedDate,
                                                                  value: Double(valueToAdd)!)
                                    try await hkManager.fetchWeights()
                                }
                                isShowingAddData = false
                            } catch STError.sharingDenied(let quantityType) {
                                print("Sharing denied for \(quantityType)")
                            } catch {
                                print("Data List View Unable to complete request")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}
