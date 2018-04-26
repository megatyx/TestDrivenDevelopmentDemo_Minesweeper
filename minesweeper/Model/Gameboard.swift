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
}

class Gameboard {
    
    let rows: Int
    let columns: Int
    let numberOfBombs: Int
    
    var spaceMatrix = Array<Array<Space>>()
    
    init?(rows: Int, columns: Int, numberOfBombs: Int) {
        if rows > 0 && columns > 0 && numberOfBombs > 0 {
            let spaces = rows * columns
            if spaces > numberOfBombs {
                self.rows = rows
                self.columns = columns
                self.numberOfBombs = numberOfBombs
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func generateGameMatrix() {
        var bombRegistry = Array<(Int,Int)>()
        print(numberOfBombs)
        repeat {
            let randomRow = Int(arc4random_uniform(UInt32(rows)))
            let randomColumn = Int(arc4random_uniform(UInt32(columns)))
            let randomTuple = (randomColumn, randomRow)
            if !bombRegistry.contains(where: {$0 == randomTuple}){
                bombRegistry.append(randomTuple)
            }
        } while (bombRegistry.count < numberOfBombs)
        
        var resultArray = Array<Array<Space>>()
        for columnIndex in 0...columns-1 {
            var spaceArray = Array<Space>()
            for rowIndex in  0...rows-1 {
                let space = Space()
                if bombRegistry.contains(where: {$0 == (columnIndex, rowIndex)}) {
                    space.hasBomb = true
                }
                spaceArray.append(space)
            }
            resultArray.append(spaceArray)
        }
        self.spaceMatrix = resultArray
    }
    
    func bombsNearCoordinate(column: Int, row: Int) throws -> Int {
        if column > self.columns || row > self.rows || column < 0 || rows < 0 {
            throw GameboardError.outOfBounds
        }
        
        func checkCurrentColumn(column:Int, row: Int) -> Int {
            var bombCount = 0
            
            if self.spaceMatrix[column][row].hasBomb {
                bombCount += 1
            }
            if row != 0 {
                if self.spaceMatrix[column][row-1].hasBomb {
                    bombCount += 1
                }
            }
            if row != self.rows-1{
                if self.spaceMatrix[column][row+1].hasBomb {
                    bombCount += 1
                }
            }
            return bombCount
        }
        
        var numberOfAdjacentBombs = checkCurrentColumn(column: column, row: row)
        if column != 0 {
            numberOfAdjacentBombs += checkCurrentColumn(column: column-1, row: row)
        }
        if column != self.columns-1 {
            numberOfAdjacentBombs += checkCurrentColumn(column: column+1, row: row)
        }
        return numberOfAdjacentBombs
    }
}
