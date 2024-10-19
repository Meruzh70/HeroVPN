// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

extension Date {
    func noon(using calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    func day(using calendar: Calendar = .current) -> Int {
        calendar.component(.day, from: self)
    }
    func adding(_ component: Calendar.Component, value: Int, using calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: component, value: value, to: self)!
    }
    func monthSymbol(using calendar: Calendar = .current) -> String {
        calendar.monthSymbols[calendar.component(.month, from: self)-1]
    }

    func getStringDate(format: String = "MMMM dd, YYYY") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}
