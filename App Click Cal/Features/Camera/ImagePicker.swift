//
//  ImagePicker.swift
//  App Click Cal
//
//  Created by Pushpendra on 24/05/25.
//

import SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var selectedImage: UIImage
    @Binding var selectedImageURL: String
    @Binding var imageURL: String
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.imageURL = "Image Selected"
                parent.selectedImageURL = "Image Selected"
            }
            if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                parent.selectedImageURL = imageURL.lastPathComponent
                parent.imageURL = imageURL.lastPathComponent
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
