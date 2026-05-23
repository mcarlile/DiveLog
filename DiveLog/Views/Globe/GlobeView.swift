import SwiftUI
import SceneKit
import CoreLocation

struct GlobeView: UIViewRepresentable {
    var dives: [Dive]
    var onDiveTapped: ((Dive) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(dives: dives, onDiveTapped: onDiveTapped)
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = context.coordinator.scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = UIColor(red: 0.02, green: 0.04, blue: 0.12, alpha: 1.0)
        scnView.antialiasingMode = .multisampling4X

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        context.coordinator.scnView = scnView

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.updateDiveMarkers(dives: dives)
    }

    class Coordinator: NSObject {
        var scene: SCNScene
        var globeNode: SCNNode
        var markerNodes: [UUID: SCNNode] = [:]
        var dives: [Dive]
        var onDiveTapped: ((Dive) -> Void)?
        weak var scnView: SCNView?

        init(dives: [Dive], onDiveTapped: ((Dive) -> Void)?) {
            self.dives = dives
            self.onDiveTapped = onDiveTapped
            scene = SCNScene()
            globeNode = SCNNode()
            super.init()
            setupScene()
        }

        private func setupScene() {
            // Globe sphere
            let sphere = SCNSphere(radius: 1.0)
            sphere.segmentCount = 72

            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "earth_texture") ?? UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 1.0)
            material.specular.contents = UIColor.white
            material.shininess = 0.1
            sphere.materials = [material]

            globeNode.geometry = sphere
            scene.rootNode.addChildNode(globeNode)

            // Atmosphere glow
            let atmosphereSphere = SCNSphere(radius: 1.02)
            let atmosphereMaterial = SCNMaterial()
            atmosphereMaterial.diffuse.contents = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.08)
            atmosphereMaterial.isDoubleSided = true
            atmosphereSphere.materials = [atmosphereMaterial]
            let atmosphereNode = SCNNode(geometry: atmosphereSphere)
            scene.rootNode.addChildNode(atmosphereNode)

            // Ambient light
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.intensity = 200
            ambientLight.color = UIColor(white: 0.5, alpha: 1.0)
            let ambientNode = SCNNode()
            ambientNode.light = ambientLight
            scene.rootNode.addChildNode(ambientNode)

            // Sun light
            let sunLight = SCNLight()
            sunLight.type = .directional
            sunLight.intensity = 1500
            sunLight.color = UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0)
            let sunNode = SCNNode()
            sunNode.light = sunLight
            sunNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
            scene.rootNode.addChildNode(sunNode)

            // Camera
            let camera = SCNCamera()
            camera.fieldOfView = 60
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, 2.8)
            scene.rootNode.addChildNode(cameraNode)

            // Auto-rotate
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            rotation.duration = 60
            rotation.repeatCount = .infinity
            globeNode.addAnimation(rotation, forKey: "rotate")

            updateDiveMarkers(dives: dives)
        }

        func updateDiveMarkers(dives: [Dive]) {
            self.dives = dives
            for node in markerNodes.values {
                node.removeFromParentNode()
            }
            markerNodes.removeAll()

            for dive in dives {
                guard let lat = dive.latitude, let lon = dive.longitude else { continue }
                let markerNode = createMarker(for: dive, lat: lat, lon: lon)
                globeNode.addChildNode(markerNode)
                markerNodes[dive.id] = markerNode
            }
        }

        private func createMarker(for dive: Dive, lat: Double, lon: Double) -> SCNNode {
            let latRad = lat * .pi / 180
            let lonRad = lon * .pi / 180
            let radius = 1.03
            let x = radius * cos(latRad) * cos(lonRad)
            let y = radius * sin(latRad)
            let z = -radius * cos(latRad) * sin(lonRad)

            let markerSphere = SCNSphere(radius: 0.018)
            let markerMaterial = SCNMaterial()
            markerMaterial.diffuse.contents = UIColor.cyan
            markerMaterial.emission.contents = UIColor(red: 0, green: 0.8, blue: 1.0, alpha: 0.6)
            markerSphere.materials = [markerMaterial]

            let markerNode = SCNNode(geometry: markerSphere)
            markerNode.position = SCNVector3(Float(x), Float(y), Float(z))
            markerNode.name = dive.id.uuidString

            // Pulse animation
            let pulse = CABasicAnimation(keyPath: "geometry.radius")
            pulse.fromValue = 0.015
            pulse.toValue = 0.025
            pulse.duration = 1.5
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            markerNode.addAnimation(pulse, forKey: "pulse")

            return markerNode
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = scnView else { return }
            let location = gesture.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: nil)

            for result in hitResults {
                if let name = result.node.name,
                   let uuid = UUID(uuidString: name),
                   let dive = dives.first(where: { $0.id == uuid }) {
                    onDiveTapped?(dive)
                    return
                }
            }
        }
    }
}
