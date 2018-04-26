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
    
    let gameboard: Gameboard! = Gameboard(rows: 10, columns: 5, numberOfBombs: 2)
    
    var runningViewTagCount = 1
    
    var gameState: GameState = .inProgress
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameboard.generateGameMatrix()
        
        for (columnIndex,row) in gameboard.spaceMatrix.enumerated() {
            for (rowIndex,space) in row.enumerated() {
                if space.hasBomb {
                    print("bomb at position: \(columnIndex,rowIndex)")
                }
            }
        }
        
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
        print("tag: \(sender.tag)")
        
        let column = ((sender.tag % gameboard.columns) == 0 ? gameboard.columns:sender.tag % gameboard.columns) - 1

//        let column = (sender.tag % gameboard.columns) == 0 ? ((sender.tag / gameboard.columns)-1):(sender.tag / gameboard.columns)
        
        let row = (sender.tag % gameboard.columns) == 0 ? ((sender.tag / gameboard.columns)-1):(sender.tag / gameboard.columns)
        
        print(column)
        print(row)
        
        if !gameboard.spaceMatrix[column][row].hasBeenTouched {
            gameboard.spaceMatrix[column][row].hasBeenTouched = true
            
            do {
                let bombs = try gameboard.bombsNearCoordinate(column: column, row: row)
                sender.setTitle("\(bombs)", for: .normal)
            } catch {
                
            }
            
            if gameboard.spaceMatrix[column][row].hasBomb {
                self.gameState = .lose
                sender.setTitle("\u{1F4A3}", for: .normal)
            }
        }
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
        button.tintColor = UIColor.black
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.tag = tag
        return button
    }
}
