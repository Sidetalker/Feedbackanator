//
//  ViewController.swift
//  Feedbackanator
//
//  Created by Kevin Sullivan on 2/6/18.
//  Copyright © 2018 SideApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            if let jsonUrl = Bundle.main.url(forResource: "initialState", withExtension: "json") {
                let jsonData = try Data(contentsOf: jsonUrl)
                let snapshot: Snapshot = try JSONDecoder().decode(Snapshot.self, from: jsonData)
                print(snapshot)
            } else {
                print("Can't find initialState.json")
            }
        } catch {
            print("Error: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

