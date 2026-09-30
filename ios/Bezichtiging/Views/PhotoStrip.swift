import SwiftUI
import PhotosUI
import AVFoundation

// MARK: – Photo strip (shown per entry in ChecklistView)
struct PhotoStrip: View {
    let viewingId: UUID
    let entryId: String
    let photoIds: [String]
    let market: Market

    @Environment(ViewingStore.self) private var store
    @State private var pickerItem: PhotosPickerItem?
    @State private var preview: PreviewItem?
    @State private var showSourceChoice = false
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false
    @State private var showPermissionAlert = false

    private struct PreviewItem: Identifiable { let id: String }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CatHeader(label: L.photos(market)).padding(.horizontal, 20)
            HStack(alignment: .top, spacing: 10) {
                ForEach(photoIds, id: \.self) { id in
                    PhotoThumb(id: id, viewingId: viewingId)
                        .onTapGesture { preview = PreviewItem(id: id) }
                        .overlay(alignment: .topTrailing) {
                            Button {
                                store.removePhoto(viewingId: viewingId,
                                                  entryId: entryId,
                                                  photoId: id)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color.bzSurface, Color.bzFg)
                                    .font(.system(size: 20))
                            }
                            .offset(x: 6, y: -6)
                        }
                }

                if photoIds.count < 2 {
                    Button { showSourceChoice = true } label: { AddPhotoButton(market: market) }
                        .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
            .confirmationDialog(L.addPhotoTitle(market), isPresented: $showSourceChoice,
                                titleVisibility: .visible) {
                Button(L.photoLibrary(market)) { isPhotoPickerPresented = true }
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") { requestCameraAccess() }
                }
                Button(L.cancel(market), role: .cancel) {}
            }
            .photosPicker(isPresented: $isPhotoPickerPresented,
                          selection: $pickerItem, matching: .images)
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraPicker(isPresented: $isCameraPresented, onImage: saveImage)
                    .ignoresSafeArea()
            }
            .alert(L.cameraPermissionTitle(market), isPresented: $showPermissionAlert) {
                Button(L.settings(market)) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(L.cancel(market), role: .cancel) {}
            } message: {
                Text(L.cameraPermissionMsg(market))
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task { @MainActor in
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        saveImage(image)
                    }
                    pickerItem = nil
                }
            }
            .sheet(item: $preview) { p in
                FullscreenPhotoView(id: p.id, viewingId: viewingId) {
                    store.removePhoto(viewingId: viewingId, entryId: entryId, photoId: p.id)
                }
            }
    }

    // MARK: – Helpers

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraPresented = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor [self] in
                    if granted { isCameraPresented = true }
                    else { showPermissionAlert = true }
                }
            }
        default:
            showPermissionAlert = true
        }
    }

    private func saveImage(_ image: UIImage) {
        guard let photoId = PhotoStore.save(image, viewingId: viewingId) else { return }
        store.addPhoto(viewingId: viewingId, entryId: entryId, photoId: photoId)
    }
}

// MARK: – Camera picker (UIImagePickerController)
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    @MainActor
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraPicker

        init(parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            if let image { parent.onImage(image) }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: – Thumbnail
struct PhotoThumb: View {
    let id: String
    let viewingId: UUID
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.bzLine.opacity(0.5))
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView().tint(Color.bzMuted)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear { image = PhotoStore.load(id: id, viewingId: viewingId) }
    }
}

// MARK: – Add button placeholder
struct AddPhotoButton: View {
    let market: Market
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.bzLine,
                              style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            VStack(spacing: 4) {
                Image(systemName: "camera")
                    .font(.system(size: 20, weight: .medium))
                Text(L.photoButtonLabel(market))
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(Color.bzMuted)
        }
        .frame(width: 80, height: 80)
    }
}

// MARK: – Full-screen preview sheet
struct FullscreenPhotoView: View {
    let id: String
    let viewingId: UUID
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView().tint(.white)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") { dismiss() }.tint(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { image = PhotoStore.load(id: id, viewingId: viewingId) }
    }
}
