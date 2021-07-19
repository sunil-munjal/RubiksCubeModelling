//
//  RubiksCubeViewModel.swift
//  threed
//
//  Created by Sunil Munjal on 6/30/21.
//

import Foundation
import SwiftUI
import SceneKit


class RubiksCubeViewModel: ObservableObject {
    @Published var rubiksCube = RubiksCube(size: 3)
    
    var playingSolution = false
    var solutionIndex = 0
    var solution: Array<RubiksCube.Command>? = nil
    var solutionCallback: (()->Void)?
    var solver: RubiksCubeSolver? = nil
    var turnlock: Bool {
        turnlockCount != 0
    }
    
    var turnlockCount = 0
    
    var commmandHistory = [RubiksCube.Command]()

    var numMoves: Int {
        commmandHistory.count
    }
    var highlightSet = Set<Int>()

    init() {
        if (rubiksCube.size == 1) {
            solver = RubiksCubeSolver1X1X1(self)
        }
        if (rubiksCube.size == 2) {
            solver = RubiksCubeSolver2X2X2(self)
        }
        if (rubiksCube.size == 3) {
            solver = RubiksCubeSolver3X3X3(self)
        }
        if (rubiksCube.size == 4) {
            solver = RubiksCubeSolver4X4X4(self)
        }
        
    }

    
    func incrementAndDispatch() {
        if (solution != nil) {
            solutionIndex += 1
            if (solutionIndex < solution!.count) {
                DispatchQueue.global(qos: .userInitiated).async(execute: {
                    if (self.solutionIndex == 0) {
                        DispatchQueue.main.async  {
                            self.rubiksCube.incrementDummyCount()
                        }
                    }
                    usleep(UInt32(500000))
                    if (self.solution!.count > self.solutionIndex) {
                        DispatchQueue.main.async  {
                            self.turn(face: self.solution![self.solutionIndex].face, direction: self.solution![self.solutionIndex].direction, removeHighlights: false, self.incrementAndDispatch)
                        }
                        usleep(UInt32(500000))

                    }
                })
                
            } else {
                DispatchQueue.global(qos: .userInitiated).async(execute: {
                   
                    usleep(UInt32(500000))
                    
                    DispatchQueue.main.async  {
                        self.highlightSet.removeAll()
                        
                        self.solution = nil
                        self.solutionIndex = -1
                        self.playingSolution = false
                        self.rubiksCube.incrementDummyCount()
                        self.playingSolution = false
                        if self.solutionCallback != nil {
                            let callback = self.solutionCallback!
                            self.solutionCallback = nil
                            callback()
                        }

                    }
                    
                })
            }
        }
    }
    
    func playSolution(_ solution: Array<RubiksCube.Command>, _ callback: (()->Void)? ) {
        playingSolution = true
        solutionIndex = -1
        self.solution = solution
        self.solutionCallback = callback
        incrementAndDispatch()
        
    }
    func turn(face : RubiksCube.Face,  direction : RubiksCube.Direction,  _ turnCompletedCallBack : @escaping (()->(Void)))  {
        if (!playingSolution) {
            turn(face: face, direction: direction, removeHighlights: true, turnCompletedCallBack)
        }
    }
    func turn(face : RubiksCube.Face,  direction : RubiksCube.Direction, removeHighlights: Bool,  _ turnCompletedCallBack : @escaping (()->(Void)))  {
        if (!turnlock) {
            turnlockCount += 1
            if (removeHighlights) {
                highlightSet.removeAll()
            }
            let tenms = UInt32(10000)
            push(face, direction)
            DispatchQueue.global(qos: .userInitiated).async(execute: {
                let angle = Float.pi * 0.05
                switch face {
                case .UP:
                    for i in 1...10 {
                        DispatchQueue.main.sync  {
                            self.rubiksCube.turnY(face: face, angleRad: angle, direction: direction)
                            if (i == 10) {
                                self.turnlockCount -= 1
                                turnCompletedCallBack()
                            }
                        }
                        
                        usleep(tenms)
                    }
                case .DOWN:
                    for i in 1...10 {
                        DispatchQueue.main.sync  {
                            self.rubiksCube.turnY(face: face, angleRad: angle, direction: direction)
                            if (i == 10) {
                                self.turnlockCount -= 1
                                turnCompletedCallBack()
                            }
                        }
                        
                        usleep(tenms)
                    }
                case .LEFT:
                    for i in 1...10 {
                        DispatchQueue.main.sync  {
                            self.rubiksCube.turnX(face: face, angleRad: angle, direction: direction)
                            if (i == 10) {
                                self.turnlockCount -= 1
                                turnCompletedCallBack()
                            }
                        }
                        
                        usleep(tenms)
                    }
                case .RIGHT:
                    for i in 1...10 {
                        DispatchQueue.main.sync  {
                            self.rubiksCube.turnX(face: face, angleRad: angle, direction: direction)
                            if (i == 10) {
                                self.turnlockCount -= 1
                                turnCompletedCallBack()
                            }
                        }
                        
                        usleep(tenms)
                    }

                case .FRONT:
                    for i in 1...10 {
                        DispatchQueue.main.sync  {
                            self.rubiksCube.turnZ(face: face, angleRad: angle, direction: direction)
                            if (i == 10) {
                                self.turnlockCount -= 1
                                turnCompletedCallBack()
                            }
                        }
                        
                        usleep(tenms)
                    }
                case .BACK:
                    for i in 1...10 {
                        DispatchQueue.main.sync  {
                            self.rubiksCube.turnZ(face: face, angleRad: angle, direction: direction)
                            if (i == 10) {
                                self.turnlockCount -= 1
                                turnCompletedCallBack()
                            }
                        }
                        
                        usleep(tenms)
                    }
                }
                
            })
        }
    }
    
    func push(_ face: RubiksCube.Face, _ direction: RubiksCube.Direction) {
        commmandHistory.append(RubiksCube.Command(face: face, direction: direction))
    }
    
    func pop() {
        if (commmandHistory.count > 0 && !turnlock) {
            let command = commmandHistory.removeLast()
            
            turn(face: command.face,  direction: command.direction.compliment(), {})
                
            commmandHistory.removeLast()
            
        }
    }
    
    
    
    
    func solve() {
        if (playingSolution) {
            return
        }
        if (solver != nil) {
            solver?.solve(self)
        }
    }
    
    func scamble(_ count: UInt) {
        if (playingSolution || turnlock) {
            return
        }
        highlightSet.removeAll()
        var scrampleSet =  Array<RubiksCube.Command>()
        for _ in 1...count {
            let randomInt = Int.random(in: 0..<12)
            let commandNumber = randomInt / 2
            let directionNumber = randomInt % 2
            scrampleSet.append(RubiksCube.Command(face: RubiksCube.Face.fromInt(commandNumber), direction: RubiksCube.Direction.fromInt(directionNumber)))
        }
        self.playSolution(scrampleSet, nil)
    }
}
