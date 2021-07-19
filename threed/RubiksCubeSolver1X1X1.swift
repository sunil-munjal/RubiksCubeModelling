//
//  RubiksCubeSolver1X1X1.swift
//  threed
//
//  Created by Sunil Munjal on 7/8/21.
//

import Foundation
import SceneKit

public class RubiksCubeSolver1X1X1 : RubiksCubeSolver {
    
    init(_ cube: RubiksCubeViewModel) {
    }
    
    func solve(_ model: RubiksCubeViewModel) {
        if model.rubiksCube.size != 1 {
            assert(false)
        }
        if model.rubiksCube.isSolvedCubbie(cubbie: 0) {
            
            model.highlightSet.insert(0)
            model.rubiksCube.incrementDummyCount()
        } else {
            model.highlightSet.insert(0)
            solveAnchor(model: model, anchor: 0)
        }
    }
    
    func solveAnchor(model: RubiksCubeViewModel, anchor: UInt) {
        model.highlightSet.removeAll()
        model.highlightSet.insert(Int(anchor))
        var solutionSet = Array<RubiksCube.Command>()
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(anchor)]
        var yaw = n.eulerAngles.z
        var pitch = n.eulerAngles.y
        var roll = n.eulerAngles.x
        var yawFace = abs(yaw)
        var pitchFace = abs(pitch)
        var rollFace = abs(roll)
        
        if (abs(roll - (Float.pi / 2)) < 0.01 && abs(pitch + (Float.pi / 2)) < 0.01) {
            if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                solutionSet.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-Float.pi / 2, -1, 0, 0))
            } else if (abs(Double(n.position.x) - model.rubiksCube.maxCord) < 0.01) {
                solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0))
            } else {
                // Something in middle
            }
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                solutionSet.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(Float.pi / 2, 0, 0, -1))
            } else if (abs(Double(n.position.z) - model.rubiksCube.maxCord) < 0.01) {
                solutionSet.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-Float.pi / 2, 0, 0, 1))
            } else {
                // something in middle
            }
            return model.playSolution(solutionSet, nil)
            
        }
        
        if ((yawFace) > 0.01)  {
            var direction = (yaw < 0) ? RubiksCube.Direction.ANTICLOCKWISE : RubiksCube.Direction.CLOCKWISE

            if (abs(yawFace - 1.5 * Float.pi) < 0.01 ) {
                yawFace = 0.5 * Float.pi
                if (yaw < 0) {
                    yaw += 2 * Float.pi
                } else {
                    yaw -= 2 * Float.pi
                }
                direction = direction.compliment()
            }
            if (abs(yawFace - (Float.pi / 2)) < 0.01) {
                if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .BACK, direction: direction.compliment()))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(yaw, 0, 0, -1))
                } else if (abs(Double(n.position.z) - model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .FRONT, direction: direction))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-yaw, 0, 0, 1))
                } else {
                    if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE))
                    } else if (abs(Double(n.position.y) - model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    }
                    return model.playSolution(solutionSet, nil)
                    
                    
                }
            } else if (abs(yawFace - Float.pi) < 0.01) {
                if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .BACK, direction: direction.compliment()))
                    solutionSet.append(RubiksCube.Command(face: .BACK, direction: direction.compliment()))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(yaw, 0, 0, -1))
                } else if (abs(Double(n.position.z) - model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .FRONT, direction: direction))
                    solutionSet.append(RubiksCube.Command(face: .FRONT, direction: direction))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-yaw, 0, 0, 1))
                } else {
                    if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE))
                        solutionSet.append(RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE))

                    } else if (abs(Double(n.position.y) - model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solutionSet.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    }
                    return model.playSolution(solutionSet, nil)
                    
                }
            } else {
                print ("ERROR in yaw ....")
            }
        }
        if ((pitchFace) > 0.01)  {
            var direction = (pitch > 0) ? RubiksCube.Direction.ANTICLOCKWISE : RubiksCube.Direction.CLOCKWISE

            if (abs(pitchFace - 1.5 * Float.pi) < 0.01 ) {
                pitchFace = 0.5 * Float.pi
                if (pitch < 0) {
                    pitch += 2 * Float.pi
                } else {
                    pitch -= 2 * Float.pi
                }
                direction = direction.compliment()
            }
            if (abs(pitchFace - (Float.pi / 2)) < 0.01) {
                if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .DOWN, direction: direction.compliment()))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-pitch, 0, -1, 0))
                } else if (abs(Double(n.position.y) - model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .UP, direction: direction))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(pitch, 0, 1, 0))
                } else {
                    if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))

                    } else if (abs(Double(n.position.x) - model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                    }
                    return model.playSolution(solutionSet, nil)
                    
                }
            } else if (abs(pitchFace - Float.pi) < 0.01) {
                if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .DOWN, direction: direction.compliment()))
                    solutionSet.append(RubiksCube.Command(face: .DOWN, direction: direction.compliment()))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-pitch, 0, -1, 0))
                } else if (abs(Double(n.position.y) - model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .UP, direction: direction))
                    solutionSet.append(RubiksCube.Command(face: .UP, direction: direction))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(pitch, 0, 1, 0))
                } else {
                    if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                        solutionSet.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))

                    } else if (abs(Double(n.position.x) - model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                        solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                    }
                    return model.playSolution(solutionSet, nil)
                    
                }
            } else {
                print ("ERROR in pitch ....")
            }
        }
        if ((rollFace) > 0.01)  {
            var direction = (roll < 0) ? RubiksCube.Direction.ANTICLOCKWISE : RubiksCube.Direction.CLOCKWISE
            if (abs(rollFace - 1.5 * Float.pi) < 0.01 ) {
                rollFace = 0.5 * Float.pi
                if (roll < 0) {
                    roll += 2 * Float.pi
                } else {
                    roll -= 2 * Float.pi
                }
                direction = direction.compliment()
            }
            
            if (abs(rollFace - (Float.pi / 2)) < 0.01) {
                if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .LEFT, direction: direction.compliment()))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(roll, -1, 0, 0))
                } else if (abs(Double(n.position.x) - model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: direction))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-roll, 1, 0, 0))
                } else {
                    if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))

                    } else if (abs(Double(n.position.z) - model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                    }
                    return model.playSolution(solutionSet, nil)
                    
                }
            } else if (abs(rollFace - Float.pi) < 0.01) {
                if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .LEFT, direction: direction.compliment()))
                    solutionSet.append(RubiksCube.Command(face: .LEFT, direction: direction.compliment()))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(roll, -1, 0, 0))
                } else if (abs(Double(n.position.x) - model.rubiksCube.maxCord) < 0.01) {
                    solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: direction))
                    solutionSet.append(RubiksCube.Command(face: .RIGHT, direction: direction))
                    n.transform = SCNMatrix4Mult(n.transform, SCNMatrix4MakeRotation(-roll, 1, 0, 0))
                } else {
                    if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                        solutionSet.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))

                    } else if (abs(Double(n.position.z) - model.rubiksCube.maxCord) < 0.01) {
                        solutionSet.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                        solutionSet.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                    }
                    return model.playSolution(solutionSet, nil)
                    
                }
            } else {
                print ("ERROR in roll ....")
            }
        }
        return model.playSolution(solutionSet, nil)
    }
    
    
}
