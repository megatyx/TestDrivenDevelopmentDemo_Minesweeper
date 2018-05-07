//
//  GameViewController.swift
//  minesweeper
//
//  Created by Tyler Wells on 4/22/18.
//  Copyright © 2018 Tyler Wells. All rights reserved.
//

import UIKit

enum GameState {
    case win
    case lose
    case inProgress
}

class GameViewController: UIViewController {

    @IBOutlet weak var baseStackView: UIStackView!
    var buttonTimer: Timer!
    var wasLongPressed: Bool = false
    
    var gameboard: Gameboard!
    
    var runningViewTagCount = 1
    
    var goodSpaces = 0
    
    var gameState: GameState = .inProgress {
        didSet {
            if gameState == .lose {
                revealAll()
                let alert = UIAlertController(title: "BOOOOOOOOM!!!", message: "You've lost. Come on, try again!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                )
                alert.addAction(UIAlertAction(title: "Review", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if gameState == .win {
                revealAll()
                let alert = UIAlertController(title: "Good Job!", message: "You've Won! Do you want to play again?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }
                    )
                )
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.goodSpaces = gameboard.columns * gameboard.rows - gameboard.numberOfBombs
        generateView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func buttonTouched(sender: UIButton) {
        self.buttonTimer.invalidate()
        if !wasLongPressed {
            self.buttonAction(sender: sender, wasLongPressed: false)
        } else {
            wasLongPressed = false
        }
    }
    
    @objc func buttonTouchedDown(sender: UIButton) {
        self.buttonTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: {_ in
            self.wasLongPressed = true
            self.buttonAction(sender: sender, wasLongPressed: true)
        })
    }

    func generateView() {
        for _ in 1...gameboard.spaceMatrix[0].count {
            var buttonArray = Array<UIButton>()
            for _ in 1...gameboard.spaceMatrix.count {
                buttonArray.append(addButtonViewWith(tag: runningViewTagCount))
                runningViewTagCount += 1
            }
            let stackView = UIStackView(arrangedSubviews: buttonArray)
            stackView.axis = UILayoutConstraintAxis.horizontal
            stackView.distribution = .fillEqually
            baseStackView.addArrangedSubview(stackView)
            print(buttonArray.count)
        }
        
        
    }
    
    func addButtonViewWith(tag: Int) -> UIButton {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchedDown), for: .touchDown)
        button.tintColor = UIColor.black
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.tag = tag
        return button
    }
    
    func revealAll(){
        for stackViews in self.baseStackView.subviews{
            for view in stackViews.subviews {
                if let button = view as? UIButton {
                    let column = ((button.tag % gameboard.columns) == 0 ? gameboard.columns:button.tag % gameboard.columns) - 1
                    
                    let row = (button.tag % gameboard.columns) == 0 ? ((button.tag / gameboard.columns)-1):(button.tag / gameboard.columns)
                    
                    button.isUserInteractionEnabled = false
                    
                    if gameboard.spaceMatrix[column][row].hasBomb {
                        if button.titleLabel?.text != "\u{2691}" {
                            button.setTitle("\u{1F4A3}", for: .normal)
                        }
                    } else {
                        do {
                            if button.titleLabel?.text == "\u{2691}" {
                                button.setTitle("X", for: .normal)
                            } else {
                                let bombs = try gameboard.bombsNearCoordinate(column: column, row: row)
                                button.setTitle("\(bombs)", for: .normal)
                            }
                        } catch {
                            
                        }
                    }
                }
            }
        }
    }
    
    func buttonAction(sender: UIButton, wasLongPressed: Bool) {
        print("tag: \(sender.tag)")
        
        let column = ((sender.tag % gameboard.columns) == 0 ? gameboard.columns:sender.tag % gameboard.columns) - 1
        
        let row = (sender.tag % gameboard.columns) == 0 ? ((sender.tag / gameboard.columns)-1):(sender.tag / gameboard.columns)
        
        if !gameboard.spaceMatrix[column][row].hasBeenTouched {
            if wasLongPressed {
                sender.setTitle("\u{2691}", for: .normal)
                return
            }
            gameboard.spaceMatrix[column][row].hasBeenTouched = true
            
            if gameboard.spaceMatrix[column][row].hasBomb {
                self.gameState = .lose
                sender.setTitle("\u{1F4A3}", for: .normal)
                return
            }
            
            do {
                let bombs = try gameboard.bombsNearCoordinate(column: column, row: row)
                sender.setTitle("\(bombs)", for: .normal)
                self.goodSpaces -= 1
                if self.goodSpaces < 1 {
                    self.gameState = .win
                }
            } catch {
                
            }
        }
    }
}
