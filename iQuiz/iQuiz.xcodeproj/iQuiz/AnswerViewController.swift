//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by Xinyi Wang on 11/13/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class AnswerViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var correctness: UILabel!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var nextOne: UIButton!
    @IBOutlet weak var finish: UIButton!
    
    public var correct: String! = ""
    public var questionIndex: Int = 0
    
    public var pageTitle: String!
    public var questionList: Array<String> = []
    public var correctIndex: Array<Int> = []
    public var choiceList: Array<Array<String>> = []
    public var count: Int = 0
    
    private var questionViewController: QuestionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red:1.00, green:0.98, blue:0.97, alpha:1.0)
        navBar.topItem!.title = pageTitle
        nextOne.tintColor = UIColor(red:0.26, green:0.09, blue:0.49, alpha:1.0)
        
        let finished: Bool = (questionIndex == questionList.count - 1)
        nextOne.isHidden = finished
        finish.isHidden = !finished

        displayInfo()
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "nextSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextSegue" {
            let questionView = segue.destination as! QuestionViewController
            questionView.pageTitle = self.pageTitle
            questionView.questionList = self.questionList
            questionView.questionIndex = self.questionIndex + 1
            questionView.correctIndex = self.correctIndex
            questionView.choiceList = self.choiceList
            questionView.count = self.count
        } else if segue.identifier == "finishSegue" {
            let finishView = segue.destination as! FinishViewController
            finishView.pageTitle = self.pageTitle
            finishView.count = self.count
            finishView.total = questionList.count
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func displayInfo() {
        correctness.text = correct
        if correct.hasPrefix("Oops") {
            correctness.textColor = UIColor(red:0.25, green:0.27, blue:0.71, alpha:1.0)
        } else {
            correctness.textColor = UIColor(red:0.98, green:0.94, blue:0.06, alpha:1.0)
            count += 1
        }
        question.text = "Question: \n\(questionList[questionIndex])"
        let correctI = correctIndex[questionIndex]
        answer.text = "Answer: \n\(choiceList[questionIndex][correctI])"
    }
    
}
