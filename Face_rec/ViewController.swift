//
//  ViewController.swift
//  Face_rec
//
//  Created by Alikhan Nursapayev on 05.12.2022.
//

import UIKit
import AVKit
import Vision
import ARKit
import CoreML
import SceneKit


class ViewController: UIViewController {
    var res: RecognitionResult? = nil
    var textNode: SCNNode? = nil
    let statusMessage = UILabel()
    let imagePredictor = ImagePredictor()
    let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-2))
    let predictionsToShow = 5
    override func viewDidLoad() {
        super.viewDidLoad()
//        MlCreator().getImageClassification()

        self.view.addSubview(sceneView) // add the scene to the subview
        sceneView.delegate = self // Setting the delegate for our view controller
        sceneView.showsStatistics = true // Show statistics
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        
        statusMessage.translatesAutoresizingMaskIntoConstraints = false
        statusMessage.text = "Please blink to proceed..."
        statusMessage.textColor = .white
        statusMessage.font = UIFont.systemFont(ofSize: 18)
        statusMessage.textAlignment = .center
        sceneView.addSubview(statusMessage)

        NSLayoutConstraint.activate([
            statusMessage.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            statusMessage.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showNectMenu") {
            let destinationVC = segue.destination as! AuthorizedViewController
            destinationVC.name = res?.name
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        let node = SCNNode(geometry: faceGeometry)
        
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
                let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft],
                let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight],
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }

            
        node.position
        
        if self.textNode != nil {
            self.textNode!.removeFromParentNode()
        }
        
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        let text = SCNText(string: "", extrusionDepth: 2)
        let font = UIFont(name: "Avenir-Heavy", size: 18)
        text.font = font
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        
        text.materials = [material]
        text.firstMaterial?.isDoubleSided = true
        
//        textNode = SCNNode(geometry: faceGeometry)
        textNode?.position = SCNVector3(-0.1, node.position.y-0.1, -0.5)
//        Poisiotn not shown
//        print(textNode?.position)
        textNode?.scale = SCNVector3(0.002, 0.002, 0.002)
        

        
        textNode?.geometry = text
        textNode?.name = "22"
        
        guard let model = try? VNCoreMLModel(for: FaceDetection3().model) else {
            fatalError("Unable to load model")
        }
        
        let coreMlRequest = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }

            DispatchQueue.main.async {[weak self] in
//                print(topResult.identifier)
                if topResult.identifier != "Unknown" {
//                    text.string = topResult.identifier
//                    for view in self!.sceneView.scene.rootNode.childNodes {
//                        if view.name == "22" {
//                            view.removeFromParentNode()
//                        }
//
//                    }
//
//
//                    self!.sceneView.scene.rootNode.addChildNode((self?.textNode!)!)
//                    self!.sceneView.autoenablesDefaultLighting = true
                }
            }
        }
        
        guard let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage else { return }
        do {
            let ciContext = CIContext()
            let ciImage = CIImage(cvImageBuffer: pixelBuffer)
            // Check if both eyes are closed
            print(leftEyeBlink.floatValue)
        if leftEyeBlink.floatValue > 0.8 && rightEyeBlink.floatValue > 0.8 {
            
            res = MlCreator().getImageClassification(img: ciContext.createCGImage(ciImage, from: ciImage.extent)!) ?? RecognitionResult(name: "", confidence: 0)
            DispatchQueue.main.async {
                if self.res?.confidence ?? 0 > 0.9 {
                    self.statusMessage.text = "Successfully logged in!"
                    self.performSegue(withIdentifier: "showNectMenu", sender: self)
                }
                self.statusMessage.text = "Please blink again"
            }
        }
            try self.imagePredictor.makePredictions(for: pixelBuffer,
                                                    completionHandler: {predictions in
                guard let predictions = predictions else {
                    
                    return
                }

                let formattedPredictions = self.formatPredictions(predictions)

                let predictionString = formattedPredictions.joined(separator: "\n")
                text.string = predictionString
                
            })
        } catch {
//            print("Vision was unable to make a prediction...\n\n\(error.localalizedDescription)")
        }
        
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([coreMlRequest])
            } catch {
                print(error)
            }
        }
    }
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)"
        }

        return topPredictions
    }
    
}

