//
//  RubiksCubeSolver4X4X4.swift
//  threed
//
//  Created by Sunil Munjal on 7/8/21.
//

import Foundation

import Foundation

public class RubiksCubeSolver4X4X4 : RubiksCubeSolver3X3X3 {
    
    override init(_ cube: RubiksCubeViewModel) {
        super.init(cube)
    }
    override func solve(_ model: RubiksCubeViewModel) {
        if model.rubiksCube.size != 4 {
            assert(false)
        }
        
        if (!model.rubiksCube.isSolvedCubbie(cubbie: UInt( layer1Corners[0]))) {
            solveLowerLeftBackCorner(model: model, lowerLayerLocked: true,  UInt( layer1Corners[0]))
            return
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: UInt( layer1Corners[1]))) {
            solveLowerLeftFrontCorner(model: model, lowerLayerLocked: true,  UInt( layer1Corners[1]))
            return
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: UInt( layer1Corners[2]))) {
            solveLowerRightBackCorner(model: model,  lowerLayerLocked: true, UInt( layer1Corners[2]))
            return
        }
        if (!model.rubiksCube.isSolvedCubbie(cubbie: UInt( layer1Corners[3]))) {
            solveLowerRightFrontCorner(model: model,  lowerLayerLocked: true, UInt( layer1Corners[3]))
            return
        }
    }
    
}

