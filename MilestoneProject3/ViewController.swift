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
    
    enum Game: Int {
        case WIN
        case LOSE
    }
    var numWrongLabel: UILabel!
    var clueLabel: UILabel!
    var wordLabel: UILabel!
    var levelLabel: UILabel!
    
    var guessedLetters: UITextField!
    
    var wordBitButtons = [UIButton]()
    var selectedButtons = [UIButton]()
    
    var level = 1 {
        didSet {
            guard level < 3 else {return}
            levelLabel.text = "Level: \(level)"
        }
    }
    var letters = [Character]()
    var wordClues = [[String]]()
    var currentWordClue = [String]()
    var numWrong = 0 {
        didSet {
            numWrongLabel.text = "Wrong: \(numWrong)"
        }
    }

    
    //MARK: - UIViewController class
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        for i in 65...90 {
            letters.append(Character(UnicodeScalar(i)!))
        }
        
        numWrongLabel = UILabel()
        numWrongLabel.translatesAutoresizingMaskIntoConstraints = false
        numWrongLabel.textAlignment = .right
        numWrongLabel.text = "Wrong Answers: 0"
        view.addSubview(numWrongLabel)

        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.textAlignment = .left
        levelLabel.text = "Level: 0"
        view.addSubview(levelLabel)

        clueLabel = UILabel()
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.font = UIFont.systemFont(ofSize: 24)
        clueLabel.text = "CLUES"
        clueLabel.numberOfLines = 0
        
        view.addSubview(clueLabel)
        
        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.font = UIFont.systemFont(ofSize: 36)
        wordLabel.text = "WORD "
        wordLabel.numberOfLines = 0
        wordLabel.textAlignment = .right
        view.addSubview(wordLabel)
        
        guessedLetters = UITextField()
        guessedLetters.textColor = UIColor.gray
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
            numWrongLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            numWrongLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            levelLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            levelLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            // pin the top of the clues label to the bottom of the score label
            clueLabel.topAnchor.constraint(equalTo: numWrongLabel.bottomAnchor),
            
            // pin the leading edge of the clues label to the leading edge of our layout margins, adding 100 for some space
            clueLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            // make the clues label 60% of the width of our layout margins, minus 100
            clueLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            // also pin the top of the answers label to the bottom of the score label
            wordLabel.topAnchor.constraint(equalTo: numWrongLabel.bottomAnchor),
            
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
                self?.chooseWord()
            }
        }
    }
    
    func chooseWord(){
        let index = Int.random(in: 0..<wordClues.count)
        let wordClue = wordClues[index]
        wordClues.remove(at: index)
        currentWordClue = wordClue
        var hiddenAnswer = ""
        for _ in 0..<wordClue[0].count {
            hiddenAnswer.append("?")
        }
        wordLabel.text = hiddenAnswer
        clueLabel.text = wordClue[1]
    }
    
    func nextWord() {
        if wordClues.count == 0 {
            level += 1
            if level == 3 {
                gameOver(outcome: .WIN)
            }else {
                loadLevel()
            }
        } else {
            chooseWord()
        }
    }
    
    func gameOver(outcome: Game) {
        view.isUserInteractionEnabled = false
        let message: String
        switch outcome {
        case .LOSE:
            message = "Don't give up, try again!"
        case .WIN:
            message = "You won! Great job!"
        }
        let ac = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }

    func hideButtons() {
        for btn in wordBitButtons {
            btn.isHidden = false
        }
    }
    
    //MARK: - #selectors
    
    @objc func letterTapped(_ wordBitButton: UIButton) {
        guard let buttonTitle = wordBitButton.titleLabel?.text else { return }
        
        //track the letter
        guessedLetters.text = guessedLetters.text?.appending(buttonTitle)
        selectedButtons.append(wordBitButton)
        wordBitButton.isHidden = true
        
        //add letter to wordLabel
        var changed = false
        for (index, char) in currentWordClue[0].enumerated() {
            if String(char) == buttonTitle {
                let result = wordLabel.text!
                wordLabel.text = replace(myString: result, index, Character(buttonTitle))
                changed = true
            }
        }
        if changed == false {
            numWrong -= 1
            if numWrong == -7 {
                gameOver(outcome: .LOSE)
            }
        }
        if wordLabel.text?.contains("?") == false {
            let ac = UIAlertController(title: "Yay!", message: "You got the word!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.hideButtons()
                self.nextWord()
                self.guessedLetters.text = ""
            }))
            present(ac, animated: true)
        }
    }
}




