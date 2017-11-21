//
//  ViewController.swift
//  iQuiz
//
//  Created by Xinyi Wang on 11/5/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var subjects: Array<String> = []
    private var descriptions: Array<String> = []
    private var questionList: Array<QuestionsList> = []
    
    private var images: Array<UIImage> = [#imageLiteral(resourceName: "comic.png"), #imageLiteral(resourceName: "heart.png"), #imageLiteral(resourceName: "planet.png")]
    private let choicesTitle: Array<String> = ["A.", "B.", "C.", "D."]
    
    private var items: Array<CustomTableViewCell> = []
    private var questionViewController: QuestionViewController!
    private var source: String = "http://tednewardsandbox.site44.com/questions.json"
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CustomTableViewCell
        if let celltry = self.tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = celltry as! CustomTableViewCell
            
        } else {
            cell = CustomTableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        cell.imageView?.image = self.images[indexPath.row - indexPath.row / 3]
        cell.textLabel?.text = self.subjects[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = self.descriptions[indexPath.row]
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor(red:1.00, green:0.89, blue:0.88, alpha:1.0)
        
        cell.heightAnchor.constraint(equalToConstant: tableView.frame.height / 3).isActive = true
        
        items.append(cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        questionBuilder()
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "questionSegue", sender: cell)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Cell Deselected")
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        print("Cell Highlighted")
    }
    
    // Quiz Questions Struct
    struct Quiz: Decodable {
        let title: String
        let desc: String
        let questions: [Questions]
    }
    
    struct Questions: Decodable {
        let text: String
        let answer: String
        let answers: Array<String>
    }
    
    struct QuestionsList {
        let text: Array<String>
        let answer: Array<Int>
        let answers: Array<Array<String>>
    }
    
    // Storyboard ViewController
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingBar: UIToolbar!
    @IBOutlet weak var settings: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")

        settingBar.backgroundColor = UIColor.white
        let font = UIFont.systemFont(ofSize: settingBar.frame.height / 3)

        settings.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        self.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        for item in items {
            item.removeConstraints(item.constraints)
        }
        setUpLayout(tableView.frame.width, tableView.frame.height)
    }
    
    @IBAction func settingsPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let questionView = segue.destination as! QuestionViewController
        let cell = sender as! UITableViewCell
        questionView.pageTitle = cell.textLabel?.text
        questionView.questionIndex = 0
        let titleIndex = subjects.index(of: cell.textLabel!.text!)
        questionView.questionList = questionList[titleIndex!].text
        questionView.correctIndex = questionList[titleIndex!].answer
        questionView.choiceList = questionList[titleIndex!].answers
    }
    
    @IBAction func unwindToViewController(unwindSegue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setUpLayout(_ tableHeight: CGFloat, _ tableWidth: CGFloat) {
        for item in items {
            item.heightAnchor.constraint(equalToConstant: tableHeight / 3).isActive = true
        }
    }
    
    private func questionBuilder() {
        if questionViewController == nil {
            questionViewController = storyboard?.instantiateViewController(withIdentifier: "Question") as! QuestionViewController
        }
    }
    
    private func fetchData() {
        guard let url = URL(string: source) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let quiz = try JSONDecoder().decode([Quiz].self, from: data)
                
                for element in quiz {
                    self.subjects.append(element.title)
                    self.descriptions.append(element.desc)
                    var textTemp: Array<String> = []
                    var answerTemp: Array<Int> = []
                    var choicesTemp: Array<Array<String>> = []
                    for question in element.questions {
                        textTemp.append(question.text)
                        answerTemp.append(Int.init(question.answer)! - 1)
                        var choiceTemp: Array<String> = []
                        for i in 0...question.answers.count - 1 {
                            choiceTemp.append("\(self.choicesTitle[i]) \(question.answers[i])")
                        }
                        choicesTemp.append(choiceTemp)
                    }
                    self.questionList.append(QuestionsList.init(text: textTemp, answer: answerTemp, answers: choicesTemp))
                }
            } catch let jsonError {
                print("Error in JSON Serialization:", jsonError)
            }
        }.resume()
    }
}

