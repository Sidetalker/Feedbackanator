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
    
    @IBOutlet weak var btnGiveFeedback: UIButton! {
        didSet {
            btnGiveFeedback.titleEdgeInsets.left = 20
        }
    }
    @IBOutlet weak var imgAvatar: UIRoundedImageView!
    @IBOutlet weak var lblLastFeedback: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var normalLineView: UIView!
    
    var delegate: UserCellDelegate?
    var timer: Timer?
    
    var user: User!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(for user: User, isFinalCell: Bool) {
        self.user = user
        
        updateText()
        
        bottomLineView.isHidden = !isFinalCell
        normalLineView.isHidden = isFinalCell
        
        if let avatar = user.avatarImage {
            imgAvatar.image = avatar
        } else {
            ImageCache.shared.cacheImage(for: user) { avatar in
                DispatchQueue.main.async {
                    self.imgAvatar.image = avatar
                }
            }
        }
        
        let now = Date()
        var heartImage: UIImage
        
        if now.timeIntervalSince(user.lastFeedbackDate) < Constants.twelveWeeksInSeconds {
            heartImage = ImageCache.shared.filledHeart
        } else {
            heartImage = ImageCache.shared.emptyHeart
        }
        
        btnGiveFeedback.setImage(heartImage, for: .normal)
        
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
