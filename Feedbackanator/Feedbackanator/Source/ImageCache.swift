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
