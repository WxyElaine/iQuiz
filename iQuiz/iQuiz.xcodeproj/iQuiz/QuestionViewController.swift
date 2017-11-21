//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Xinyi Wang on 11/12/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backToMain: UIBarButtonItem!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var choiceA: UIButton!
    @IBOutlet weak var choiceB: UIButton!
    @IBOutlet weak var choiceC: UIButton!
    @IBOutlet weak var choiceD: UIButton!
    @IBOutlet weak var submit: UIButton!
    
    public var pageTitle: String!
    public var questionIndex: Int = 0
    public var questionList: Array<String> = []
    public var correctIndex: Array<Int> = []
    public var choiceList: Array<Array<String>> = []
    public var count: Int = 0

    private var selected: UIButton!
    
    public var choices: Array<UIButton> = []
    private var answerViewController: AnswerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:0.90, green:0.90, blue:0.98, alpha:1.0)
        choices = [choiceA, choiceB, choiceC, choiceD]
        
        // setup font
        navBar.topItem!.title = pageTitle
        
        // setup label
        questionLabel.backgroundColor = UIColor(red:0.94, green:0.97, blue:1.00, alpha:1.0)
        for choice in choices {
            choice.backgroundColor = UIColor.white
        }
        
        displayQandA(questionIndex)
    }
    
    private func displayQandA(_ index: Int) {
        if questionList.isEmpty {
            questionLabel.text = "No questions"
        } else {
            questionLabel.text = questionList[index]
        }
        if !choiceList.isEmpty {
            for i in 0...choices.count - 1 {
                choices[i].setTitle(choiceList[questionIndex][i], for: .normal)
            }
        }
        submit.isEnabled = false
        submit.tintColor = UIColor(red:0.26, green:0.09, blue:0.49, alpha:1.0)
    }
    
    @IBAction func choiceSelected(_ sender: UIButton) {
        if selected == nil || !selected.isEqual(sender) {
            selected = sender
            for choice in choices {
                if choice.isEqual(sender) {
                    choice.tintColor = UIColor(red:0.00, green:0.00, blue:0.40, alpha:1.0)
                } else {
                    choice.tintColor = UIColor(red:0.75, green:0.74, blue:0.76, alpha:1.0)
                }
            }
            submit.isEnabled = true
        }
    }
    
    @IBAction func submitted(_ sender: UIButton) {
        answerBuilder()
        performSegue(withIdentifier: "answerSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "answerSegue" {
            let answerView = segue.destination as! AnswerViewController
            answerView.pageTitle = self.pageTitle
            answerView.questionList = self.questionList
            answerView.questionIndex = self.questionIndex
            answerView.correctIndex = self.correctIndex
            answerView.choiceList = self.choiceList
            answerView.count = self.count
            let correctI = correctIndex[questionIndex]
            if selected.isEqual(choices[correctI]) {
                answerView.correct = "Great! You got it right!"
            } else {
                answerView.correct = "Oops! You got it wrong!"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func answerBuilder() {
        if answerViewController == nil {
            answerViewController = storyboard?.instantiateViewController(withIdentifier: "Answer") as! AnswerViewController
        }
    }
}
