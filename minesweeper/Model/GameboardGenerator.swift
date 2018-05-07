//
//  GameboardGenerator.swift
//  minesweeper
//
//  Created by Tyler Wells on 5/7/18.
//  Copyright © 2018 Tyler Wells. All rights reserved.
//

import Foundation

class GameboardGenerator {
    
    public class func generateGameboard(rows: Int, columns: Int, numberOfBombs: Int) -> Gameboard? {
        if GameboardGenerator.isValidGameData(rows: rows, columns: columns, numberOfBombs: numberOfBombs) {
            return Gameboard(rows: rows, columns: columns, numberOfBombs: numberOfBombs, spaceMatrix: GameboardGenerator.generateGameMatrix(rows: rows, columns: columns, numberOfBombs: numberOfBombs))
        } else {
            return nil
        }
    }
    
    fileprivate class func isValidGameData(rows: Int, columns: Int, numberOfBombs: Int) -> Bool {
        if rows > 0 && columns > 0 && numberOfBombs > 0 {
            let spaces = rows * columns
            if spaces > numberOfBombs {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    fileprivate class func generateGameMatrix(rows: Int, columns: Int, numberOfBombs: Int) -> Array<Array<Space>> {
        var bombRegistry = Array<(Int,Int)>()
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
        return resultArray
    }
}
