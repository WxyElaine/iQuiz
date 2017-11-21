//
//  FinishViewController.swift
//  iQuiz
//
//  Created by Xinyi Wang on 11/13/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var score: UILabel!
    
    public var pageTitle: String!
    public var count: Int = 0
    public var total: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red:0.93, green:0.91, blue:0.95, alpha:1.0)
        navBar.topItem!.title = pageTitle
        
        displayResult()
    }

    private func displayResult() {
        let result = Double(count) / Double(total)
        var displayText = ""
        var color = UIColor.black
        if result >= 0.8 {
            displayText = "Perfect!"
            color = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0)
        } else if 0.6..<0.8 ~= result {
            displayText = "Almost!"
            color = UIColor(red:0.95, green:0.47, blue:0.21, alpha:1.0)
        } else if 0.5..<0.6 ~= result {
            displayText = "Keep it Up!"
            color = UIColor(red:1.00, green:0.68, blue:0.38, alpha:1.0)
        } else {
            displayText = "Try Again!"
            color = UIColor(red:0.30, green:0.11, blue:0.48, alpha:1.0)
        }
        text.text = displayText
        text.textColor = color
        score.text = "\(count) / \(total)"
        score.textColor = color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
