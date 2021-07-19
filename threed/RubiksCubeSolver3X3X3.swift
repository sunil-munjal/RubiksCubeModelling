//
//  RubiksCubeSolver3X3X3.swift
//  threed
//
//  Created by Sunil Munjal on 7/8/21.
//

import Foundation
import SceneKit

public class RubiksCubeSolver3X3X3 : RubiksCubeSolver2X2X2 {
    var layer1Edges = Array<UInt>()
    var middleLayerEdges = Array<UInt>()
    var upperLayerEdges = Array<UInt>()
    
    override init(_ cube: RubiksCubeViewModel) {
        super.init(cube)
        let n = SCNNode()
        for index in cube.rubiksCube.cubbieOriginals.indices {
            n.transform = cube.rubiksCube.cubbieOriginals[index]
            let position = n.position
            let fX = abs(Double(position.x))
            let fY = abs(Double(position.y))
            let fZ = abs(Double(position.z))
            
            if (abs(Double(position.y) + cube.rubiksCube.maxCord) < 0.01) {
                
               if ( ( abs(fX - cube.rubiksCube.maxCord) < 0.01 ||
                      abs(fZ - cube.rubiksCube.maxCord) < 0.01)  &&
                    ( (cube.rubiksCube.maxCord - fX) > 0.01 ||
                      (cube.rubiksCube.maxCord - fZ) > 0.01))
                {
                    layer1Edges.append(UInt(index))
                        
                    //cube.highlightSet.insert(index)
                }
            } else if ((abs(Double(n.position.y) - cube.rubiksCube.maxCord) < 0.01)) {
                if ( ( abs(fX - cube.rubiksCube.maxCord) < 0.01 ||
                       abs(fZ - cube.rubiksCube.maxCord) < 0.01)  &&
                     ( (cube.rubiksCube.maxCord - fX) > 0.01 ||
                       (cube.rubiksCube.maxCord - fZ) > 0.01))
                 {
                    upperLayerEdges.append(UInt(index))
                    //cube.highlightSet.insert(index)
                }
            } else {
                if ( abs(fX - cube.rubiksCube.maxCord) < 0.01 &&
                       abs(fZ - cube.rubiksCube.maxCord) < 0.01)
                 {
                    middleLayerEdges.append(UInt(index))
                    cube.highlightSet.insert(index)
                }
            }
        }
        print(" Layer 1 Edges - \(layer1Edges)")
        print(" Middle Layer  Edges - \(middleLayerEdges)")
        print(" Upper Layer  Edges - \(upperLayerEdges)")
    }
    override func solve(_ model: RubiksCubeViewModel) {
        if model.rubiksCube.size != 3 {
            assert(false)
        }
        if (!areLowerLayerEdgesinLowerLayer(model: model)) {
            return moveLowerLayerEdgesToLowerLayer(model: model)
        }
        if (!areLowerLayerEdgesOrientedinLowerLayer(model: model)) {
            return orientLowerLayerEdges(model: model)
        }
        if (!areLowerLayerEdgesSolved(model: model)) {
            return solveLowerLayerEdges(model: model)
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerLeftBackCorner())) {
            return solveLowerLeftBackCorner(model: model,  lowerLayerLocked: true, getLowerLeftBackCorner())
            
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerLeftFrontCorner())) {
            return solveLowerLeftFrontCorner(model: model, lowerLayerLocked: true, getLowerLeftFrontCorner())
            
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerRightBackCorner())) {
            return solveLowerRightBackCorner(model: model, lowerLayerLocked: true, getLowerRightBackCorner())
            
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: getLowerRightFrontCorner())) {
            return solveLowerRightFrontCorner(model: model, lowerLayerLocked: true, getLowerRightFrontCorner())
            
        }
        
        if (!areSolvedMiddleLayerEdges(model: model)) {
            return solveMiddleLayerEdges(model: model)
        }
        
        if (!areUpperLayerEdgesOrientedinUpperLayer(model: model)) {
            return orientUpperLayerEdges(model: model)
        }
        if (!areUpperLayerEdgesSolved(model: model)) {
            return solveUpperLayerEdges(model: model)
        }
        if (!areUpperLayerCornersInPosition(model: model)) {
            return positionUpperLayerCornersFor3x3(model: model)
        }
        if (!model.rubiksCube.isSolvedCubbies(cubbies: upperLayerCorners)) {
            return orientUpperLayerCornersFor2x2(model: model)
        }
        for index in model.rubiksCube.cubbieOriginals.indices {
            model.highlightSet.insert(index)
        }
        model.rubiksCube.incrementDummyCount()
        
        
    }
    func positionUpperLayerCornersFor3x3(model: RubiksCubeViewModel) {
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperRightFrontCorner())) {
            return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: .FRONT, mirrorY: false, callback: nil)
        }
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperLeftFrontCorner())) {
            return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: .FRONT, mirrorY: true, callback: nil)
        }
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperLeftBackCorner())) {
            return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: .BACK, mirrorY: false, callback: nil)
        }
        if (model.rubiksCube.isInPositionCubbie(cubbie: getUpperRightBackCorner())) {
            return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: .BACK, mirrorY: true, callback: nil)
        }
        return apply3CornerPlacementWithFrontRightAnchorFromFace(model: model, face: .FRONT, mirrorY: false, callback: nil)
    }
    func areSolvedMiddleLayerEdges(model: RubiksCubeViewModel) -> Bool {
        for edge in middleLayerEdges {
            if !model.rubiksCube.isSolvedCubbie(cubbie: edge) {
                return false
            }
        }
        return true
    }
    
    func solveMiddleLayerEdges(model: RubiksCubeViewModel) {
        for edge in middleLayerEdges {
            if !model.rubiksCube.isSolvedCubbie(cubbie: edge) {
                return solveMiddleLayerEdge(model: model, edge: edge)
            }
        }
    }
    
    func isInMiddleLayer(model: RubiksCubeViewModel, edge: UInt) -> Bool {
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(edge)]
        let Yposition = abs(n.position.y)
        if (abs(Double(Yposition) - model.rubiksCube.maxCord) < 0.01) {
            return false
        }
        return true
    }
    
    func solveMiddleLayerEdge(model: RubiksCubeViewModel, edge: UInt) {
        if (model.rubiksCube.isSolvedCubbie(cubbie: edge)) {
            return
        }
        if (isInMiddleLayer(model: model, edge: edge)) {
            let faces = model.rubiksCube.getFacesForCubbie(cubbie: edge)
            let direction = (faces[1] == faces[0].clockwiseNeighbour()) ? RubiksCube.Direction.CLOCKWISE : .ANTICLOCKWISE
            let solution = [RubiksCube.Command(face: faces[0], direction: direction),
                            RubiksCube.Command(face: .UP, direction: direction),
                            RubiksCube.Command(face: faces[0], direction: direction.compliment()),
                            RubiksCube.Command(face: .UP, direction: direction.compliment()),
                            RubiksCube.Command(face: faces[1], direction: direction.compliment()),
                            RubiksCube.Command(face: .UP, direction: direction.compliment()),
                            RubiksCube.Command(face: faces[1], direction: direction)
            ]
            return model.playSolution(solution, nil)
        }
        let originalFaces = model.rubiksCube.getOriginFacesForCubbie(cubbie: edge)
        let faces = model.rubiksCube.getFacesForCubbie(cubbie: edge)
        let verticalFace = (faces[0] == .UP) ? faces[1] : faces[0]
        if (originalFaces.contains(verticalFace)) {
            model.highlightSet.insert(Int(edge))
            let alignedFace = (isAligned(model: model, edge: edge))
                ? verticalFace
                : (originalFaces[0] == verticalFace) ? originalFaces[1] : originalFaces[0]
            let unalignedFace = (originalFaces[0] == alignedFace) ? originalFaces[1] : originalFaces[0]
            let direction = (alignedFace == unalignedFace.clockwiseNeighbour()) ? RubiksCube.Direction.CLOCKWISE : .ANTICLOCKWISE
            var solution = Array<RubiksCube.Command>()
            if (verticalFace == unalignedFace) {
                solution.append(RubiksCube.Command(face: .UP, direction: direction))
            }
            solution.append(RubiksCube.Command(face: .UP, direction: direction))
            solution.append(RubiksCube.Command(face: unalignedFace, direction: direction))
            solution.append(RubiksCube.Command(face: .UP, direction: direction.compliment()))
            solution.append(RubiksCube.Command(face: unalignedFace, direction: direction.compliment()))
            solution.append(RubiksCube.Command(face: .UP, direction: direction.compliment()))
            solution.append(RubiksCube.Command(face: alignedFace, direction: direction.compliment()))
            solution.append(RubiksCube.Command(face: .UP, direction: direction))
            solution.append(RubiksCube.Command(face: alignedFace, direction: direction))
            return model.playSolution(solution, nil)
        }
        let direction = (verticalFace.clockwiseNeighbour() == originalFaces[0] || verticalFace.clockwiseNeighbour() == originalFaces[1])  ? RubiksCube.Direction.CLOCKWISE : .ANTICLOCKWISE
        let solution = [RubiksCube.Command(face: .UP, direction: direction)]
        return model.playSolution(solution, nil)
        
    }
    
    func areUpperLayerEdgesOrientedinUpperLayer(model: RubiksCubeViewModel) -> Bool {
        for edge in upperLayerEdges {
            if !model.rubiksCube.isOrientedCubbie(cubbie: edge) {
                return false
            }
        }
        return true
    }
    
    func areLowerLayerEdgesOrientedinLowerLayer(model: RubiksCubeViewModel) -> Bool {
        for edge in layer1Edges {
            if !model.rubiksCube.isOrientedCubbie(cubbie: edge) {
                return false
            }
        }
        return true
    }
    
    func isAligned(model: RubiksCubeViewModel, edge: UInt) -> Bool {
        let n = SCNNode()
        n.transform = model.rubiksCube.cubbieTransforms[Int(edge)]
        let eulerAngles = n.eulerAngles
        var numAnglesZero = 0
        if (abs(eulerAngles.x) < 0.01) {
            numAnglesZero += 1
        }
        if (abs(eulerAngles.y) < 0.01) {
            numAnglesZero += 1
        }
        if (abs(eulerAngles.z) < 0.01) {
            numAnglesZero += 1
        }
        return (numAnglesZero == 2)
    }
    func areUpperLayerEdgesSolved(model: RubiksCubeViewModel) -> Bool {
        for edge in upperLayerEdges {
            if !model.rubiksCube.isSolvedCubbie(cubbie: edge) {
                return false
            }
        }
        
        return true
    }
    func areLowerLayerEdgesSolved(model: RubiksCubeViewModel) -> Bool {
        for edge in layer1Edges {
            if !model.rubiksCube.isSolvedCubbie(cubbie: edge) {
                return false
            }
        }
        
        return true
    }
    func areLowerLayerEdgesinLowerLayer(model: RubiksCubeViewModel) -> Bool {
        for edge in layer1Edges {
            let faces = model.rubiksCube.getFacesForCubbie(cubbie: edge)
            if !faces.contains(.DOWN) {
                return false
            }
        }
        return true
    }
    
    func lowerLeftEdge() -> UInt {
        return layer1Edges[0]
    }
    func lowerBackEdge() -> UInt {
        return layer1Edges[1]
    }
    func lowerFrontEdge() -> UInt {
        return layer1Edges[2]
    }
    func lowerRightEdge() -> UInt {
        return layer1Edges[3]
    }
    
    func upperLeftEdge() -> UInt {
        return upperLayerEdges[0]
    }
    func upperBackEdge() -> UInt {
        return upperLayerEdges[1]
    }
    func upperFrontEdge() -> UInt {
        return upperLayerEdges[2]
    }
    func upperRightEdge() -> UInt {
        return upperLayerEdges[3]
    }
    
    func iterateUpperLayerFRURUFromLeftWithoutMirror() {
        return applyIterateUpperLayerFRURUF(model: callbackModel!, from: .LEFT, mirrorX: false, iterations: 1, callback: nil)
    }
    
    func iterateUpperLayerFRURUFromLeftWithMirror() {
        return applyIterateUpperLayerFRURUF(model: callbackModel!, from: .LEFT, mirrorX: true, iterations: 1, callback: nil)
    }
    func orientUpperLayerEdges(model: RubiksCubeViewModel) {
        var orientedCubes = Array<UInt>()
        for edge in upperLayerEdges {
            if model.rubiksCube.isOrientedCubbie(cubbie: edge) {
                orientedCubes.append(edge)
            }
        }
        
        if orientedCubes.count == 0 {
           // FRUR'U'F' -U2 -FURU'R'F'
            return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: false, iterations: 1, callback: iterateUpperLayerFRURUFromLeftWithoutMirror)
            
        }
        
        if orientedCubes.count == 2 {
            let orientedCubbieOneFaces = model.rubiksCube.getFacesForCubbie(cubbie: orientedCubes[0])
            let orientedCubbieOneVerticalFace = (orientedCubbieOneFaces[0] == .UP) ? orientedCubbieOneFaces[1] : orientedCubbieOneFaces[0]
            let orientedCubbieTwoFaces = model.rubiksCube.getFacesForCubbie(cubbie: orientedCubes[1])
            let orientedCubbieTwoVerticalFace = (orientedCubbieTwoFaces[0] == .UP) ? orientedCubbieTwoFaces[1] : orientedCubbieTwoFaces[0]
            
            switch orientedCubbieOneVerticalFace {
            case .LEFT:
                switch orientedCubbieTwoVerticalFace {
                case .RIGHT:
                    
                    return applyIterateUpperLayerFRURUF(model: model, from: .FRONT, mirrorX: false, iterations: 1, callback: nil)
                case .FRONT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .RIGHT, mirrorX: false, iterations: 1, callback: nil)
                case .BACK:
                   
                    return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: false, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            case .RIGHT:
                switch orientedCubbieTwoVerticalFace {
                case .LEFT:
                   
                    return applyIterateUpperLayerFRURUF(model: model, from: .FRONT, mirrorX: false, iterations: 1, callback: nil)
                case .FRONT:
            
                    return applyIterateUpperLayerFURURF(model: model, from: .LEFT, mirrorX: false, iterations: 1, callback: nil)
                case .BACK:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: false, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            case .FRONT:
                switch orientedCubbieTwoVerticalFace {
                case .LEFT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .RIGHT, mirrorX: false, iterations: 1, callback: nil)
                case .RIGHT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .LEFT, mirrorX: false, iterations: 1, callback: nil)
                case .BACK:
                   
                    return applyIterateUpperLayerFRURUF(model: model, from: .BACK, mirrorX: false, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            case .BACK:
                switch orientedCubbieTwoVerticalFace {
                case .LEFT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: false, iterations: 1, callback: nil)
                case .RIGHT:
                   
                    return applyIterateUpperLayerFURURF(model: model, from: .LEFT, mirrorX: false, iterations: 1, callback: nil)
                case .FRONT:
                   
                    return applyIterateUpperLayerFRURUF(model: model, from: .LEFT, mirrorX: false, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            default:
                assert(false)
            }
        }
        assert(false)
    }
    
    func orientLowerLayerEdges(model: RubiksCubeViewModel) {
        var orientedCubes = Array<UInt>()
        var unOrientedCube = UInt(0)
        for edge in layer1Edges {
            if model.rubiksCube.isOrientedCubbie(cubbie: edge) {
                orientedCubes.append(edge)
            } else {
                unOrientedCube = edge
            }
        }
        if orientedCubes.count == 1 || orientedCubes.count == 3 {
            let faces = model.rubiksCube.getFacesForCubbie(cubbie: unOrientedCube)
            let verticalFace = (faces[0] == .DOWN) ? faces[1] : faces[0]
            var otherFace: RubiksCube.Face? = nil
            switch verticalFace {
            case .LEFT:
                otherFace = .BACK
            case .RIGHT:
                otherFace = .FRONT
            case .FRONT:
                otherFace = .LEFT
            case .BACK:
                otherFace = .RIGHT
            default:
                assert(false)
            }
            let solution = [RubiksCube.Command(face: verticalFace, direction: .CLOCKWISE),
                            RubiksCube.Command(face: otherFace!, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                            RubiksCube.Command(face: otherFace!, direction: .CLOCKWISE),
                            RubiksCube.Command(face: verticalFace, direction: .CLOCKWISE),
                            RubiksCube.Command(face: verticalFace, direction: .CLOCKWISE)
                            ]
            return model.playSolution(solution, nil)
        }
        
        if orientedCubes.count == 0 {
           // FRUR'U'F' -U2 -FURU'R'F'
            return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: true, iterations: 1, callback: iterateUpperLayerFRURUFromLeftWithMirror)
            
        }
        
        if orientedCubes.count == 2 {
            let orientedCubbieOneFaces = model.rubiksCube.getFacesForCubbie(cubbie: orientedCubes[0])
            let orientedCubbieOneVerticalFace = (orientedCubbieOneFaces[0] == .DOWN) ? orientedCubbieOneFaces[1] : orientedCubbieOneFaces[0]
            let orientedCubbieTwoFaces = model.rubiksCube.getFacesForCubbie(cubbie: orientedCubes[1])
            let orientedCubbieTwoVerticalFace = (orientedCubbieTwoFaces[0] == .DOWN) ? orientedCubbieTwoFaces[1] : orientedCubbieTwoFaces[0]
            
            switch orientedCubbieOneVerticalFace {
            case .LEFT:
                switch orientedCubbieTwoVerticalFace {
                case .RIGHT:
                    
                    return applyIterateUpperLayerFRURUF(model: model, from: .FRONT, mirrorX: true, iterations: 1, callback: nil)
                case .FRONT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .BACK, mirrorX: true, iterations: 1, callback: nil)
                case .BACK:
                   
                    return applyIterateUpperLayerFURURF(model: model, from: .RIGHT, mirrorX: true, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            case .RIGHT:
                switch orientedCubbieTwoVerticalFace {
                case .LEFT:
                   
                    return applyIterateUpperLayerFRURUF(model: model, from: .FRONT, mirrorX: true, iterations: 1, callback: nil)
                case .FRONT:
            
                    return applyIterateUpperLayerFURURF(model: model, from: .LEFT, mirrorX: true, iterations: 1, callback: nil)
                case .BACK:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: true, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            case .FRONT:
                switch orientedCubbieTwoVerticalFace {
                case .LEFT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .BACK, mirrorX: true, iterations: 1, callback: nil)
                case .RIGHT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .RIGHT, mirrorX: true, iterations: 1, callback: nil)
                case .BACK:
                   
                    return applyIterateUpperLayerFRURUF(model: model, from: .LEFT, mirrorX: true, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            case .BACK:
                switch orientedCubbieTwoVerticalFace {
                case .LEFT:
                    
                    return applyIterateUpperLayerFURURF(model: model, from: .LEFT, mirrorX: true, iterations: 1, callback: nil)
                case .RIGHT:
                   
                    return applyIterateUpperLayerFURURF(model: model, from: .FRONT, mirrorX: true, iterations: 1, callback: nil)
                case .FRONT:
                   
                    return applyIterateUpperLayerFRURUF(model: model, from: .LEFT, mirrorX: true, iterations: 1, callback: nil)
                default:
                    assert(false)
                }
            default:
                assert(false)
            }
        }
        assert(false)
    }
    
    func solveLowerEdge(model: RubiksCubeViewModel, edge: UInt) {
        let faces = model.rubiksCube.getFacesForCubbie(cubbie: edge)
        let vFace = (faces[0] == .DOWN) ? faces[1] : faces[0]
        if vFace == .LEFT {
            let solution = [RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE)]
            return model.playSolution(solution, nil)
        }
        if vFace == .RIGHT {
            let solution = [RubiksCube.Command(face: .DOWN, direction: .ANTICLOCKWISE)]
            return model.playSolution(solution, nil)
        }
        if vFace == .BACK {
            let solution = [RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE),
                        RubiksCube.Command(face: .DOWN, direction: .CLOCKWISE)]
            return model.playSolution(solution, nil)
        }
    }
    
    func solveUpperEdge(model: RubiksCubeViewModel, edge: UInt) {
        let faces = model.rubiksCube.getFacesForCubbie(cubbie: edge)
        let vFace = (faces[0] == .UP) ? faces[1] : faces[0]
        if vFace == .LEFT {
            let solution = [RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE)]
            return model.playSolution(solution, nil)
        }
        if vFace == .RIGHT {
            let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
            return model.playSolution(solution, nil)
        }
        if vFace == .BACK {
            let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE)]
            return model.playSolution(solution, nil)
        }
    }
    
    func solveLowerLayerEdges(model: RubiksCubeViewModel) {
        if (!model.rubiksCube.isSolvedCubbie(cubbie: lowerFrontEdge())) {
            return solveLowerEdge(model: model, edge: lowerFrontEdge())
        }
        if (model.rubiksCube.isSolvedCubbie(cubbie: lowerRightEdge())) {
            return apply3EdgePlacementWithFrontAnchorFromFace(model: model, face: .BACK, mirrorX: true, callback: nil)
        }
        if (model.rubiksCube.isSolvedCubbie(cubbie: lowerLeftEdge())) {
            return apply3EdgePlacementWithFrontAnchorFromFace(model: model, face: .RIGHT, mirrorX: true, callback: nil)
        }
        return apply3EdgePlacementWithFrontAnchorFromFace(model: model, face: .FRONT, mirrorX: true, callback: nil)
        
    }
    
    func solveUpperLayerEdges(model: RubiksCubeViewModel) {
        if (!model.rubiksCube.isSolvedCubbie(cubbie: upperFrontEdge())) {
            return solveUpperEdge(model: model, edge: upperFrontEdge())
        }
        if (model.rubiksCube.isSolvedCubbie(cubbie: upperRightEdge())) {
            return apply3EdgePlacementWithFrontAnchorFromFace(model: model, face: .LEFT, mirrorX: false, callback: nil)
        }
        if (model.rubiksCube.isSolvedCubbie(cubbie: upperLeftEdge())) {
            return apply3EdgePlacementWithFrontAnchorFromFace(model: model, face: .BACK, mirrorX: false, callback: nil)
        }
        return apply3EdgePlacementWithFrontAnchorFromFace(model: model, face: .FRONT, mirrorX: false, callback: nil)
        
    }
    
    func apply3EdgePlacementWithFrontAnchorFromFace(model: RubiksCubeViewModel, face: RubiksCube.Face, mirrorX : Bool, callback : (()->Void)? ) {
       // R B" R F2 R" B R F2 R2
        let solution = [
            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .RIGHT, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .UP, direction: .CLOCKWISE).fromFace(face: face).mirrorX(mirrorX),
            RubiksCube.Command(face: .RIGHT, direction: .ANTICLOCKWISE).fromFace(face: face).mirrorX(mirrorX)]
        
        if (callback != nil) {
            callbackModel = model
        } else {
            callbackModel = nil
        }
        return model.playSolution(solution, callback)
    }
    
    
    
    func moveLowerLayerEdgesToLowerLayer(model: RubiksCubeViewModel) {
        var lockedFaces = Set<RubiksCube.Face>()
        var availableFaces =  Set<RubiksCube.Face>()
        availableFaces.insert(.LEFT)
        availableFaces.insert(.RIGHT)
        availableFaces.insert(.FRONT)
        availableFaces.insert(.BACK)
        var toMoveEdges = Array<UInt>()
        for edge in layer1Edges {
            let faces = model.rubiksCube.getFacesForCubbie(cubbie: edge)
            if faces.contains(.DOWN) {
                for face in faces {
                    lockedFaces.insert(face)
                    availableFaces.remove(face)
                }
            } else {
                toMoveEdges.append(edge)
            }
        }
        if (toMoveEdges.count > 0) {
            let faces = model.rubiksCube.getFacesForCubbie(cubbie: toMoveEdges[0])
            if faces.contains(.UP) {
                for availableFace in availableFaces {
                    if (faces.contains(availableFace)) {
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    }
                }
                let currentFace = (faces[0] == .UP) ? faces[1] : faces[0]
                let availableFace = availableFaces.first!
                switch currentFace {
                case .LEFT:
                    switch availableFace {
                    case .RIGHT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                        
                    case .FRONT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    case .BACK:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    default:
                        assert(false)
                    }
                case .RIGHT:
                    switch availableFace {
                    case .LEFT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                        
                    case .FRONT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    case .BACK:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    default:
                        assert(false)
                    }
                case .FRONT:
                    switch availableFace {
                    case .RIGHT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                        
                    case .LEFT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    case .BACK:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    default:
                        assert(false)
                    }
                case .BACK:
                    switch availableFace {
                    case .RIGHT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                        
                    case .LEFT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .ANTICLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    case .FRONT:
                        model.highlightSet.insert(Int(toMoveEdges[0]))
                        let solution = [RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: .UP, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE),
                                        RubiksCube.Command(face: availableFace, direction: .CLOCKWISE)]
                        return model.playSolution(solution,  nil)
                    default:
                        assert(false)
                    }
                default:
                    assert(false)
                }
            } else {
                for availableFace in availableFaces {
                    if (faces.contains(availableFace)) {
                        let otherFace = (faces[0] == availableFace) ? faces[1] : faces[0]
                        switch availableFace {
                        case .LEFT:
                            model.highlightSet.insert(Int(toMoveEdges[0]))
                            let solution = [RubiksCube.Command(face: availableFace, direction: (otherFace == .FRONT) ? .CLOCKWISE : .ANTICLOCKWISE)]
                            return model.playSolution(solution, nil)
                        case .RIGHT:
                            model.highlightSet.insert(Int(toMoveEdges[0]))
                            let solution = [RubiksCube.Command(face: availableFace, direction: (otherFace == .BACK) ? .CLOCKWISE : .ANTICLOCKWISE)]
                            return model.playSolution(solution, nil)
                        case .FRONT:
                            model.highlightSet.insert(Int(toMoveEdges[0]))
                            let solution = [RubiksCube.Command(face: availableFace, direction: (otherFace == .RIGHT) ? .CLOCKWISE : .ANTICLOCKWISE)]
                            return model.playSolution(solution, nil)
                        case .BACK:
                            model.highlightSet.insert(Int(toMoveEdges[0]))
                            let solution = [RubiksCube.Command(face: availableFace, direction: (otherFace == .LEFT) ? .CLOCKWISE : .ANTICLOCKWISE)]
                            return model.playSolution(solution, nil)
                        default:
                            assert(false)
                        }
                    }
                }
                let otherFace = faces[1]
                switch (faces[0]) {
                case .LEFT:
                    model.highlightSet.insert(Int(toMoveEdges[0]))
                    let solution = [RubiksCube.Command(face: faces[0], direction:
                                                (otherFace == .BACK) ? .CLOCKWISE : .ANTICLOCKWISE),
                                    RubiksCube.Command(face: .UP, direction:  .CLOCKWISE),
                                    RubiksCube.Command(face: faces[0], direction:
                                                                (otherFace == .BACK) ? .ANTICLOCKWISE : .CLOCKWISE)]
                    return model.playSolution(solution, nil)
                case .RIGHT:
                    model.highlightSet.insert(Int(toMoveEdges[0]))
                    let solution = [RubiksCube.Command(face: faces[0], direction:
                                                (otherFace == .FRONT) ? .CLOCKWISE : .ANTICLOCKWISE),
                                    RubiksCube.Command(face: .UP, direction:  .CLOCKWISE),
                                    RubiksCube.Command(face: faces[0], direction:
                                                                (otherFace == .FRONT) ? .ANTICLOCKWISE : .CLOCKWISE)]
                    return model.playSolution(solution, nil)
                case .FRONT:
                    model.highlightSet.insert(Int(toMoveEdges[0]))
                    let solution = [RubiksCube.Command(face: faces[0], direction:
                                                (otherFace == .LEFT) ? .CLOCKWISE : .ANTICLOCKWISE),
                                    RubiksCube.Command(face: .UP, direction:  .CLOCKWISE),
                                    RubiksCube.Command(face: faces[0], direction:
                                                                (otherFace == .LEFT) ? .ANTICLOCKWISE : .CLOCKWISE)]
                    return model.playSolution(solution, nil)
                case .BACK:
                    model.highlightSet.insert(Int(toMoveEdges[0]))
                    let solution = [RubiksCube.Command(face: faces[0], direction:
                                                (otherFace == .RIGHT) ? .CLOCKWISE : .ANTICLOCKWISE),
                                    RubiksCube.Command(face: .UP, direction:  .CLOCKWISE),
                                    RubiksCube.Command(face: faces[0], direction:
                                                                (otherFace == .RIGHT) ? .ANTICLOCKWISE : .CLOCKWISE)]
                    return model.playSolution(solution, nil)
                default:
                    assert(false)
                }
                
            }
        }
    }
}

