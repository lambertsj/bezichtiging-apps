import SwiftUI
import PhotosUI
import AVFoundation

struct ItemDetailSheet: View {
    let viewingId: UUID
    let itemKey: String
    let item: ChecklistItem
    let market: Market

    @Environment(ViewingStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var note: String = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var showSourceChoice = false
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false
    @State private var showPermissionAlert = false
    @State private var previewId: String?

    private var photoIds: [String] {
        store.viewings.first { $0.id == viewingId }?.itemPhotoIds[itemKey] ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    itemHeader
                    photosSection
                    noteSection
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.bzBg)
            .navigationTitle(L.ratingBad(market))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.done(market)) { persistNoteAndDismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear { loadNote() }
        .onDisappear { persistNote() }
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
        .sheet(item: Binding(
            get: { previewId.map { FullscreenPreviewID(id: $0) } },
            set: { previewId = $0?.id }
        )) { p in
            FullscreenPhotoView(id: p.id, viewingId: viewingId) {
                store.removeItemPhoto(viewingId: viewingId, itemKey: itemKey, photoId: p.id)
            }
        }
    }

    // MARK: – Subviews

    private var itemHeader: some View {
        BZCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.bzFg)
                    .fixedSize(horizontal: false, vertical: true)
                if let hint = item.hint {
                    Text(hint)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.bzMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            CatHeader(label: L.photos(market))
            HStack(alignment: .top, spacing: 10) {
                ForEach(photoIds, id: \.self) { id in
                    PhotoThumb(id: id, viewingId: viewingId)
                        .onTapGesture { previewId = id }
                        .overlay(alignment: .topTrailing) {
                            Button {
                                store.removeItemPhoto(viewingId: viewingId, itemKey: itemKey, photoId: id)
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
                    Button { showSourceChoice = true } label: {
                        AddPhotoButton(market: market)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            CatHeader(label: L.itemDetailNoteLabel(market))
            BZCard {
                TextField(L.itemDetailNotePlaceholder(market), text: $note)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.bzFg)
                    .submitLabel(.done)
                    .padding(16)
            }
        }
    }

    // MARK: – Helpers

    private func loadNote() {
        note = store.viewings.first { $0.id == viewingId }?.itemNotes[itemKey] ?? ""
    }

    private func persistNote() {
        store.setItemNote(viewingId: viewingId, itemKey: itemKey, text: note)
    }

    private func persistNoteAndDismiss() {
        persistNote()
        dismiss()
    }

    private func saveImage(_ image: UIImage) {
        guard let photoId = PhotoStore.save(image, viewingId: viewingId) else { return }
        store.addItemPhoto(viewingId: viewingId, itemKey: itemKey, photoId: photoId)
    }

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
}

private struct FullscreenPreviewID: Identifiable { let id: String }
