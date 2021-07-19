//
//  ContentView.swift
//  threed
//
//  Created by Sunil Munjal on 6/23/21.
//

import SwiftUI

import SceneKit

struct SceneKitView: UIViewRepresentable {
    
    @ObservedObject var viewModel: RubiksCubeViewModel
     let bloomFilter = CIFilter(name:"CIBloom")!
        
        //CIFilter(name: "CIGaussianBlur")!
        
        //CIFilter(name:"CIBloom")!
    
    func makeUIView(context: UIViewRepresentableContext<SceneKitView>) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.black
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1, y: 1, z: 1)
        
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        let fsize = Float(viewModel.rubiksCube.size)
        let maxCoord = (fsize - 1.0) / 2.0
        cameraNode.position = SCNVector3(x: -( (maxCoord + fsize / 2  + 1) ), y: -(maxCoord), z: fsize  +  fsize + maxCoord)
        cameraNode.transform = SCNMatrix4Rotate(cameraNode.transform, Float.pi / 5.0, -0.5, -0.4, 0.5) 
        sceneView.pointOfView = cameraNode
       // sceneView.contentMode = .scaleAspectFit
        sceneView.defaultCameraController.translateInCameraSpaceBy(x: 2, y: 2, z: 2)
        let box1 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.01)
        let box2 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.01)
        let green = SCNMaterial();
        green.diffuse.contents = UIColor.green
        //green.transparency = 0.925
        let blue = SCNMaterial();
        blue.diffuse.contents = UIColor.blue
        //blue.transparency = 0.925
        let yellow = SCNMaterial();
        yellow.diffuse.contents = UIColor.yellow
       // yellow.transparency = 0.925
        let white = SCNMaterial();
        white.diffuse.contents = UIColor.white
        //white.transparency = 0.925
        let red = SCNMaterial();
        red.diffuse.contents = UIColor.red
        //red.transparency = 0.925
        let orange = SCNMaterial();
        orange.diffuse.contents = UIColor.orange
       // orange.transparency = 0.925
        box1.materials = [green, white, blue, yellow, orange, red]
        box2.materials = [white, white, white, white, white, white]
        var boxNodes = [SCNNode]()
        var index = 0;
        for transform in viewModel.rubiksCube.cubbieTransforms {
            if (transform.m41 == -1 && transform.m42 == -1 && transform.m43 == -1) {
                boxNodes.append(SCNNode(geometry: box1))
            } else {
                    boxNodes.append(SCNNode(geometry: box1))
            }
                    boxNodes[index].transform = transform
                    sceneView.scene?.rootNode.addChildNode(boxNodes[index])
                    index += 1
        }
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.name = "blur"
        let pixellateFilter = CIFilter(name:"CIPixellate")
        pixellateFilter?.name = "pixellate"
        
        bloomFilter.setValue(10.0, forKey: "inputIntensity")
        bloomFilter.setValue(15.0, forKey: "inputRadius")
       // sceneView.scene?.rootNode.childNodes[2].filters =
       //     [ bloomFilter ] as? [CIFilter]
       //  sceneView.scene?.rootNode.addChildNode(lightNode)
        let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor.darkGray
        //sceneView.scene?.rootNode.addChildNode(ambientLightNode)
        //let boxnode1 = SCNNode(geometry: box1)
        //let boxnode2 = SCNNode(geometry: box1)
        //spherenode.position = SCNVector3(x: 0.0, y: 3.0, z: 0.0)
       
        
        //let boxnode7 = SCNNode(geometry: box7)
        //let boxnode8 = SCNNode(geometry: box8)
        //boxnode1.position = SCNVector3(x: 0, y: 0, z: 0)
        ////boxnode2.transform = SCNMatrix4Rotate(boxnode2.transform, .pi/2, 0.0, 1.0, 0.0)
    
       // boxnode7.position = SCNVector3(x: 0.3, y: 0.0, z: 0.3)
        //boxnode8.position = SCNVector3(x: 0.3, y: 0.3, z: 0.3)
        //sceneView.scene?.rootNode.addChildNode(boxnode1)
       // //sceneView.scene?.rootNode.addChildNode(boxnode3)
        //sceneView.scene?.rootNode.addChildNode(boxnode4)
        //sceneView.scene?.rootNode.addChildNode(boxnode6)
       // sceneView.scene?.rootNode.addChildNode(boxnode7)
       // sceneView.scene?.rootNode.addChildNode(boxnode8)
        //sceneView.scene?.rootNode.addChildNode(spherenode)
        
        
        return sceneView
    }

     func updateUIView(_ uiView: SCNView, context: UIViewRepresentableContext<SceneKitView>) {
      
        for i in viewModel.rubiksCube.cubbieTransforms.indices {
            uiView.scene?.rootNode.childNodes[i].transform = viewModel.rubiksCube.cubbieTransforms[i]
            if (viewModel.highlightSet.contains(i)) {
                uiView.scene?.rootNode.childNodes[i].filters =
                     [ bloomFilter] as? [CIFilter]
            } else {
                uiView.scene?.rootNode.childNodes[i].filters = Array<CIFilter>()
                     
            }
            if (i == 3 || i == 5 || i == 21 || i == 23) {
            print("[\(i)] \(uiView.scene?.rootNode.childNodes[i].position)  \(uiView.scene?.rootNode.childNodes[i].rotation)  \(uiView.scene?.rootNode.childNodes[i].eulerAngles)")
            }
            
        }
        //uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
    }

    typealias UIViewType = SCNView
}

struct ContentView: View {
    @ObservedObject var viewModel: RubiksCubeViewModel
    var body: some View {
        VStack {
            SceneKitView(viewModel: viewModel)
            HStack {
                Button("L",
                   action: {
                    
                    viewModel.turn(face: .LEFT,  direction: .CLOCKWISE, {})
                    
                    })
                
                Button("R",
                       action: {
                        
                        viewModel.turn(face: .RIGHT,  direction: .CLOCKWISE, {})
                        
                        })
                
                Button("U",
                   action: {
                    
                    viewModel.turn(face: .UP,  direction: .CLOCKWISE, {})
                    
                    })
                
                Button("D",
                       action: {
                        
                        viewModel.turn(face: .DOWN,  direction: .CLOCKWISE, {})
                        
                        })
                
                Button("F",
                   action: {
                    
                    viewModel.turn(face: .FRONT, direction: .CLOCKWISE, {})
                    
                    })
                Button("B",
                       action: {
                        
                        viewModel.turn(face: .BACK,  direction: .CLOCKWISE, {})
                        
                        })

            
                
            }
            HStack {
                Button("l",
                   action: {
                    
                    viewModel.turn(face: .LEFT, direction: .ANTICLOCKWISE, {})
                    
                    })
                
                Button("r",
                       action: {
                        
                        viewModel.turn(face: .RIGHT,  direction: .ANTICLOCKWISE, {})
                        
                        })
                
                Button("u",
                   action: {
                    
                    viewModel.turn(face: .UP,  direction: .ANTICLOCKWISE, {})
                    
                    })
                
                Button("d",
                       action: {
                        
                        viewModel.turn(face: .DOWN, direction: .ANTICLOCKWISE, {})
                        
                        })
                
                Button("f",
                   action: {
                    
                    viewModel.turn(face: .FRONT, direction: .ANTICLOCKWISE, {})
                    
                    })
                Button("b",
                       action: {
                        
                        viewModel.turn(face: .BACK,  direction: .ANTICLOCKWISE, {})
                        
                        })
                
            }
            HStack {
                Button("\(viewModel.numMoves)",
                   action: {
                    viewModel.pop()
                   })
                Button("Solve",
                   action: {
                    viewModel.solve()
                   })
                
                Button("Scramble",
                   action: {
                    viewModel.scamble(15)
                   })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: RubiksCubeViewModel())
    }
}
