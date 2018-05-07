//
//  InitialViewController.swift
//  minesweeper
//
//  Created by Tyler Wells on 5/2/18.
//  Copyright © 2018 Tyler Wells. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    var gameboard: Gameboard!
    
    @IBOutlet weak var ColumnsTextField: UITextField!
    @IBOutlet weak var RowsTextField: UITextField!
    @IBOutlet weak var BombsTextField: UITextField!
    
    @IBAction func GenerateMinefieldButtonAction(_ sender: UIButton) {
        
        do {
            let thisgameboard = try validateUserInput()
            self.gameboard = thisgameboard
            self.performSegue(withIdentifier: "ToGameView", sender: self)
        } catch let error{
            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            switch error {
            case UserEntryError.emptyStrings:
                alert.title = "Empty Fields"
                alert.message = "Please make sure to enter something in every field"
            case UserEntryError.invalidIntegers:
                alert.title = "Invalid Entry"
                alert.message = "Columns, Rows, and Bombs should not be zero, and the amount of spaces (rows * columns) should be greater than the number of bombs. Please make these corrections and try again."
            default:
                alert.title = "Unknown Error"
                alert.message = "There was an uknown issue. Please try again with different parameters."
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    enum UserEntryError: Error {
        case invalidIntegers
        case emptyStrings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destVC = segue.destination as? GameViewController {
            destVC.gameboard = self.gameboard
        }
    }

    func validateUserInput() throws -> Gameboard {
        guard let columnsText: String = ColumnsTextField.text, let rowsText: String = RowsTextField.text, let bombsText: String = BombsTextField.text, !columnsText.isEmpty && !rowsText.isEmpty && !bombsText.isEmpty else {
            throw UserEntryError.emptyStrings
        }
        
        if let columns = Int(columnsText), let rows = Int(rowsText), let bombs = Int(bombsText), columns > 0 && rows > 0 && bombs > 0, rows * columns > bombs {
            if let gameboard = GameboardGenerator.generateGameboard(rows: rows, columns: columns, numberOfBombs: bombs) {
                return gameboard
            } else {
                throw UserEntryError.invalidIntegers
            }
        } else {
            throw UserEntryError.invalidIntegers
        }
    }
}
