//
//  STError.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/12/24.
//

import Foundation

enum STError: LocalizedError {
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue

    var errorDescription: String? {
        switch self {
        case .authNotDetermined: return "Authorization not determined"
        case .sharingDenied: return "No Write Access"
        case .noData: return "No data available"
        case .unableToCompleteRequest: return "Unable to complete request"
        case .invalidValue: return "Invalid value"
        }
    }

    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Settings › Health › Data Access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Settings › Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time. \n\nPlease try again later or contact support."
        case .invalidValue:
            "Must be a numeric value with a maximum of one decimal please."
        }
    }
}

