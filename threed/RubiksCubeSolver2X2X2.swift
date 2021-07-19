//
//  RubiksCubeSolver2X2X2.swift
//  threed
//
//  Created by Sunil Munjal on 7/8/21.
//

import Foundation
import SceneKit

public class RubiksCubeSolver2X2X2 : RubiksCubeSolver1X1X1 {
    
    var layer1Corners = Array<UInt>()
    var upperLayerCorners = Array<UInt>()
    var callbackModel: RubiksCubeViewModel? = nil
    var numIterations: Int? = nil
    var lastIterationCallback: (()->Void)? = nil
    var iterateFromFace : RubiksCube.Face? = nil
    var iterateMirrorX : Bool? = nil
    
    override init(_ cube: RubiksCubeViewModel) {
        super.init(cube)
        let n = SCNNode()
        for index in cube.rubiksCube.cubbieOriginals.indices {
            n.transform = cube.rubiksCube.cubbieOriginals[index]
            let position = n.position
            let fX = abs(Double(position.x))
            let fZ = abs(Double(position.z))
            if (abs(Double(position.y) + cube.rubiksCube.maxCord) < 0.01) {
                
                if ( abs(fX - cube.rubiksCube.maxCord) < 0.01 &&
                   abs(fZ - cube.rubiksCube.maxCord) < 0.01) {
                    layer1Corners.append(UInt(index))
                }
            } else if (abs(Double(position.y) - cube.rubiksCube.maxCord) < 0.01) {
                if ( abs(fX - cube.rubiksCube.maxCord) < 0.01 &&
                       abs(fZ - cube.rubiksCube.maxCord) < 0.01) {
                    upperLayerCorners.append(UInt(index))
                }
            }
        }
        
        print(" Layer 1 Corners - \(layer1Corners[0]), \(layer1Corners[1]),  \(layer1Corners[2]), \(layer1Corners[3])")
        print(" Upper Layer  Corners - \(upperLayerCorners[0]), \(upperLayerCorners[1]),  \(upperLayerCorners[2]), \(upperLayerCorners[3])")
    }
    func getLowerLeftBackCorner() -> UInt {
        layer1Corners[0]
    }
    func getLowerLeftFrontCorner() -> UInt {
        layer1Corners[1]
    }
    func getLowerRightBackCorner() -> UInt {
        layer1Corners[2]
    }
    func getLowerRightFrontCorner() -> UInt {
        layer1Corners[3]
    }
    func getUpperLeftBackCorner() -> UInt {
        upperLayerCorners[0]
    }
    func getUpperLeftFrontCorner() -> UInt {
        upperLayerCorners[1]
    }
    func getUpperRightBackCorner() -> UInt {
        upperLayerCorners[2]
    }
    func getUpperRightFrontCorner() -> UInt {
        upperLayerCorners[3]
    }
    func upperRightFrontCorner(model: RubiksCubeViewModel) -> UInt {
        let n = SCNNode()
        for cubbie in upperLayerCorners {
            n.transform = model.rubiksCube.cubbieTransforms[Int(cubbie)]
            if (abs(Double(n.position.x) - model.rubiksCube.maxCord) < 0.01) {
                if (abs(Double(n.position.z) - model.rubiksCube.maxCord) < 0.01) {
                    return cubbie
                }
            }
        }
        return 0
    }
    override func solve(_ model: RubiksCubeViewModel) {
        if model.rubiksCube.size != 2 {
            assert(false)
        }
        
       
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerLeftBackCorner())) {
            //solveAnchor(model: model, anchor: getLowerLeftBackCorner())
            return solveLowerLeftBackCorner(model: model,  lowerLayerLocked: false, getLowerLeftBackCorner())
            
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerLeftFrontCorner())) {
            return solveLowerLeftFrontCorner(model: model, lowerLayerLocked: false, getLowerLeftFrontCorner())
            
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerRightBackCorner())) {
            return solveLowerRightBackCorner(model: model, lowerLayerLocked: false, getLowerRightBackCorner())
            
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerRightFrontCorner())) {
            return solveLowerRightFrontCorner(model: model, lowerLayerLocked: false, getLowerRightFrontCorner())
            
        }
        
        if (!model.rubiksCube.isInPositionCubbie(cubbie: getUpperLeftBackCorner())) {
            return getUpperCubbieInPosition(model: model, getUpperLeftBackCorner())
        }
        if (!areUpperLayerCornersInPosition(model: model)) {
            return positionUpperLayerCornersFor2x2(model: model)
        }
        if (!model.rubiksCube.isSolvedCubbies(cubbies: upperLayerCorners)) {
            return orientUpperLayerCornersFor2x2(model: model)
        }
        for index in model.rubiksCube.cubbieOriginals.indices {
            model.highlightSet.insert(index)
        }
        model.rubiksCube.incrementDummyCount()
    }
    func anchorleftCorner() {
        if (callbackModel != nil) {
            let model = callbackModel!
            callbackModel = nil
            return getUpperCubbieInPosition(model: model, getUpperLeftBackCorner())
        }
    }
    
    func orientUpperLayerCornersFor2x2(model: RubiksCubeViewModel) {
        numIterations = Int(3)
        callbackModel = model
        positionAndIterate()
    }
    
    func positionAndIterate() {
        if (callbackModel != nil && numIterations != nil) {
            let model = callbackModel!
            let iteration = numIterations!
            if (iteration > 0) {
                let cubbie = upperRightFrontCorner(model: model)
                if (model.rubiksCube.isOrientedCubbie(cubbie: cubbie)) {
                    let solution  = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
                    return model.playSolution(solution, positionAndIterate)
                } else {
                    model.highlightSet.insert(Int(cubbie))
                    numIterations = Int( iteration - 1 )
                    let solution  =
                        [
                            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .DOWN, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE),
                            RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE),
                            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .DOWN, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE),
                            RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE)
                        ]
                    return model.playSolution(solution, positionAndIterate)
                }
            }
            numIterations = nil
            return anchorleftCorner()
        }
        
        callbackModel = nil
        numIterations = nil
    }
    
    func iterateUpperLayerFURURF() {
        if (callbackModel != nil && numIterations != nil) {
            let model = callbackModel!
            let iteration = numIterations!
            let face = iterateFromFace!
            let mirrorX = iterateMirrorX!
            if (iteration > 0) {
                numIterations = Int(iteration - 1)
                let solution = [
                    RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX)]
                return model.playSolution(solution, iterateUpperLayerFURURF)
            }
            numIterations = nil
            iterateFromFace = nil
            iterateMirrorX = nil
            if (lastIterationCallback != nil) {
                let callback = lastIterationCallback!
                lastIterationCallback = nil
                return callback()
            }
            
            
        }
        numIterations = nil
        callbackModel = nil
        lastIterationCallback = nil
        iterateFromFace = nil
    }
    
    func applyIterateUpperLayerFURURF(model: RubiksCubeViewModel, from face: RubiksCube.Face, mirrorX: Bool, iterations : Int, callback : (()->Void)? ) {
        numIterations = Int(iterations)
        callbackModel = model
        lastIterationCallback = callback
        iterateFromFace = face
        iterateMirrorX = mirrorX
        iterateUpperLayerFURURF()
    }
    
    
    func iterateUpperLayerFRURUF() {
        if (callbackModel != nil && numIterations != nil) {
            let model = callbackModel!
            let iteration = numIterations!
            let face = iterateFromFace!
            let mirrorX = iterateMirrorX!
            if (iteration > 0) {
                numIterations = Int(iteration - 1)
                let solution = [
                    RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
                    RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX)]
                return model.playSolution(solution, iterateUpperLayerFRURUF)
            }
            numIterations = nil
            iterateFromFace = nil
            iterateMirrorX = nil
            if (lastIterationCallback != nil) {
                let callback = lastIterationCallback!
                lastIterationCallback = nil
                return callback()
            }
            callbackModel = nil
            
        }
        numIterations = nil
        callbackModel = nil
        lastIterationCallback = nil
        iterateFromFace = nil
        iterateMirrorX = nil
    }
    
    func applyIterateUpperLayerFRURUF(model: RubiksCubeViewModel, from face: RubiksCube.Face, mirrorX: Bool, iterations : Int, callback : (()->Void)? ) {
        numIterations = Int(iterations)
        callbackModel = model
        lastIterationCallback = callback
        iterateFromFace = face
        iterateMirrorX = mirrorX
        iterateUpperLayerFRURUF()
    }
    
    func apply3CornerPlacementWithBackRightAnchorFromFace(model: RubiksCubeViewModel, face: RubiksCube.Face, callback : (()->Void)? ) {
        return apply3CornerPlacementWithBackLeftAnchorFromFace(model: model, face: face, mirrorY : true, callback : callback )
    }
    
    func apply3CornerPlacementWithBackLeftAnchorFromFace(model: RubiksCubeViewModel, face: RubiksCube.Face, mirrorY : Bool, callback : (()->Void)? ) {
       // R B" R F2 R" B R F2 R2
        let solution = [
            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .BACK, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY)]
        
        if (callback != nil) {
            callbackModel = model
        } else {
            callbackModel = nil
        }
        return model.playSolution(solution, callback)
    }
    
    func apply3CornerPlacementWithFrontLeftAnchorFromFace(model: RubiksCubeViewModel, face: RubiksCube.Face, callback : (()->Void)? ) {
        return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: face, mirrorY : true, callback : callback )
    }
    
    func apply3CornerPlacementWithFrontRightAnchorFromFace(model: RubiksCubeViewModel, face: RubiksCube.Face, mirrorY : Bool, callback : (()->Void)? ) {
       // U R U" L" U R" U" L
        let solution = [
            RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorY(mirrorY),
            RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE).fromFace(face: face).mirrorY(mirrorY)]
        if (callback != nil) {
            callbackModel = model
        } else {
            callbackModel = nil
        }
        return model.playSolution(solution, callback)
    }
    
    func positionUpperLayerCornersFor2x2(model: RubiksCubeViewModel) {
        //var solution = Array<RubiksCube.Command>()
        
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperLeftFrontCorner())) {
            model.highlightSet.insert(Int(getUpperRightBackCorner()))
            model.highlightSet.insert(Int(getUpperRightFrontCorner()))
            return apply3CornerPlacementWithBackLeftAnchorFromFace(model: model, face: .LEFT, mirrorY: false, callback: anchorleftCorner)
            
        }
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperRightBackCorner())) {
            model.highlightSet.insert(Int(getUpperLeftFrontCorner()))

            model.highlightSet.insert(Int(getUpperRightFrontCorner()))
            return apply3CornerPlacementWithBackLeftAnchorFromFace(model: model, face: .BACK, mirrorY: false, callback: anchorleftCorner)
        }
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperRightFrontCorner())) {
            model.highlightSet.insert(Int(getUpperLeftFrontCorner()))
            model.highlightSet.insert(Int(getUpperRightBackCorner()))

            return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: false, iterations : 1, callback : anchorleftCorner)
        }
        model.highlightSet.insert(Int(getUpperLeftFrontCorner()))
        model.highlightSet.insert(Int(getUpperRightBackCorner()))
        model.highlightSet.insert(Int(getUpperRightFrontCorner()))
        return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: .BACK, mirrorY: false, callback: nil)


    }
    func areUpperLayerCornersInPosition(model: RubiksCubeViewModel) -> Bool {
        for cubbie in upperLayerCorners {
            if (!model.rubiksCube.isInPositionCubbie(cubbie: cubbie)) {
                return false
            }
        }
        return true
    }
    func getUpperCubbieInPosition(model: RubiksCubeViewModel, _ cubbie: UInt) {
        let n = SCNNode()
        model.highlightSet.insert(Int(cubbie))
        n.transform = model.rubiksCube.cubbieTransforms[Int(cubbie)]
        let currentPosition = n.position
        n.transform = model.rubiksCube.cubbieOriginals[Int(cubbie)]
        let originalPosition = n.position
        //var solution = Array<RubiksCube.Command>()
        if (abs(Double(originalPosition.x) + model.rubiksCube.maxCord) < 0.01) {
            if (abs(Double(originalPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                
                if (abs(Double(currentPosition.x) + model.rubiksCube.maxCord) < 0.01) {
                    if (abs(Double(currentPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                        return
                    }
                    let solution = [
                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
                    return model.playSolution(solution, nil)
                } else {
                    if (abs(Double(currentPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                        return model.playSolution(solution, nil)
                    } else {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                        return model.playSolution(solution, nil)
                    }
                }
                
            } else {
                
                if (abs(Double(currentPosition.x) + model.rubiksCube.maxCord) < 0.01) {
                    let solution = [
                        RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                    return model.playSolution(solution, nil)
                } else {
                    if (abs(Double(currentPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                        return model.playSolution(solution, nil)
                    } else {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
                        return model.playSolution(solution, nil)
                    }
                }
                
            }
        } else {
            if (abs(Double(originalPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                
                if (abs(Double(currentPosition.x) - model.rubiksCube.maxCord) < 0.01) {
                    let solution = [
                        RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                    return model.playSolution(solution, nil)
                } else {
                    if (abs(Double(currentPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
                        return model.playSolution(solution, nil)
                    } else {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                        return model.playSolution(solution, nil)
                    }
                }
                
            } else {
                
                if (abs(Double(currentPosition.x) - model.rubiksCube.maxCord) < 0.01) {
                    let solution = [
                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
                    return model.playSolution(solution, nil)
                } else {
                    if (abs(Double(currentPosition.z) + model.rubiksCube.maxCord) < 0.01) {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                        return model.playSolution(solution, nil)
                    } else {
                        let solution = [
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
                        return model.playSolution(solution, nil)
                    }
                }
                
            }
        }
        
    }
    func solveLowerLeftBackCorner(model: RubiksCubeViewModel, lowerLayerLocked: Bool, _ cubbie: UInt) {
        if (!lowerLayerLocked) {
            return solveAnchor(model: model, anchor: cubbie)
            
        }
        model.highlightSet.insert(Int(cubbie))
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(cubbie)]
        var solution = Array<RubiksCube.Command>()
        if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
        
            if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                    if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                        solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE))
                    }
                } else {
                    if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                    }
                }
            } else {
                // Right side of Cube
                if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                    // back
                    if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                        
                    } else {
                        solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                    }
                } else {
                    // front
                    if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                    }
                }
            }
            
            return model.playSolution(solution, nil)
            
        }
        
        if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                // Correct Position
                if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.z - 0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                } else if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.x - 0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE))

                } else {
                    solution.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE))
                    
                }
            } else {
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                
            }
        } else {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
           
            } else {
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))

          
            }
        }
        return model.playSolution(solution, nil)
        
    }
    
    func solveLowerLeftFrontCorner(model: RubiksCubeViewModel, lowerLayerLocked: Bool, _ cubbie: UInt) {
        model.highlightSet.insert(Int(cubbie))
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(cubbie)]
        var solution = Array<RubiksCube.Command>()
        if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
            
            if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
                // Left Side of Cube
                if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                    if (lowerLayerLocked) {
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    }
                } else {
                    solution.append(RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                }
            } else {
                // Right side of Cube
                if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                    // back
                    if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                        solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                        if (lowerLayerLocked) {
                            solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                            solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                        }
                    }
                } else {
                    // front
                    if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                        if (lowerLayerLocked) {
                            solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                            solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                        }
                    } else {
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                        if (lowerLayerLocked) {
                            solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                            solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                        }
                    }
                }
            }
            
            return model.playSolution(solution, nil)
            
        }
        
        if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                
            } else {
                // Correct position
                if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.z - 0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                } else if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.x - 0) < 0.01) {
                    if (lowerLayerLocked) {
                        solution.append(RubiksCube.Command(face: .LEFT, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .LEFT, direction: .CLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    }
                } else {
                    if (lowerLayerLocked) {
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    }
                }
            }
        } else {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
           
            } else {
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
          
            }
        }
        return model.playSolution(solution, nil)
        
    }
    
    func solveLowerRightBackCorner(model: RubiksCubeViewModel, lowerLayerLocked: Bool, _ cubbie: UInt) {
        model.highlightSet.insert(Int(cubbie))
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(cubbie)]
        var solution = Array<RubiksCube.Command>()
        if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
            
            // Right side of Cube
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                // back
                if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                    if (lowerLayerLocked) {
                        solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                    }
                    
                        
                } else {
                    solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                }
            } else {
                // front
                if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                                               
                } else {
                    solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                    if (lowerLayerLocked) {
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                    }
                }
            }
            
            
            return model.playSolution(solution, nil)
            
        }
        
        if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                
            } else {
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
            }
        } else {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                // Correct position
                if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.z - 0) < 0.01) {
                    if (lowerLayerLocked) {
                        solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                        solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                    } else {
                        solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                    }
                    
                } else if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.x - 0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                } else {
                    solution.append(RubiksCube.Command(face: .BACK, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .BACK, direction: .ANTICLOCKWISE))
                }
                
           
            } else {
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
          
            }
        }
        return model.playSolution(solution, nil)
        
    }
    
    func solveLowerRightFrontCorner(model: RubiksCubeViewModel, lowerLayerLocked: Bool, _ cubbie: UInt) {
        model.highlightSet.insert(Int(cubbie))
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(cubbie)]
        var solution = Array<RubiksCube.Command>()
        if (abs(Double(n.position.y) + model.rubiksCube.maxCord) < 0.01) {
            
            // Right side of Cube
            
            // front
            if (abs(n.eulerAngles.y - 0.0) < 0.01) {
                solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                                               
            } else {
                solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
            }
                
            return model.playSolution(solution, nil)
            
        }
        
        if (abs(Double(n.position.x) + model.rubiksCube.maxCord) < 0.01) {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                
            } else {
                solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
            }
        } else {
            if (abs(Double(n.position.z) + model.rubiksCube.maxCord) < 0.01) {
                
                solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
           
            } else {
                // Correct position
    
          
                if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.z - 0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))


                    
                } else if (abs(n.eulerAngles.y - 0) < 0.1 && abs(n.eulerAngles.x - 0) < 0.01) {
                    solution.append(RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE))
                } else {
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .ANTICLOCKWISE))
                    solution.append(RubiksCube.Command(face: .UP, direction: .CLOCKWISE))
                    solution.append(RubiksCube.Command(face: .FRONT, direction: .CLOCKWISE))
                    
                }
            }
        }
        return model.playSolution(solution, nil)
        
    }
}
