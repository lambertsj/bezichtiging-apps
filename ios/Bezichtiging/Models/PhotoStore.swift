import UIKit

enum PhotoStore {

    static func save(_ image: UIImage, viewingId: UUID) -> String? {
        let id = UUID().uuidString
        let dir = base.appendingPathComponent(viewingId.uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let data = image.bzCompressed() else { return nil }
        guard (try? data.write(to: dir.appendingPathComponent("\(id).jpg"))) != nil else { return nil }
        return id
    }

    static func load(id: String, viewingId: UUID) -> UIImage? {
        UIImage(contentsOfFile: filePath(id: id, viewingId: viewingId))
    }

    static func delete(id: String, viewingId: UUID) {
        try? FileManager.default.removeItem(atPath: filePath(id: id, viewingId: viewingId))
    }

    static func deleteAll(viewingId: UUID) {
        try? FileManager.default.removeItem(at: base.appendingPathComponent(viewingId.uuidString))
    }

    // MARK: – Helpers
    private static var base: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("bzPhotos", isDirectory: true)
    }

    private static func filePath(id: String, viewingId: UUID) -> String {
        base.appendingPathComponent(viewingId.uuidString)
            .appendingPathComponent("\(id).jpg").path
    }
}

private extension UIImage {
    func bzCompressed() -> Data? {
        let maxDim: CGFloat = 1200
        let scale = min(maxDim / max(size.width, size.height), 1)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.75)
    }
}
