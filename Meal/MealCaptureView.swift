//
//  MealCaptureView.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  MealCaptureView.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import SwiftUI
import PhotosUI

struct MealCaptureView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var foodClassifier = FoodClassifier()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var mealDescription = ""
    @State private var showDescriptionInput = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentColor"), lineWidth: 2)
                    )
                    .padding()
                
                if showDescriptionInput {
                    VStack {
                        TextField("Describe your meal in 3 words", text: $mealDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: saveMeal) {
                            Text("Save Meal")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .transition(.slide)
                }
            } else {
                VStack(spacing: 30) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("Snap a photo of your meal")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { showImagePicker = true }) {
                        Text("Take Photo")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Log Your Meal")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            guard let image = newImage else { return }
            processImage(image)
        }
        .overlay(
            Group {
                if isProcessing {
                    ProcessingOverlay()
                }
            }
        )
    }
    
    private func processImage(_ image: UIImage) {
        isProcessing = true
        foodClassifier.classify(image: image) { result, confidence  in
            DispatchQueue.main.async {
                isProcessing = false
                withAnimation {
                    showDescriptionInput = true
                }
            }
        }
    }
    
    private func saveMeal() {
        guard let image = selectedImage else { return }
        foodClassifier.classify(image: image, completion: { classify, top in
            let meal = Meal(
                id: UUID(),
                image: image,
                foodType: classify ?? "Unknown",
                description: mealDescription,
                timestamp: Date()
            )
            
            appState.addMeal(meal)
            
            // Reset for next meal
            selectedImage = nil
            mealDescription = ""
            showDescriptionInput = false
        })
        
    }
}

struct ProcessingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Analyzing your meal...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color("appPrimaryColor").opacity(0.9))
            .cornerRadius(15)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
