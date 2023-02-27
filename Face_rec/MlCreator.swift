//
//  MlCreator.swift
//  Face_rec
//
//  Created by Alikhan Nursapayev on 29.01.2023.
//

import Foundation
import CreateML
import CoreML
import CoreImage
import Vision
import UIKit


class MlCreator {
    
    @available(iOS 15.0, *)
    func trainModel(images: [UIImage]) {
            // Preprocessing of the images to be done here

            // Convert the images to a CreateML Data Table
            var dataTable = MLDataTable()

            // Add the image data and labels to the data table
            for (index, image) in images.enumerated() {
//                let imagePixelData = image.pixelData()
//                let label = "Label \(index)"
//                dataTable.addRow(["image_data": MLDataValue(doubleArray: imagePixelData), "label": MLDataValue(string: label)])
            }

            // Train the Image Classifier
        do {
            let classifier = try MLImageClassifier(trainingData: .labeledDirectories(at: URL(string: "./userimages")!))
            
            // Save the Image Classifier to disk
            let metadata = MLModelMetadata(author: "Your Name", shortDescription: "A model trained to recognize faces", version: "1.0")
            try! classifier.write(to: URL(fileURLWithPath: "FaceRecognition3.mlmodel"), metadata: metadata)
        } catch {
            
        }

        }
    
    
    func getImageClassification(img: CGImage) -> RecognitionResult? {
        var classification: String?
        var name = ""
        var confidence = 0.0
        // Load the trained model and create a request for classification
        guard let model = try? VNCoreMLModel(for: FaceDetection3().model) else {
            fatalError("Failed to load the model.")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                  let topClassification = results.first else {
                fatalError("Unexpected results type.")
            }
            print("Classification: \(topClassification.identifier), Confidence: \(topClassification.confidence)")
            classification = topClassification.identifier
            name = topClassification.identifier
            confidence = Double(topClassification.confidence)
        }
        
        // Perform the request on the input image
        let handler = VNImageRequestHandler(cgImage: img, options: [:])
        try? handler.perform([request])
        var recognitionResult = RecognitionResult(name: name, confidence: confidence)
        return recognitionResult
    }
    
    
}


struct RecognitionResult {
    var name: String
    var confidence: Double
}
