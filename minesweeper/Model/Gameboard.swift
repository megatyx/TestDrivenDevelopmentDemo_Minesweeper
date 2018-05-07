//
//  Gameboard.swift
//  minesweeper
//
//  Created by Tyler Wells on 4/22/18.
//  Copyright © 2018 Tyler Wells. All rights reserved.
//

import Foundation

enum GameboardError: Error {
    case outOfBounds
    case invalidData
    case spacesLessThanBombs
}

class Gameboard {
    
    let rows: Int
    let columns: Int
    let numberOfBombs: Int
    let spaceMatrix: Array<Array<Space>>
    
    init(rows: Int, columns: Int, numberOfBombs: Int, spaceMatrix: Array<Array<Space>> = Array<Array<Space>>()) {
        self.rows = rows
        self.columns = columns
        self.numberOfBombs = numberOfBombs
        self.spaceMatrix = spaceMatrix
    }
    
    func bombsNearCoordinate(column: Int, row: Int, shouldCheckDiagonals: Bool = true) throws -> Int {
        if column > self.columns || row > self.rows || column < 0 || rows < 0 {
            throw GameboardError.outOfBounds
        }
        
        func checkCurrentColumn(column:Int, row: Int, diagonals: Bool = true) -> Int {
            var bombCount = 0
            
            if self.spaceMatrix[column][row].hasBomb {
                bombCount += 1
            }
            if row != 0 {
                if self.spaceMatrix[column][row-1].hasBomb && diagonals {
                    bombCount += 1
                }
            }
            if row != self.rows-1{
                if self.spaceMatrix[column][row+1].hasBomb && diagonals {
                    bombCount += 1
                }
            }
            return bombCount
        }
        
        var numberOfAdjacentBombs = checkCurrentColumn(column: column, row: row)
        if column != 0 {
            numberOfAdjacentBombs += checkCurrentColumn(column: column-1, row: row, diagonals: shouldCheckDiagonals)
        }
        if column != self.columns-1 {
            numberOfAdjacentBombs += checkCurrentColumn(column: column+1, row: row, diagonals: shouldCheckDiagonals)
        }
        return numberOfAdjacentBombs
    }
}
