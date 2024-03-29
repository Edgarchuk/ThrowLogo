
import Foundation
import RealityKit
import SwiftUI
import ARKit

class GameController {
    var lastDragPoint: CGPoint?
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { [self] value in
                if let lastDragPoint = lastDragPoint {
                    var velocity = SIMD3<Float>(
                        Float(value.location.x - lastDragPoint.x),
                        -1 * Float(value.location.y - lastDragPoint.y),
                        0) * 0.1
                    velocity = float3x3(arView!.cameraTransform.rotation) * velocity
                    currentModel?.physicsMotion?.linearVelocity = velocity
                } else {
                    currentModel = model.clone(recursive: true) as! HasPhysics
                    cameraAnchor.addChild(currentModel!)
                }
                lastDragPoint = value.location
            }
            .onEnded { value in
                self.currentModel?.physicsBody?.mode = .dynamic
                self.lastDragPoint = nil
            }
    }
    
    var currentModel: (Entity & HasPhysics)?
    
    let plane: HasAnchoring = {
        var entity = ModelEntity(mesh: .generateBox(size: .init(100, 0.1, 100)),
                                 materials: [OcclusionMaterial()])
        entity.physicsBody = .init(massProperties: .default, material: .default, mode: .static)
        entity.generateCollisionShapes(recursive: false)
        entity.position.y = -0.1
        var anchor = try! Experience.loadBox()
        anchor.children.removeAll()
        anchor.addChild(entity)
        return anchor
    }()
    
    let model: Entity & HasPhysics = {
        var entity = (try! Experience.loadBox()).model! as! HasPhysics
        
        entity.physicsBody?.mode = .kinematic
        entity.collision?.mode = .default
        entity.collision?.filter = .default
        return entity
        
    }()
    
    let cameraAnchor: AnchorEntity = {
        var anchor = AnchorEntity(.camera)
        return anchor
    } ()
    
    private var arView: ARView?
    
    func makeARView() -> ARView {
        let arView = ARView(frame: .zero)
        cameraAnchor.position.z = -0.5
        arView.scene.anchors.append(cameraAnchor)
        let configuration = ARWorldTrackingConfiguration()

        let sceneReconstruction: ARWorldTrackingConfiguration.SceneReconstruction = .mesh
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(sceneReconstruction) {
            configuration.sceneReconstruction = sceneReconstruction
        } else {
            arView.scene.anchors.append(plane)
        }

        let frameSemantics: ARConfiguration.FrameSemantics = [.smoothedSceneDepth, .sceneDepth]
        if ARWorldTrackingConfiguration.supportsFrameSemantics(frameSemantics) {
            configuration.frameSemantics.insert(frameSemantics)
        }
        arView.session.run(configuration)
        arView.environment.sceneUnderstanding.options
            .insert([.collision, .physics, .receivesLighting, .occlusion])
        self.arView = arView
        return arView
    }
}

struct ARViewContainer: UIViewRepresentable {
    var arView: ARView
    
    func makeUIView(context: Context) -> ARView {
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}
