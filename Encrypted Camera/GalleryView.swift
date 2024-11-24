import SwiftUI
import CryptoKit

struct GalleryView: View {
    @Binding var images: [UIImage] // Bind to the ContentView's decryptedImages array
    @Environment(\.dismiss) var dismiss // Environment property to dismiss the sheet
    @State private var encryptionKey = SymmetricKey(size: .bits256) // Use the same key for encryption
    @State private var isLocked = false

    var body: some View {
        NavigationView {
            VStack {
                // Lock/Unlock Buttons
                HStack {
                    Button(action: lockFiles) {
                        Text("Lock Photos")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    Button(action: unlockFiles) {
                        Text("Unlock Photos")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                // Scrollable Image Gallery
                ScrollView {
                    VStack {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 200)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Gallery", displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                dismiss() // Dismiss the sheet programmatically
            })
        }
    }

    // Lock Files: Encrypt the decrypted images back into files
    func lockFiles() {
        let fileManager = FileManager.default

        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let folderURL = documentsURL.appendingPathComponent("EncryptedPhotos")

            for (index, image) in images.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    let sealedBox = try AES.GCM.seal(imageData, using: encryptionKey)
                    if let encryptedData = sealedBox.combined {
                        let fileURL = folderURL.appendingPathComponent("photo_\(index).enc")
                        try encryptedData.write(to: fileURL)
                    }
                }
            }

            images.removeAll() // Clear decrypted images from memory
            isLocked = true
            print("Photos locked successfully!")
        } catch {
            print("Failed to lock files: \(error)")
        }
    }

    // Unlock Files: Decrypt the files back into images
    func unlockFiles() {
        images.removeAll() // Clear existing images

        let fileManager = FileManager.default

        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let folderURL = documentsURL.appendingPathComponent("EncryptedPhotos")

            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

            for fileURL in fileURLs {
                if let data = try? Data(contentsOf: fileURL),
                   let sealedBox = try? AES.GCM.SealedBox(combined: data),
                   let decryptedData = try? AES.GCM.open(sealedBox, using: encryptionKey),
                   let image = UIImage(data: decryptedData) {
                    images.append(image)
                }
            }

            isLocked = false
            print("Photos unlocked successfully!")
        } catch {
            print("Failed to unlock files: \(error)")
        }
    }
}
