//
//  FaceEmotionDetector.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  FaceEmotionDetector.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import AVFoundation
import Vision
import CoreML
import UIKit

class FaceEmotionDetector: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var requests = [VNRequest]()
    @Published var currentMood: MoodState = .neutral
    
    func startDetection() {
        setupCaptureSession()
        setupVision()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopDetection() {
        captureSession?.stopRunning()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .medium
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Failed to access front camera")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        guard captureSession?.canAddInput(deviceInput) == true,
              captureSession?.canAddOutput(videoOutput) == true else {
            print("Failed to add camera input/output")
            return
        }
        
        captureSession?.addInput(deviceInput)
        captureSession?.addOutput(videoOutput)
    }
    
    var emotionModel: MLModel? //classic machine learning model created with createml
    var visionModel: VNCoreMLModel? //Vision Container for Core Ml Model
    
    private func setupVision() {
        self.emotionModel = EmotionClassificator().model
        do{
            visionModel = try VNCoreMLModel(for: self.emotionModel!)
            let request = VNCoreMLRequest(model: visionModel!, completionHandler: handleDetectionResults)
            self.requests = [request]
        }catch{
            fatalError("Unable to create Vision Model...")
        }
    }
    

    
    private func handleDetectionResults(request: VNRequest, error: Error?) {
        if let error = error {
            print("Detection error: \(error.localizedDescription)")
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            return
        }
        
        DispatchQueue.main.async {
            self.currentMood = self.moodState(for: topResult.identifier)
        }
    }
    
    private func moodState(for emotion: String) -> MoodState {
        switch emotion.lowercased() {
        case "happy": return .happy
        case "sad": return .sad
        case "angry": return .angry
        case "surprise": return .surprised
        case "fear": return .anxious
        case "neutral": return .neutral
        case "No Results": return .noresult
        default: return .neutral
        }
    }
}

extension FaceEmotionDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .upMirrored,  // Front camera needs mirroring
            options: [:]
        )
        
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print("Failed to perform request: \(error)")
        }
    }
}

extension Notification.Name {
    static let emotionDetected = Notification.Name("emotionDetected")
}
