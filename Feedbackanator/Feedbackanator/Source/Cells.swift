//
//  Cells.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

protocol UserCellDelegate {
    func userCellTappedGiveFeedback(_ cell: UserCell)
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
        lblLastFeedback.attributedText = lastFeedbackString(for: user.lastFeedbackDate, prepending: "Last feedback you sent: ")
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
    
    func lastFeedbackString(for date: Date, prepending prependedString: String? = nil) -> NSAttributedString {
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
    
    @IBAction func tapGiveFeedback(_ sender: Any) {
        delegate?.userCellTappedGiveFeedback(self)
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
