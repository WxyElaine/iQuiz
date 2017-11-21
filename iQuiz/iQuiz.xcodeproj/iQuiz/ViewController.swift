//
//  ViewController.swift
//  iQuiz
//
//  Created by Xinyi Wang on 11/5/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
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
        
        cell.imageView?.image = self.images[indexPath.row - 3 * (indexPath.row / 3)]
        cell.textLabel?.text = self.subjects[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = self.descriptions[indexPath.row]
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor(red:1.00, green:0.89, blue:0.88, alpha:1.0)

        items.append(cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        questionBuilder()
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "questionSegue", sender: cell)
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
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var inputURL: UITextField!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        self.inputURL.delegate = self
        
        popoverView.isHidden = true
        popoverView.layer.cornerRadius = 10
        dimmerView.isHidden = true
        settingBar.backgroundColor = UIColor.white
        let font = UIFont.systemFont(ofSize: settingBar.frame.height / 3)
        settings.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        self.fetchData()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(ViewController.refreshData(sender:)), for: .valueChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @objc private func refreshData(sender: UIRefreshControl) {
        fetchData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func settingsPressed(_ sender: UIBarButtonItem) {
        popoverView.isHidden = false
        dimmerView.isHidden = false
    }
    
    // Dismisses the keyboard if needed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    @IBAction func setted(_ sender: UIButton) {
        let _ = self.textFieldShouldReturn(inputURL)
        let newSource = inputURL.text
        var errMessage = ""
        
        if newSource != nil && newSource != "" {
            let range = newSource!.startIndex..<newSource!.endIndex
            let correctRange = newSource!.range(of: "^(http)s?(:\\/\\/).*$", options: .regularExpression)
            if correctRange == range {
                source = newSource!
                fetchData()
            } else {
                errMessage = "Invalid URL"
            }
        } else {
            errMessage = "Please enter an URL"
        }
        if errMessage != "" {
            let alertController = UIAlertController(title: "ERROR", message: errMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }

        popoverView.isHidden = true
        dimmerView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "questionSegue" {
            let questionView = segue.destination as! QuestionViewController
            let cell = sender as! UITableViewCell
            questionView.pageTitle = cell.textLabel?.text
            questionView.questionIndex = 0
            let titleIndex = subjects.index(of: cell.textLabel!.text!)
            questionView.questionList = questionList[titleIndex!].text
            questionView.correctIndex = questionList[titleIndex!].answer
            questionView.choiceList = questionList[titleIndex!].answers
        }
    }
    
    @IBAction func unwindToViewController(unwindSegue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func questionBuilder() {
        if questionViewController == nil {
            questionViewController = storyboard?.instantiateViewController(withIdentifier: "Question") as! QuestionViewController
        }
    }
    
    /* Fetches data from the source URL.
        --> If succeeds, uses the JSON data writes the JSON to a local file (creates one if no local file exists).
        --> If fails, checks if a local file exists. If the local exists, uses the local file. If not, uses the original read-only data in the application bundle. */
    private func fetchData() {
        guard let url = URL(string: source) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse != nil && httpResponse?.statusCode == 200 {
                print("statusCode: \(httpResponse!.statusCode)")

                guard let data = data else { return }
                if self.parseJSON(data) {
                    self.writeJSON(data)
                } else {
                    let alertController = UIAlertController(title: "ERROR", message: "Invalid Source URL!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true)
                    self.chooseLocalFile()
                }
            } else {
                print("NETWORK ERROR")
                // use local file
                self.chooseLocalFile()
            }
            DispatchQueue.main.async {
                print("FINISH")
                self.tableView.reloadData()
            }
        }.resume()
    }
    
    private func chooseLocalFile() {
        if let filePath = Bundle.main.url(forResource: "NewData", withExtension: "json") {
            // use new data
            print("NewData")
            getLocalFile(filePath)
        } else if let filePath = Bundle.main.url(forResource: "Data", withExtension: "txt") {
            // use original read-only data
            print("OldData")
            getLocalFile(filePath)
        } else {
            print("INVALID FILEPATH")
        }
    }
    
    private func getLocalFile(_ filePath: URL) {
        do {
            let file: FileHandle? = try FileHandle(forReadingFrom: filePath)
            if file != nil {
                let fileData = file!.readDataToEndOfFile()
                file!.closeFile()
//                let str = NSString(data: fileData, encoding: String.Encoding.utf8.rawValue)
//                print("FILE CONTENT: \(str!)")
                let _ = parseJSON(fileData)
            }
        } catch {
            print("Error in file reading: \(error.localizedDescription)")
        }
    }
    
    private func parseJSON(_ data: Data) -> Bool {
        var result = true
        do {
            let quiz = try JSONDecoder().decode([Quiz].self, from: data)
            self.subjects.removeAll()
            self.descriptions.removeAll()
            self.questionList.removeAll()

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
        }  catch let jsonError {
            print("Error in JSON Serialization:", jsonError)
            result = false
        }
        return result
    }
    
    private func writeJSON(_ data: Data) {
        var documentsDirectory: URL?
        var fileURL: URL?
        
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        fileURL = documentsDirectory!.appendingPathComponent("NewData.json")
        do {
            let checkFile: FileHandle? = try FileHandle(forWritingTo: fileURL!)
            if checkFile == nil {
                print("File does not exist, create it")
                NSData().write(to: fileURL!, atomically: true)
            } else {
                print("File exists")
            }
        } catch {
            print("Error in file creating: \(error.localizedDescription)")
        }
        do {
            let newFile: FileHandle? = try FileHandle(forWritingTo: fileURL!)
            if newFile != nil {
                newFile!.write(data)
                print("FILE WRITE")
            } else {
                print("Unable to write JSON file!")
            }
        } catch {
            print("Error in file writing: \(error.localizedDescription)")
        }
    }
}

