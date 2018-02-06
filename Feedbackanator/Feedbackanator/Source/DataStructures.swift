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

struct User: Codable {
    var id: Int
    var name: String
    var email: String
    var avatarUrl: String?
    var lastInteractions = [Interaction]()
    
    var avatarImage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarUrl = "avatar"
        case lastInteractions = "last_interactions"
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
