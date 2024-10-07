//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Foundation

extension Date {
    var weekDayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
