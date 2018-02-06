//
//  FormatterCache.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import Foundation

class DateFormatterCache {
    static let shared = DateFormatterCache()
    
    let standardFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    func string(from date: Date) -> String {
        return standardFormatter.string(from: date)
    }
    
    func date(from string: String) -> Date? {
        return standardFormatter.date(from: string)
    }
}
