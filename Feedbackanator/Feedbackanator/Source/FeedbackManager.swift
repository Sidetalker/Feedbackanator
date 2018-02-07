//
//  FeedbackManager.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import Foundation

class FeedbackManager {
    
    var currentState: Snapshot
    var initialState: Snapshot
    
    /// Initialized on first access based on `currentState`, but maintained manually during app lifecycle
    lazy var totalUsers: Int = { currentState.users.count }()
    /// Initialized on first access based on `currentState`, but maintained manually during app lifecycle
    lazy var totalFeedback: Int = { currentState.users.reduce(0) { $0 + $1.lastInteractions.count } }()
    
    var recentFeedbackCount: Int {
        return currentState.users.reduce(0) {
            return $0 + $1.hasRecentFeedback.intValue
        }
    }
    var staleFeedbackCount: Int {
        return currentState.users.reduce(0) {
            return $0 + (!$1.hasRecentFeedback).intValue
        }
    }
    
    var recentFeedbackUsers: [User] {
        return currentState.users.flatMap {
            return $0.hasRecentFeedback ? $0 : nil
        }.sorted()
    }
    var staleFeedbackUsers: [User] {
        return currentState.users.flatMap {
            return !$0.hasRecentFeedback ? $0 : nil
        }.sorted().reversed()
    }
    
    init?() {
        do {
            if let jsonUrl = Bundle.main.url(forResource: "initialState", withExtension: "json") {
                let jsonData = try Data(contentsOf: jsonUrl)
                let snapshot: Snapshot = try JSONDecoder().decode(Snapshot.self, from: jsonData)
                currentState = snapshot
                initialState = snapshot
                print("Successfully Initialized FeedbackManager from initialState.json")
            } else {
                print("Can't find initialState.json")
                return nil
            }
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func user(at indexPath: IndexPath) -> User? {
        if indexPath.section == 0 {
            return staleFeedbackUsers[indexPath.row]
        } else if indexPath.section == 1 {
            return recentFeedbackUsers[indexPath.row]
        }
        
        print("Error: Unexpected section \(indexPath.section)")
        return nil
    }
    
    func giveFeedback(at indexPath: IndexPath) {
        var user: User
        
        if indexPath.section == 0 {
            user = staleFeedbackUsers[indexPath.row]
        } else if indexPath.section == 1 {
            user = recentFeedbackUsers[indexPath.row]
        } else {
            print("Error: Unexpected section \(indexPath.section)")
            return
        }
        
        totalFeedback += 1
        user.lastInteractions.append(Interaction(id: totalFeedback, isoTime: ISOTime()))
    }
}

extension User: Comparable {
    
    var lastFeedbackDate: Date { return lastInteractions.last?.date ?? Date(timeIntervalSince1970: 0) }
    var hasRecentFeedback: Bool { return Date().timeIntervalSince(lastFeedbackDate) < Constants.twoWeeksInSeconds }
    
    static func <(lhs: User, rhs: User) -> Bool {
        return lhs.lastFeedbackDate < rhs.lastFeedbackDate
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
