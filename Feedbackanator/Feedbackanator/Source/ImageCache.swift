//
//  ImageCache.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    /// Cache of user.id to avatar image
    var localCache = [Int : UIImage]()
    
    lazy var filledHeart = imageOfHeart(imageSize: CGSize(width: 30, height: 30), isHeartEmpty: false).withRenderingMode(.alwaysOriginal)
    lazy var emptyHeart = imageOfHeart(imageSize: CGSize(width: 30, height: 30), isHeartEmpty: true).withRenderingMode(.alwaysOriginal)
    
    func cacheImage(for user: User, completion: @escaping (UIImage?) -> ()) {
        guard let url = user.avatarUrl else {
            print("Can't cache avatar for \(user) missing avatarUrl")
            completion(cacheDefault(for: user))
            return
        }
        
        let id = user.id
        
        print("Caching image at \(url) under \(id)")
        
        getData(from: url) { data, response, error in
            guard
                let data = data,
                let image = UIImage(data: data),
                error == nil
            else {
                print("Error: \(error?.localizedDescription ?? "no image at \(url)")")
                completion(self.cacheDefault(for: user))
                return
            }
            
            self.localCache[id] = image
            print("Cached \(image) under \(id)")
            
            completion(image)
        }
    }
    
    private func cacheDefault(for user: User) -> UIImage {
        print("Caching default avatar under \(user.id)")
        localCache[user.id] = #imageLiteral(resourceName: "blankProfile")
        return #imageLiteral(resourceName: "blankProfile")
        
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
}

// MARK: - Paintcode Generated

fileprivate func drawHeart(frame: CGRect, heartFill: UIColor = .red) {
    
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: frame.minX + 0.50775 * frame.width, y: frame.minY + 0.93304 * frame.height))
    bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.21318 * frame.width, y: frame.minY + 0.74554 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.39639 * frame.width, y: frame.minY + 0.81880 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.28076 * frame.width, y: frame.minY + 0.81634 * frame.height))
    bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.02713 * frame.width, y: frame.minY + 0.39732 * frame.height), controlPoint1: CGPoint(x: frame.minX + -0.02033 * frame.width, y: frame.minY + 0.50092 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.02713 * frame.width, y: frame.minY + 0.39732 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.09690 * frame.width, y: frame.minY + 0.16518 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.21318 * frame.width, y: frame.minY + 0.08482 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.34496 * frame.width, y: frame.minY + 0.08482 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.47674 * frame.width, y: frame.minY + 0.22768 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.50775 * frame.width, y: frame.minY + 0.39732 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.55426 * frame.width, y: frame.minY + 0.16518 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.64729 * frame.width, y: frame.minY + 0.08482 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.80233 * frame.width, y: frame.minY + 0.08482 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.91085 * frame.width, y: frame.minY + 0.16518 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.98062 * frame.width, y: frame.minY + 0.39732 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.82558 * frame.width, y: frame.minY + 0.71875 * frame.height))
    bezierPath.addLine(to: CGPoint(x: frame.minX + 0.50775 * frame.width, y: frame.minY + 0.93304 * frame.height))
    heartFill.setFill()
    bezierPath.fill()
    UIColor.red.setStroke()
    bezierPath.lineWidth = 3
    bezierPath.lineCapStyle = .round
    bezierPath.lineJoinStyle = .round
    bezierPath.stroke()
}

fileprivate func imageOfHeart(imageSize: CGSize, isHeartEmpty: Bool) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    drawHeart(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), heartFill: isHeartEmpty ? .white : .red)
    
    let imageOfCanvas1 = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return imageOfCanvas1
}
