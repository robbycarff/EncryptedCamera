//
//  ContentView.swift
//  Encrypted Camera
//
//  Created by Robby Carff on 11/21/24.
//

import SwiftUI
import CryptoKit

import SwiftUI
import CryptoKit

struct ContentView: View {
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var decryptedImages: [UIImage] = []

    var body: some View {
        HStack {
            // Camera Button
            Button(action: {
                showCamera = true
            }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    if let capturedImage = image {
                        encryptAndSave(image: capturedImage)
                    } else {
                        print("Camera cancelled")
                    }
                }
            }

            // Folder Button
            Button(action: {
                loadDecryptedImages()
                showGallery = true
            }) {
                Image(systemName: "folder")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .sheet(isPresented: $showGallery) {
                GalleryView(images: $decryptedImages)
            }
        }
        .padding()
    }
    // Encrypt and Save Method (from previous implementation)
    func encryptAndSave(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to data.")
            return
        }

        let key = SymmetricKey(size: .bits256)

        do {
            let sealedBox = try AES.GCM.seal(imageData, using: key)
            if let encryptedData = sealedBox.combined {
                saveToFolder(data: encryptedData)
            } else {
                print("Failed to retrieve combined encrypted data.")
            }
        } catch {
            print("Encryption failed: \(error)")
        }
    }

    func saveToFolder(data: Data) {
        let fileManager = FileManager.default
        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let folderURL = documentsURL.appendingPathComponent("EncryptedPhotos")

            if !fileManager.fileExists(atPath: folderURL.path) {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }

            let timestamp = Int(Date().timeIntervalSince1970)
            let fileURL = folderURL.appendingPathComponent("photo_\(timestamp).enc")

            try data.write(to: fileURL)
            print("Encrypted photo saved to: \(fileURL.path)")
        } catch {
            print("Failed to save file: \(error)")
        }
    }

    // Load Decrypted Images from Folder
    func loadDecryptedImages() {
        decryptedImages.removeAll() // Clear existing images

        let fileManager = FileManager.default
        let key = SymmetricKey(size: .bits256) // Use the same key used for encryption

        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let folderURL = documentsURL.appendingPathComponent("EncryptedPhotos")

            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

            for fileURL in fileURLs {
                if let data = try? Data(contentsOf: fileURL),
                   let sealedBox = try? AES.GCM.SealedBox(combined: data),
                   let decryptedData = try? AES.GCM.open(sealedBox, using: key),
                   let image = UIImage(data: decryptedData) {
                    decryptedImages.append(image)
                }
            }
        } catch {
            print("Failed to load or decrypt files: \(error)")
        }
    }
}
#Preview {
    ContentView()
}
