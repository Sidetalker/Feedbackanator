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
    
    var recentFeedbackCount: Int {
        return currentState.users.reduce(0) {
            return $0 + ($1.hasRecentFeedback ? 1 : 0)
        }
    }
    var staleFeedbackCount: Int {
        return currentState.users.reduce(0) {
            return $0 + ($1.hasRecentFeedback ? 0 : 1)
        }
    }
    
    init(with state: Snapshot) {
        currentState = state
        initialState = state
    }
}

extension User {
    var lastFeedbackDate: Date { return lastInteractions.last?.date ?? Date(timeIntervalSince1970: 0) }
    var hasRecentFeedback: Bool { return Date().timeIntervalSince(lastFeedbackDate) < Constants.twoWeeksInSeconds }
}
