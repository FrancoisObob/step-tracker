//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/3/24.
//

import SwiftUI

struct HealthKitPermissionPrimingView: View {
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

            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
    }
}

#Preview {
    HealthKitPermissionPrimingView()
}
