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
    var initialState: Data
    
    /// Initialized on first access based on `currentState`, but maintained manually during app lifecycle
    lazy var totalUsers: Int = { computedTotalUsers }()
    /// Initialized on first access based on `currentState`, but maintained manually during app lifecycle
    lazy var totalFeedback: Int = { computedTotalFeedback }()
    
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
    
    var recentFeedbackPaths: [IndexPath] {
        var paths = [IndexPath]()
        for row in 0..<recentFeedbackCount {
            paths.append(IndexPath(row: row, section: 1))
        }
        return paths
    }
    var staleFeedbackPaths: [IndexPath] {
        var paths = [IndexPath]()
        for row in 0..<staleFeedbackCount {
            paths.append(IndexPath(row: row, section: 0))
        }
        return paths
    }
    var indexPaths: [IndexPath] {
        return recentFeedbackPaths + staleFeedbackPaths
    }
    
    private var computedTotalUsers: Int {
        return currentState.users.count
    }
    
    private var computedTotalFeedback: Int {
        return currentState.users.reduce(0) { $0 + $1.lastInteractions.count }
    }
    
    convenience init?() {
        do {
            if let jsonUrl = Bundle.main.url(forResource: "initialState", withExtension: "json") {
                let jsonData = try Data(contentsOf: jsonUrl)
                self.init(data: jsonData)
            } else {
                print("Can't find initialState.json")
                return nil
            }
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    init?(data: Data) {
        do {
            currentState = try FeedbackManager.loadSnapshot(from: data)
            initialState = data
            print("Successfully Initialized FeedbackManager from \(data)")
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    private static func loadSnapshot(from data: Data) throws -> Snapshot {
        return try JSONDecoder().decode(Snapshot.self, from: data)
    }
    
    func restart() {
        do {
            currentState = try FeedbackManager.loadSnapshot(from: initialState)
            totalUsers = computedTotalUsers
            totalFeedback = computedTotalFeedback
            print("Successfully restarted FeedbackManager using \(initialState)")
        } catch {
            print("Error: \(error)")
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
