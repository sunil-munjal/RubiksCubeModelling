//
//  RubiksCube.swift
//  threed
//
//  Created by Sunil Munjal on 6/30/21.
//

import Foundation
import SceneKit

struct RubiksCube {
    let size: UInt
    let maxCord: Double
    var cubbieTransforms = [SCNMatrix4]()
    var cubbieOriginals = [SCNMatrix4]()
    var turnlock = false
    enum Face : Int {
        case UP
        case DOWN
        case LEFT
        case RIGHT
        case FRONT
        case BACK
        
        func parallelFace() -> Face {
            switch self {
            case .FRONT:
                return .BACK
            case .BACK:
                return .FRONT
            case .LEFT:
                return .RIGHT
            case .RIGHT:
                return .LEFT
            case .UP:
                return .DOWN
            case .DOWN:
                return .UP
            }
        }
        
        func clockwiseNeighbour() -> Face {
            switch self {
            case .FRONT:
                return .LEFT
            case .BACK:
                return .RIGHT
            case .LEFT:
                return .BACK
            case .RIGHT:
                return .FRONT
            case .UP:
                return .RIGHT
            case .DOWN:
                return .LEFT
            }
        }
        
        func anticlockwiseNeighbour() -> Face {
            switch self {
            case .FRONT:
                return .RIGHT
            case .BACK:
                return .LEFT
            case .LEFT:
                return .FRONT
            case .RIGHT:
                return .BACK
            case .UP:
                return .LEFT
            case .DOWN:
                return .RIGHT
            }
        }
        
        static func fromInt(_ intVal: Int) -> Face {
            switch intVal {
            case 0:
                return .UP
            case 1:
                return .DOWN
            case 2:
                return .LEFT
            case 3:
                return.RIGHT
            case 4:
                return FRONT
            default:
                return .BACK
            }
        }
    }
    
    enum Direction {
        case CLOCKWISE
        case ANTICLOCKWISE
        
        func  compliment() ->  Direction {
            switch self {
            case .CLOCKWISE:
            return.ANTICLOCKWISE
            case .ANTICLOCKWISE:
            return .CLOCKWISE
            }
        }
        
        static func fromInt(_ intVal: Int) -> Direction {
            switch intVal {
            case 0:
                return .CLOCKWISE
            default:
                return .ANTICLOCKWISE
            }
        }
    }

    struct Command {
        let face : Face
        let direction : Direction
        
        func mirrorY(_ mirror: Bool) -> Command {
            if (!mirror) {
                return self
            }
            switch self.face {
            case Face.LEFT:
                return Command(face: Face.RIGHT, direction: self.direction.compliment())
            case Face.RIGHT:
                return Command(face: Face.LEFT, direction: self.direction.compliment())
            default:
                return Command(face: self.face, direction: self.direction.compliment())
            }
        }
        
        func mirrorX(_ mirror: Bool) -> Command {
            if (!mirror) {
                return self
            }
            switch self.face {
            case Face.UP:
                return Command(face: Face.DOWN, direction: self.direction.compliment())
            case Face.DOWN:
                return Command(face: Face.UP, direction: self.direction.compliment())

            default:
                return Command(face: self.face, direction: self.direction.compliment())
            }
        }
        
        func fromFace(face: Face) -> Command {
            switch face {
            case Face.FRONT:
                return self
            case Face.RIGHT:
                switch self.face {
                case Face.FRONT:
                    return Command(face: Face.RIGHT, direction: self.direction)
                case Face.BACK:
                    return Command(face: Face.LEFT, direction: self.direction)
                case Face.RIGHT:
                    return Command(face: Face.BACK, direction: self.direction)
                case Face.LEFT:
                    return Command(face: Face.FRONT, direction: self.direction)
                default:
                    return self
                }
            case Face.LEFT:
                switch self.face {
                case Face.FRONT:
                    return Command(face: Face.LEFT, direction: self.direction)
                case Face.BACK:
                    return Command(face: Face.RIGHT, direction: self.direction)
                case Face.RIGHT:
                    return Command(face: Face.FRONT, direction: self.direction)
                case Face.LEFT:
                    return Command(face: Face.BACK, direction: self.direction)
                default:
                    return self
                }
            case Face.BACK:
                switch self.face {
                case Face.FRONT:
                    return Command(face: Face.BACK, direction: self.direction)
                case Face.BACK:
                    return Command(face: Face.FRONT, direction: self.direction)
                case Face.RIGHT:
                    return Command(face: Face.LEFT, direction: self.direction)
                case Face.LEFT:
                    return Command(face: Face.RIGHT, direction: self.direction)
                default:
                    return self
                }
            case Face.UP:
                switch self.face {
                case Face.FRONT:
                    return Command(face: Face.UP, direction: self.direction)
                case Face.BACK:
                    return Command(face: Face.DOWN, direction: self.direction)
                case Face.UP:
                    return Command(face: Face.BACK, direction: self.direction)
                case Face.DOWN:
                    return Command(face: Face.FRONT, direction: self.direction)
                default:
                    return self
                }
                
            case Face.DOWN:
                switch self.face {
                case Face.FRONT:
                    return Command(face: Face.DOWN, direction: self.direction)
                case Face.BACK:
                    return Command(face: Face.UP, direction: self.direction)
                case Face.UP:
                    return Command(face: Face.FRONT, direction: self.direction)
                case Face.DOWN:
                    return Command(face: Face.BACK, direction: self.direction)
                default:
                    return self
                }
            }
        }
    }
    
    
    
    
    init(size : UInt) {
        self.size = size
        maxCord = Double(size - 1) / 2.0
        var index = 0
        let offset = Float(size - 1) / 2.0
        for  x in 0..<size {
            for y in 0..<size {
                for z in 0..<size {
                    let fx = Float(x) - offset
                    let fy =  Float(y) - offset
                    let fz = Float(z) - offset
                    cubbieOriginals.append( SCNMatrix4Translate(SCNMatrix4Identity, fx, fy, fz))
                    cubbieTransforms.append(cubbieOriginals[index])
                    index += 1
                }
            }
        }
    }
    
 
    
    mutating func turnX(face : Face, angleRad : Float, direction : Direction) {
        switch face {
        case .LEFT:
            
            var angle = angleRad
            if (direction == .CLOCKWISE) {
                angle = -angleRad
            }
            let rotation = SCNMatrix4MakeRotation(angle, -1, 0, 0);
            for transform in cubbieTransforms.indices {
                if (cubbieTransforms[transform].m41 <=  Float(-(maxCord - 0.1))) {
                    print(transform)

                    //let ty = cubbieTransforms[transform].m42 * ((cos(angle) - 1.0)) - //cubbieTransforms[transform].m43 * sin(angle)
                    //let tz = cubbieTransforms[transform].m43 * (cos(angle) - 1.0) + //cubbieTransforms[transform].m42 * sin(angle)
                    //cubbieTransforms[transform] = SCNMatrix4Translate(cubbieTransforms[transform], 0.0, ty, tz)
                    //cubbieTransforms[transform] = SCNMatrix4Rotate(cubbieTransforms[transform], angle, 1.0, 0.0, 0.0)
                    cubbieTransforms[transform] = SCNMatrix4Mult(cubbieTransforms[transform], rotation)
                }
            }
        case .RIGHT:
            
            var angle = angleRad
            if (direction == .CLOCKWISE) {
                angle = -angleRad
            }
            let rotation = SCNMatrix4MakeRotation(angle, 1, 0, 0);
            for transform in cubbieTransforms.indices {
                if (cubbieTransforms[transform].m41 > Float((maxCord - 0.1))) {
                    print(transform)

                    //let ty = cubbieTransforms[transform].m42 * ((cos(angle) - 1.0)) - cubbieTransforms[transform].m43 * sin(angle)
                    //let tz = cubbieTransforms[transform].m43 * (cos(angle) - 1.0) + cubbieTransforms[transform].m42 * sin(angle)
                    //cubbieTransforms[transform] =
                    //    SCNMatrix4Translate(cubbieTransforms[transform], 0.0, ty, tz)
                    //cubbieTransforms[transform] = SCNMatrix4Rotate(cubbieTransforms[transform], angle, 1.0, 0.0, 0.0)
                    cubbieTransforms[transform] = SCNMatrix4Mult(cubbieTransforms[transform], rotation)
                }
            }
        default:
            break
        }
       
        
    }
    mutating func turnY(face : Face, angleRad : Float, direction: Direction)  {
        switch face {
        case .UP:
            
            var angle = angleRad
            if (direction == .CLOCKWISE) {
                angle = -angleRad
            }
            let rotation = SCNMatrix4MakeRotation(angle, 0, 1, 0);
            for transform in cubbieTransforms.indices {
                if (cubbieTransforms[transform].m42 > Float(maxCord - 0.1)) {
                    print(transform)
                    //let tx = cubbieTransforms[transform].m41 * ((cos(angle) - 1.0)) - cubbieTransforms[transform].m43 * sin(angle)
                    //let tz = cubbieTransforms[transform].m43 * (cos(angle) - 1.0) + cubbieTransforms[transform].m41 * sin(angle)
                    //cubbieTransforms[transform] = SCNMatrix4Translate(cubbieTransforms[transform], tx, 0.0, tz)
                    //cubbieTransforms[transform] = SCNMatrix4Rotate(cubbieTransforms[transform], angle, 0.0, 1.0, 0.0)
                    cubbieTransforms[transform] = SCNMatrix4Mult(cubbieTransforms[transform], rotation)
                }
            }
        case .DOWN:
            
            var angle = angleRad
            if (direction == .CLOCKWISE) {
                angle = -angleRad
            }
            let rotation = SCNMatrix4MakeRotation(angle, 0, -1, 0);
            for transform in cubbieTransforms.indices {
                if (cubbieTransforms[transform].m42 < Float(-(maxCord - 0.1))) {
                    print(transform)

                    //let tx = cubbieTransforms[transform].m41 * ((cos(angle) - 1.0)) - cubbieTransforms[transform].m43 * sin(angle)
                    //let tz = cubbieTransforms[transform].m43 * (cos(angle) - 1.0) + cubbieTransforms[transform].m41 * sin(angle)
                    //cubbieTransforms[transform] = SCNMatrix4Translate(cubbieTransforms[transform], tx, 0.0, tz)
                    //cubbieTransforms[transform] = SCNMatrix4Rotate(cubbieTransforms[transform], angle, 0.0, 1.0, 0.0)
                    cubbieTransforms[transform] = SCNMatrix4Mult(cubbieTransforms[transform], rotation)
                }
            }
        default:
            break
        }
        
    }
    mutating func turnZ(face : Face, angleRad : Float, direction: Direction) {
        switch face {
        case .BACK:
            
            var angle = angleRad
            if (direction == .CLOCKWISE) {
                angle = -angleRad
            }
            let rotation = SCNMatrix4MakeRotation(angle, 0, 0, -1);
            for transform in cubbieTransforms.indices {
                if (cubbieTransforms[transform].m43 < Float(-(maxCord - 0.1))) {
                    print(transform)

                   // let tx = cubbieTransforms[transform].m41 * ((cos(angle) - 1.0)) - cubbieTransforms[transform].m42 * sin(angle)
                    //let ty = cubbieTransforms[transform].m42 * (cos(angle) - 1.0) + cubbieTransforms[transform].m41 * sin(angle)
                   // cubbieTransforms[transform] =
                    //    SCNMatrix4Translate(cubbieTransforms[transform], tx, ty, 0.0)
                   // cubbieTransforms[transform] = SCNMatrix4Rotate(cubbieTransforms[transform], angle, 0.0, 0.0, 1.0)
                    cubbieTransforms[transform] = SCNMatrix4Mult(cubbieTransforms[transform], rotation)
                }
            }
        case .FRONT:
            
            var angle = angleRad
            if (direction == .CLOCKWISE) {
                angle = -angleRad
            }
            let rotation = SCNMatrix4MakeRotation(angle, 0, 0, 1);
            for transform in cubbieTransforms.indices {
                if (cubbieTransforms[transform].m43 > Float((maxCord - 0.1))) {
                    print(transform)

                    //let tx = cubbieTransforms[transform].m41 * ((cos(angle) - 1.0)) + cubbieTransforms[transform].m42 * sin(angle)
                   // let ty = cubbieTransforms[transform].m42 * (cos(angle) - 1.0) - cubbieTransforms[transform].m41 * sin(angle)
                    //cubbieTransforms[transform] = SCNMatrix4Translate(cubbieTransforms[transform], tx, ty, 0.0)
                    //cubbieTransforms[transform] = SCNMatrix4Rotate(cubbieTransforms[transform], angle, 0.0, 0.0, 1.0)
                    cubbieTransforms[transform] = SCNMatrix4Mult(cubbieTransforms[transform], rotation)
                }
            }
        default:
            break
        }
    }
    func isInLowerLayer(cubbie: UInt) -> Bool {
        let n = SCNNode()
        n.transform = cubbieTransforms[Int(cubbie)]
        let position = n.position
        if abs(Double(position.y) + maxCord) < 0.01 {
            return true
        }
        return false
    }
    func getFacesForCubbie(cubbie: UInt) -> Array<Face> {
        let n = SCNNode()
        n.transform = cubbieTransforms[Int(cubbie)]
        let position = n.position
        var faces = Array<Face>()
        if abs(Double(position.x) + maxCord) < 0.01 {
            faces.append(.LEFT)
        }
        if abs(Double(position.x) - maxCord) < 0.01 {
            faces.append(.RIGHT)
        }
        if abs(Double(position.y) + maxCord) < 0.01 {
            faces.append(.DOWN)
        }
        if abs(Double(position.y) - maxCord) < 0.01 {
            faces.append(.UP)
        }
        if abs(Double(position.z) + maxCord) < 0.01 {
            faces.append(.BACK)
        }
        if abs(Double(position.z) - maxCord) < 0.01 {
            faces.append(.FRONT)
        }
        return faces
    }
    func getOriginFacesForCubbie(cubbie: UInt) -> Array<Face> {
        let n = SCNNode()
        n.transform = cubbieOriginals[Int(cubbie)]
        let position = n.position
        var faces = Array<Face>()
        if abs(Double(position.x) + maxCord) < 0.01 {
            faces.append(.LEFT)
        }
        if abs(Double(position.x) - maxCord) < 0.01 {
            faces.append(.RIGHT)
        }
        if abs(Double(position.y) + maxCord) < 0.01 {
            faces.append(.DOWN)
        }
        if abs(Double(position.y) - maxCord) < 0.01 {
            faces.append(.UP)
        }
        if abs(Double(position.z) + maxCord) < 0.01 {
            faces.append(.BACK)
        }
        if abs(Double(position.z) - maxCord) < 0.01 {
            faces.append(.FRONT)
        }
        return faces
    }
    func isInPositionCubbie(cubbie: UInt) -> Bool {
        let n = SCNNode()
        n.transform = cubbieOriginals[Int(cubbie)]
        let po = n.position
        n.transform = cubbieTransforms[Int(cubbie)]
        let pn = n.position
        return (abs( po.x - pn.x) < 0.01 &&
                abs( po.y - pn.y) < 0.01 &&
                abs( po.z - pn.z) < 0.01)
    }
    func isOrientedCubbie(cubbie: UInt) -> Bool {
        let n = SCNNode()
        n.transform = cubbieOriginals[Int(cubbie)]
        let ro = n.eulerAngles
        n.transform = cubbieTransforms[Int(cubbie)]
        let rn = n.eulerAngles
        return (abs( ro.x - rn.x ) < 0.01 &&
                abs( ro.z - rn.z ) < 0.01 
        ) || (abs(abs( ro.x - rn.x ) - Float.pi) < 0.01 && abs(abs( ro.z - rn.z ) - Float.pi) < 0.01)
    }
    
    func isSolvedCubbie(cubbie: UInt) -> Bool {
        let n = SCNNode()
        n.transform = cubbieOriginals[Int(cubbie)]
        let po = n.position
        let ro = n.rotation
        n.transform = cubbieTransforms[Int(cubbie)]
        let pn = n.position
        let rn = n.rotation
        return (abs( po.x - pn.x) < 0.01 &&
                abs( po.y - pn.y) < 0.01 &&
                abs( po.z - pn.z) < 0.01 &&
                abs( ro.x - rn.x ) < 0.01 &&
                abs( ro.y - rn.y ) < 0.01 &&
                abs( ro.z - rn.z ) < 0.01 &&
                abs( ro.w - rn.w ) < 0.01 )
    }

    func isSolvedCubbies(cubbies: [UInt]) -> Bool {
        if cubbies == nil || cubbies.count == 0 {
            return true
        }
        
        for cubbie in cubbies {
            if (!isSolvedCubbie(cubbie: cubbie)) {
                return false
            }
        }
        return true
    }
    var dummy = 0
    mutating func incrementDummyCount() {
        dummy += 1
    }
}
