//
//  CameraView.swift
//  Encrypted Camera
//
//  Created by Robby Carff on 11/23/24.
//

import SwiftUI
import UIKit

// Step 1: A struct to bridge UIImagePickerController into SwiftUI
struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var didFinishPicking: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            parent.didFinishPicking(image)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.didFinishPicking(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
