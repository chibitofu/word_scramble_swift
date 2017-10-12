//
//  ViewController.swift
//  word_scramble
//
//  Created by Erin Moon on 10/5/17.
//  Copyright © 2017 Erin Moon. All rights reserved.
//

import GameplayKit
import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
//Shuffles the words in allWords array using Gameplaykit, sets the title to the selected word and empties out the usedWords array.
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        var singleWord = [String]()
        for letter in allWords[0] {
            singleWord.append(String(letter))
        }
        let shuffleWord = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: singleWord)
        let shuffleWordString = shuffleWord.flatMap {String(describing: $0)}
        title = String(shuffleWordString)
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
//Sends an alert message to the UI.
    func alertMessage(errorTitle: String, errorMessage: String) -> Void {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
        return
    }
    
//Checks then submits the user answer to the usedWords array and adds it to the tableView.
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    alertMessage(errorTitle: "Word not recognized", errorMessage: "You can't just make them up, you know!")
                }
            } else {
                alertMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
            }
        } else {
            alertMessage(errorTitle: "Word not possible", errorMessage: "You can't spell '\(answer)' from '\(title!.lowercased())'!")
        }
    }
    
//Checks to see if the user answer is an anagram of the word and longer than 3 letters.
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        if tempWord.count > 3{
            for letter in word {
                if let pos = tempWord.range(of: String(letter)) {
                    
                    tempWord.remove(at: pos.lowerBound)
                } else {
                    return false
                }
            }
        }
        
        return true
    }
    
//Checks to see if the user answer is a copy of a word in the usedWords array.
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
//Checks to see if the user answer is a real word in english.
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
//Connected to the right bar button item that was added in viewDidLoad().
//Pops up an alert so the user can enter in a word and submit it.
    @objc func promptForAnswers() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [unowned self, ac] (action: UIAlertAction) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
//Sets the number of rows in the tableView to the amount of guessed words.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
//Sets the text in each row to an item in the usedWords array.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Creates an array of the words in start.txt
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        
        //Adds a button to the navbar in the upper right.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswers))
        
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

