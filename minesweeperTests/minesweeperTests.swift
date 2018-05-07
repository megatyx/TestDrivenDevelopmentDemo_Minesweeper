//
//  minesweeperTests.swift
//  minesweeperTests
//
//  Created by Tyler Wells on 4/22/18.
//  Copyright © 2018 Tyler Wells. All rights reserved.
//

import XCTest
@testable import minesweeper

class minesweeperTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTooManyBombs() {
        
        XCTAssertNil(GameboardGenerator.generateGameboard(rows: 1, columns: 1, numberOfBombs: 10))
    }
    
    func testSpaceInit() {
        let touchableSpace = Space()
        XCTAssertNotNil(touchableSpace)
        XCTAssertFalse(touchableSpace.hasBeenTouched)
        XCTAssertFalse(touchableSpace.hasBomb)
    }
    
    func testGameboardGeneration() {
        let rows = 3
        let columns = 3
        let bombs = 7
        
        for columnsIndex in 0...columns-1 {
            for rowsIndex in 0...rows-1 {
                for bombIndex in 0...bombs-1 {
                    if rowsIndex > 0 && columnsIndex > 0 && bombIndex > 0 {
                        let spaces = rowsIndex * columnsIndex
                        if spaces > bombIndex {
                            if let gameboard = GameboardGenerator.generateGameboard(rows: rowsIndex, columns: columnsIndex, numberOfBombs: bombIndex) {
                                XCTAssertEqual(gameboard.numberOfBombs, bombIndex)
                                XCTAssertEqual(gameboard.rows, rowsIndex)
                                XCTAssertEqual(gameboard.columns, columnsIndex)
                                XCTAssert(gameboard.spaceMatrix.count > 0)
                                if gameboard.spaceMatrix.count > 0 {
                                    XCTAssert(gameboard.spaceMatrix[0].count > 0)
                                    XCTAssert((gameboard.spaceMatrix.count * gameboard.spaceMatrix[0].count) == (rowsIndex * columnsIndex))
                                    
                                    var bombCount = 0
                                    for thisRow in gameboard.spaceMatrix {
                                        for thisSpace in thisRow {
                                            
                                            if thisSpace.hasBomb{
                                                bombCount += 1
                                            }
                                        }
                                    }
                                    XCTAssertEqual(bombCount, bombIndex)
                                    
                                } else {XCTFail("empty column matrix")}
                            } else {
                                XCTFail()
                            }
                        } else {
                            XCTAssertNil(GameboardGenerator.generateGameboard(rows: rowsIndex, columns: columnsIndex, numberOfBombs: bombIndex))
                        }
                    } else {
                        XCTAssertNil(GameboardGenerator.generateGameboard(rows: rowsIndex, columns: columnsIndex, numberOfBombs: bombIndex))
                    }
                }
            }
        }
    }
    
    func testTouchGameboardSpace() {
        let rows = 3
        let columns = 2
        let bombs = 1
        if let gameboard = GameboardGenerator.generateGameboard(rows: rows, columns: columns, numberOfBombs: bombs) {
            
            let touchPoint = self.touchPointRandomInBounds(columnMax: columns, rowMax: rows)
            gameboard.spaceMatrix[touchPoint.0][touchPoint.1].hasBeenTouched = true
            
            var canBeTouched = false
            for row in gameboard.spaceMatrix {
                for space in row {
                    if space.hasBeenTouched {
                        canBeTouched = true
                    }
                }
            }
            XCTAssertTrue(canBeTouched)
        }
    }
    
    func testRunGame() {
        
        var randomColumnCount = Int(arc4random_uniform(UInt32(100)))
        var randomRowCount = Int(arc4random_uniform(UInt32(100)))
        
        randomColumnCount = (randomColumnCount > 0) ? randomColumnCount:2
        randomRowCount = (randomRowCount > 0) ? randomRowCount:1
        
        print("columns: \(randomColumnCount)")
        print("rows: \(randomRowCount)")
        
        let spaceCount = randomColumnCount * randomRowCount
        
        print("spaceCount: \(spaceCount)")
        
        var randomBombCount = Int(arc4random_uniform(UInt32(spaceCount - 1)))
        if randomBombCount == 0 {
            randomBombCount = 1
        }
        
        print("bombCount: \(randomBombCount)")
        
        if let gameboard = GameboardGenerator.generateGameboard(rows: randomRowCount, columns: randomColumnCount, numberOfBombs: randomBombCount) {
            
            var goodSpaceCount = spaceCount - gameboard.numberOfBombs
            print("goodSpaces: \(goodSpaceCount)")
            
            var gameFinished = false
            var gameLoopCount = 0
            repeat {
                gameLoopCount += 1
                print("On game loop: \(gameLoopCount) with \(goodSpaceCount) good spaces remaining")
                let touchPoint = self.touchPointRandomInBounds(columnMax: randomColumnCount, rowMax: randomRowCount)
                if !gameboard.spaceMatrix[touchPoint.0][touchPoint.1].hasBeenTouched {
                    goodSpaceCount -= 1
                    gameboard.spaceMatrix[touchPoint.0][touchPoint.1].hasBeenTouched = true
                    if goodSpaceCount < 1 {
                        gameFinished = true
                        print("game finished with no bombs")
                    }
                }
                if(gameboard.spaceMatrix[touchPoint.0][touchPoint.1].hasBomb) {
                    print("bombEncountered at \(touchPoint.0),\(touchPoint.1)")
                    gameFinished = true
                }
            } while (!gameFinished)
            
            XCTAssertTrue(gameFinished)
        } else{XCTFail("gameboard was not successfully generated")}
    }
    
    func testBombFindingAlgo() {
        let rows = 3
        let columns = 3
        let bombs = 1
        
        if let gameboard = GameboardGenerator.generateGameboard(rows: rows, columns: columns, numberOfBombs: bombs) {
            
            for row in gameboard.spaceMatrix {
                for space in row {
                    space.hasBomb = false
                }
            }
            do {
                let zeroCoordinateReturn = try gameboard.bombsNearCoordinate(column: 0, row: 0)
                XCTAssertTrue(zeroCoordinateReturn == 0)
                let middleCoordinateReturn = try gameboard.bombsNearCoordinate(column: 1, row: 1)
                XCTAssertTrue(middleCoordinateReturn == 0)
                let boundsCheckReturn = try gameboard.bombsNearCoordinate(column: 1, row: 2)
                XCTAssertTrue(boundsCheckReturn == 0)
                gameboard.spaceMatrix[1][2].hasBomb = true
                let oneCoordinateReturn = try gameboard.bombsNearCoordinate(column: 2, row: 2)
                XCTAssertTrue(oneCoordinateReturn == 1)
            } catch {
                
            }
            
            do {
                XCTAssertThrowsError(try gameboard.bombsNearCoordinate(column: 4, row: 4))
                XCTAssertNil(try? gameboard.bombsNearCoordinate(column: -1, row: -1))
            }
            
           
        }
    }
    
    func touchPointRandomInBounds(columnMax: Int, rowMax: Int) -> (Int,Int) {
        let randomColumn = Int(arc4random_uniform(UInt32(columnMax-1)))
        let randomRow = Int(arc4random_uniform(UInt32(rowMax-1)))
        return (randomColumn, randomRow)
    }
    
}
