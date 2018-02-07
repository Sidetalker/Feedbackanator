//
//  Cells.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

protocol UserCellDelegate {
    func tappedGiveFeedback(from cell: UserCell)
}

class UserCell: UITableViewCell {
    
    static let height: CGFloat = 120
    
    @IBOutlet weak var btnGiveFeedback: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblLastFeedback: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lineBreakLeftPadding: NSLayoutConstraint!
    
    var delegate: UserCellDelegate?
    var timer: Timer?
    
    var user: User!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(for user: User) {
        self.user = user
        
        updateText()
        
        let now = Date()
        
        if now.timeIntervalSince(user.lastFeedbackDate) < 60 {
            startTimer(withInterval: 1)
        } else if now.timeIntervalSince(user.lastFeedbackDate) < 360 {
            startTimer(withInterval: 60)
        } else {
            stopTimer()
        }
    }
    
    @objc private func updateText() {
        guard let user = user else {
            return // Can't update text without a user
        }
        
        lblName.text = user.name
        lblLastFeedback.attributedText = user.lastFeedbackString
        setNeedsDisplay()
        
        if Date().timeIntervalSince(user.lastFeedbackDate) >= 360 {
            stopTimer()
        }
    }
    
    private func startTimer(withInterval interval: TimeInterval) {
        if timer != nil { stopTimer() }
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateText), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func tapGiveFeedback(_ sender: Any) {
        delegate?.tappedGiveFeedback(from: self)
    }
}

/// Shamelessly ripped from https://stackoverflow.com/questions/27182023/getting-the-difference-between-two-nsdates-in-months-days-hours-minutes-seconds
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
