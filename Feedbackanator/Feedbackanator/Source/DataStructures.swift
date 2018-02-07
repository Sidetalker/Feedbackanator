//
//  DataStructures.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

struct Snapshot: Codable {
    var users: [User]
}

class User: Codable {
    var id: Int
    var name: String
    var email: String
    var avatarUrl: String?
    var lastInteractions = [Interaction]()
    
    var avatarImage: UIImage? = nil
    var firstName: String {
        return String(name.split(separator: " ").first ?? "")

    }
    
    var lastFeedbackString: NSAttributedString {
        return feedbackString(at: lastInteractions.count - 1, prepending: "Last feedback you sent: ")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarUrl = "avatar"
        case lastInteractions = "last_interactions"
    }
    
    func feedbackString(at index: Int, prepending prependedString: String? = nil) -> NSAttributedString {
        if lastInteractions.count == 0 {
            let attributes: [NSAttributedStringKey : Any] = [.foregroundColor : UIColor.darkText,
                                                             .font : UIFont.boldSystemFont(ofSize: 12)]
            
            let returnString = NSMutableAttributedString()
            let baseString = NSAttributedString(string: prependedString ?? "")
            let ohNoString = NSAttributedString(string: "Never sent feedback!", attributes: attributes)
            
            returnString.append(baseString)
            returnString.append(ohNoString)
            
            return returnString
        } else {
            return lastInteractions[index].feedbackString(prepending: prependedString)
        }
    }
}

struct Interaction: Codable {
    var id: Int
    var isoTime: ISOTime
    
    var date: Date { return isoTime.date }
    
    enum CodingKeys: String, CodingKey {
        case id
        case isoTime = "date"
    }
    
    func feedbackString(prepending prependedString: String? = nil) -> NSAttributedString {
        let now = Date()
        let timeElapsedInMonths = now.months(from: date)
        let timeElapsedInWeeks = now.weeks(from: date)
        let timeElapsedInDays = now.days(from: date)
        let timeElapsedInHours = now.hours(from: date)
        let timeElapsedInMinutes = now.minutes(from: date)
        let timeElapsedInSeconds = now.seconds(from: date)
        
        var basicString = prependedString ?? ""
        
        if timeElapsedInMonths >= 1 {
            basicString += "\(timeElapsedInMonths) \("month".pluralized(givenCount: timeElapsedInMonths))"
        } else if timeElapsedInWeeks >= 1 {
            basicString += "\(timeElapsedInWeeks) \("week".pluralized(givenCount: timeElapsedInWeeks))"
        } else if timeElapsedInDays >= 1 {
            basicString += "\(timeElapsedInDays) \("day".pluralized(givenCount: timeElapsedInDays))"
        } else if timeElapsedInHours >= 1 {
            basicString += "\(timeElapsedInHours) \("hour".pluralized(givenCount: timeElapsedInHours))"
        } else if timeElapsedInMinutes >= 1 {
            basicString += "\(timeElapsedInMinutes) \("minute".pluralized(givenCount: timeElapsedInMinutes))"
        } else if timeElapsedInSeconds > 10 {
            basicString += "\(timeElapsedInSeconds) seconds"
        }
        
        if timeElapsedInSeconds <= 10 {
            basicString += "just now"
        } else {
            basicString += " ago"
        }
        
        let returnString = NSMutableAttributedString(string: basicString)
        
        if timeElapsedInWeeks >= 3 {
            let searchNum = timeElapsedInMonths > 0 ? timeElapsedInMonths : timeElapsedInWeeks
            let searchRange = basicString.range(of: "\(searchNum)")! // TODO: Unit test this!
            let searchIndex = searchRange.lowerBound
            
            let attributes: [NSAttributedStringKey : Any] = [.foregroundColor : (timeElapsedInMonths >= 2 ? UIColor.red : UIColor.orange),
                                                             .font : UIFont.boldSystemFont(ofSize: 12)]
            
            let start = basicString.distance(from: basicString.startIndex, to: searchIndex)
            let length = basicString.distance(from: searchIndex, to: basicString.endIndex)
            returnString.addAttributes(attributes, range: NSMakeRange(start, length))
        }
        
        return NSAttributedString(attributedString: returnString)
    }
}

struct ISOTime: Codable {
    var date: Date
    
    init() {
        self.date = Date()
    }
    
    init(from decoder: Decoder) throws {
        let isoString = try String(from: decoder)
        
        if let parsedDate = DateFormatterCache.shared.date(from: isoString) {
            date = parsedDate
        } else {
            throw ParseError.invalidTimeString
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(DateFormatterCache.shared.string(from: date))
    }
}

enum ParseError: Error {
    case invalidTimeString
}
