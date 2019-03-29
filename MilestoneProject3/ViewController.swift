/*
 Load file
    Get words
    Get clues
    Make dictionary
 
 Start level
    Pick word
    Put word in wordLabel with underscores
    Put clue in clueLabel
 
 
 */

import UIKit

class ViewController: UIViewController {

    var scoreLabel: UILabel!
    var clueLabel: UILabel!
    var wordLabel: UILabel!
    var guessedLetters: UITextField!
    var wordBitButtons = [UIButton]()
    var selectedButtons = [UIButton]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    var letters = [Character]()
    var wordClues = [[String]]()
    var currentWordClue = [String]()
    
    
    //MARK: - UIViewController class

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadLevel()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        for i in 65...90 {
            letters.append(Character(UnicodeScalar(i)!))
        }
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        clueLabel = UILabel()
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.font = UIFont.systemFont(ofSize: 24)
        clueLabel.text = "CLUES"
        clueLabel.numberOfLines = 0
        
        view.addSubview(clueLabel)
        
        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.font = UIFont.systemFont(ofSize: 24)
        wordLabel.text = "ANSWERS"
        wordLabel.numberOfLines = 0
        wordLabel.textAlignment = .right
        view.addSubview(wordLabel)
        
        guessedLetters = UITextField()
        guessedLetters.translatesAutoresizingMaskIntoConstraints = false
        guessedLetters.placeholder = "Tap letters to guess"
        guessedLetters.textAlignment = .center
        guessedLetters.font = UIFont.systemFont(ofSize: 44)
        guessedLetters.isUserInteractionEnabled = false
        view.addSubview(guessedLetters)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        clueLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        wordLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // pin the top of the clues label to the bottom of the score label
            clueLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // pin the leading edge of the clues label to the leading edge of our layout margins, adding 100 for some space
            clueLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            // make the clues label 60% of the width of our layout margins, minus 100
            clueLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            // also pin the top of the answers label to the bottom of the score label
            wordLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // make the answers label stick to the trailing edge of our layout margins, minus 100
            wordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            // make the answers label take up 40% of the available space, minus 100
            wordLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            // make the answers label match the height of the clues label
            wordLabel.heightAnchor.constraint(equalTo: clueLabel.heightAnchor),
            
            guessedLetters.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guessedLetters.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            guessedLetters.topAnchor.constraint(equalTo: clueLabel.bottomAnchor, constant: 20),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: guessedLetters.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            
            ])
        
        // set some values for the width and height of each button
        let width = 60
        let height = 60
        
        for row in 0..<2 {
            for col in 0..<13 {
                // create a new button and give it a big font size
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                
                // give the button some temporary text so we can see it on-screen
                letterButton.setTitle(String(letters[col + row*13]), for: .normal)
                
                // calculate the frame of this button using its column and row
                let frame = CGRect(x: col * width, y: row * height, width: width-5, height: height-5)
                letterButton.frame = frame
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.gray.cgColor
                
                // add it to the buttons view
                buttonsView.addSubview(letterButton)
                
                // and also to our letterButtons array
                wordBitButtons.append(letterButton)
            }
        }
        
    }
    
    
    //MARK: - ViewController class
    
    
    func loadLevel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            /* level1.txt
             HAUNTED: Ghosts in residence
             LEPROSY: A Biblical skin disease
             TWITTER: Short but sweet online chirping
             OLIVER: Has a Dickensian twist
             ELIZABETH: Head of state, British style
             SAFARI: The zoological web
             PORTLAND: Hipster heartland
             */
            guard let level = self?.level else {return}
            if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.remove(at: lines.count - 1)
                    lines.shuffle()
                    
                    for line in lines {
                        let parts = line.components(separatedBy: ": ")
                        let word = parts[0]
                        let clue = parts[1]
                        
                        self?.wordClues.append([word, clue])
                    }
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                let c = (self?.wordClues.count)!
                let r = Int.random(in: 0..<c)
                let cur = (self?.wordClues[r])!
                self?.wordClues.remove(at: r)
                self?.currentWordClue = cur
                var hidden = ""
                for _ in 0..<cur[0].count {
                    hidden.append("?")
                }
                self?.wordLabel.text = hidden
                self?.clueLabel.text = cur[1]
            }
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        
        loadLevel()
        
        for btn in wordBitButtons {
            btn.isHidden = false
        }
    }
    
    
    

    //MARK: - #selectors
    
    @objc func letterTapped(_ wordBitButton: UIButton) {
        guard let buttonTitle = wordBitButton.titleLabel?.text else { return }
        guessedLetters.text = guessedLetters.text?.appending(buttonTitle)
        selectedButtons.append(wordBitButton)
        wordBitButton.isHidden = true
        
        for (index, char) in currentWordClue[0].enumerated() {
            if String(char) == buttonTitle {
                var result = wordLabel.text!
                wordLabel.text = replace(myString: result, index, Character(buttonTitle))
            }
        }
    }
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }

    
//    @objc func submitTapped(_ sender: UIButton) {
//        guard let answerText = guessedLetters.text else { return }
//
//        if let solutionPosition = solutionWords.firstIndex(of: answerText) {
//            selectedButtons.removeAll()
//
//            var splitAnswers = wordLabel.text?.components(separatedBy: "\n")
//            splitAnswers?[solutionPosition] = answerText
//            wordLabel.text = splitAnswers?.joined(separator: "\n")
//
//            guessedLetters.text = ""
//            score += 1
//
//            var canLevelUp = true
//            for wordBitButton in wordBitButtons {
//                if wordBitButton.isHidden == false {
//                    canLevelUp = false
//                }
//            }
//            if canLevelUp {
//                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
//                present(ac, animated: true)
//            }
//        } else {
//            let ac = UIAlertController(title: "Incorrect", message: "Don't give up!", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: clearAction))
//            present(ac, animated: true)
//            score -= 1
//        }
//    }
    
    func clear() {
        guessedLetters.text = ""
        
        for btn in selectedButtons {
            btn.isHidden = false
        }
        
        selectedButtons.removeAll()
    }
    
    func clearAction(action: UIAlertAction) {
        clear()
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        clear()
    }
}

