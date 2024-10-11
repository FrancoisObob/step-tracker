//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var weekdayTitle: String {
        formatted(.dateTime.weekday(.wide))
    }
}
