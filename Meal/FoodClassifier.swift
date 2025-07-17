//
//  FoodClassifier.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  FoodClassifier.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import UIKit
import CoreML
import Vision


class FoodClassifier: ObservableObject {
    private var model: VNCoreMLModel?
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        // Load the MobileNetV2 model from the app bundle
        guard let modelURL = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") else {
            print("Failed to locate MobileNetV2.mlmodelc in bundle")
            return
        }
        
        do {
            // Initialize the CoreML model
            let coreMLModel = try MLModel(contentsOf: modelURL)
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("Failed to load MobileNetV2 model: \(error.localizedDescription)")
        }
    }
    
    func classify(image: UIImage, completion: @escaping (String?, Double?) -> Void) {
        guard let model = model,
              let ciImage = CIImage(image: image) else {
            completion(nil, nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Classification error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil, nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(topResult.identifier, Double(topResult.confidence))
            }
        }
        
        // Configure the request
        request.imageCropAndScaleOption = .centerCrop
        
        // Perform the classification
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: getImageOrientation(image))
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }
    }
    
    private func getImageOrientation(_ image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
