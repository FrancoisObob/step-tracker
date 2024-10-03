//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/3/24.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {

    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss

    @State private var trigger = false

    var description = """
    This app displays your step and wieght data in interactive charts.
    
    You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
    """

    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 12){
                Image(.healthLogo)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3) ,radius: 16)
                    .padding(.bottom, 12)

                Text("Apple Health Integration")
                    .font(.title2).bold()

                Text(description)
                    .foregroundStyle(.secondary)
            }

            Button("Connect Apple Health") {
                trigger.toggle()
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .healthDataAccessRequest(
            store: hkManager.store,
            shareTypes: hkManager.types,
            readTypes: hkManager.types,
            trigger: trigger ) { result in
                switch result {
                case .success:
                    dismiss()
                case .failure:
                    // handle the error later
                    dismiss()
                }
            }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
