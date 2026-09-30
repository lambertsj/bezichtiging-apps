import SwiftUI
import PDFKit
import UIKit
import StoreKit

struct ExportView: View {
    let viewing: Viewing
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var pdfData: Data?
    @State private var showShare = false

    private static let pdfCountKey = "bz.pdfExportCount"

    var body: some View {
        NavigationStack {
            Group {
                if let data = pdfData {
                    PDFKitView(data: data)
                } else {
                    ProgressView("Rapport genereren…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.bzBg)
                }
            }
            .navigationTitle("Voorvertoning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sluiten") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if pdfData != nil {
                        Button {
                            showShare = true
                        } label: {
                            Label("Opslaan als PDF", systemImage: "arrow.down.doc")
                        }
                    }
                }
            }
        }
        .task {
            pdfData = PDFGenerator.generate(viewing: viewing)
            requestReviewAfterThirdExport()
        }
        .sheet(isPresented: $showShare) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }

    // MARK: – Review request helper (runs once, when the 3rd PDF is generated)
    private func requestReviewAfterThirdExport() {
        let count = UserDefaults.standard.integer(forKey: Self.pdfCountKey) + 1
        UserDefaults.standard.set(count, forKey: Self.pdfCountKey)
        if count == 3 { requestReview() }
    }
}

// MARK: – PDFKit viewer
private struct PDFKitView: UIViewRepresentable {
    let data: Data
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.displayDirection = .vertical
        v.backgroundColor = UIColor(Color.bzBg)
        return v
    }
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
}

// MARK: – PDF generator
enum PDFGenerator {
    static func generate(viewing: Viewing) -> Data {
        let pageW: CGFloat = 595.2; let pageH: CGFloat = 841.8
        let margin: CGFloat = 50; let contentW = pageW - 2 * margin
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageW, height: pageH))
        return renderer.pdfData { ctx in
            var y: CGFloat = margin
            func newPage() { ctx.beginPage(); y = margin }
            func checkPageBreak(needed: CGFloat) { if y + needed > pageH - margin { newPage() } }

            ctx.beginPage()

            // Accent colour
            let accent = UIColor(Color.bzAccent)
            let fg = UIColor(Color.bzFg)
            let muted = UIColor(Color.bzMuted)
            let good = UIColor(Color.bzGoodInk)
            let bad = UIColor(Color.bzBadInk)
            let goodSoft = UIColor(Color.bzGoodSoft)
            let badSoft = UIColor(Color.bzBadSoft)

            func attr(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = UIColor(Color.bzFg)) -> NSAttributedString {
                NSAttributedString(string: text, attributes: [
                    .font: UIFont.systemFont(ofSize: size, weight: weight),
                    .foregroundColor: color,
                ])
            }

            func drawText(_ s: NSAttributedString, x: CGFloat = margin, width: CGFloat? = nil, maxH: CGFloat = 1000) -> CGFloat {
                let w = width ?? contentW
                let rect = CGRect(x: x, y: y, width: w, height: maxH)
                let h = s.boundingRect(with: CGSize(width: w, height: maxH), options: .usesLineFragmentOrigin, context: nil).height
                s.draw(in: rect)
                return h
            }

            // Draws up to 2 photos side-by-side. Uses aspect-fit within a fixed row height.
            func drawPhotoRow(_ photos: [UIImage], rowH: CGFloat) {
                guard !photos.isEmpty else { return }
                let count = min(photos.count, 2)
                let gap: CGFloat = 8
                let imgW = count == 1 ? contentW : (contentW - gap) / 2
                checkPageBreak(needed: rowH + 8)
                for i in 0..<count {
                    let ix = margin + CGFloat(i) * (imgW + gap)
                    let imgRect = CGRect(x: ix, y: y, width: imgW, height: rowH)
                    // White background
                    UIColor.white.setFill()
                    UIBezierPath(roundedRect: imgRect, cornerRadius: 4).fill()
                    // Aspect-fit the image
                    let img = photos[i]
                    let aspect = img.size.height / img.size.width
                    let fitH = min(rowH, imgW * aspect)
                    let fitW = min(imgW, rowH / max(aspect, 0.001))
                    let fitRect = CGRect(x: ix + (imgW - fitW) / 2, y: y + (rowH - fitH) / 2, width: fitW, height: fitH)
                    img.draw(in: fitRect)
                    // Border
                    let bp = UIBezierPath(roundedRect: imgRect, cornerRadius: 4)
                    UIColor(Color.bzLine).setStroke(); bp.lineWidth = 0.5; bp.stroke()
                }
                y += rowH + 8
            }

            // Eye-brow
            let eyebrow = attr("BEZICHTIGINGSRAPPORT", size: 10, weight: .bold, color: accent)
            y += drawText(eyebrow) + 8

            // Title
            let title = attr(viewing.name, size: 24, weight: .bold)
            checkPageBreak(needed: 40)
            y += drawText(title) + 6

            // Meta
            let df = DateFormatter(); df.dateStyle = .long
            df.locale = viewing.market.isEnglish ? Locale(identifier: "en_GB") : Locale(identifier: "nl_NL")
            let viewedOn = viewing.market.isEnglish ? "Viewed on" : "Bezichtigd op"
            let metaStr = "\(viewing.type.label(for: viewing.market)) · \(viewing.tenure.longLabel(for: viewing.market)) · \(viewedOn) \(df.string(from: viewing.date))"
            let meta = attr(metaStr, size: 11, color: muted)
            y += drawText(meta) + 14

            // Divider
            let divPath = UIBezierPath()
            divPath.move(to: CGPoint(x: margin, y: y))
            divPath.addLine(to: CGPoint(x: pageW - margin, y: y))
            UIColor(Color.bzLine).setStroke(); divPath.lineWidth = 0.5; divPath.stroke()
            y += 14

            // Summary stats
            let s = viewing.score
            let naCount = viewing.answers.values.filter { $0 == .na }.count
            let statW = contentW / 3 - 6
            let stats: [(String, String, UIColor)] = [
                ("\(s.goed)", L.ratingGood(viewing.market), good),
                ("\(s.niet)", L.ratingBad(viewing.market), bad),
                ("\(naCount)", L.ratingNA(viewing.market).uppercased(), muted),
            ]
            let statH: CGFloat = 56
            for (i, stat) in stats.enumerated() {
                let rx = margin + CGFloat(i) * (statW + 9)
                let r = CGRect(x: rx, y: y, width: statW, height: statH)
                let p = UIBezierPath(roundedRect: r, cornerRadius: 8)
                UIColor.white.setFill(); p.fill()
                UIColor(Color.bzLine).setStroke(); p.lineWidth = 0.5; p.stroke()
                // number
                let numA = attr(stat.0, size: 22, weight: .bold, color: stat.2)
                numA.draw(at: CGPoint(x: rx + 12, y: y + 8))
                // label
                let lblA = attr(stat.1, size: 10, color: muted)
                lblA.draw(at: CGPoint(x: rx + 12, y: y + 34))
            }
            y += statH + 22

            // Content sections
            let sections = ChecklistData.themes(for: viewing.type, market: viewing.market).map { $0.id }
                         + ChecklistData.rooms(for: viewing.type, market: viewing.market).map { $0.id }

            for entryId in sections {
                let flat = ChecklistData.flatItems(entryId: entryId, type: viewing.type, tenure: viewing.tenure, market: viewing.market)
                let answered = flat.compactMap { fi -> (FlatItem, Rating)? in
                    guard let r = viewing.answers[fi.key] else { return nil }
                    return (fi, r)
                }
                let note = (viewing.notes[entryId] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let sectionPhotoIds = viewing.photoIds[entryId] ?? []
                guard !answered.isEmpty || !note.isEmpty || !sectionPhotoIds.isEmpty else { continue }

                let label = ChecklistData.themes(for: viewing.type, market: viewing.market).first { $0.id == entryId }?.label
                         ?? ChecklistData.rooms(for: viewing.type, market: viewing.market).first { $0.id == entryId }?.label ?? entryId

                checkPageBreak(needed: 50)
                // Room heading
                let divPath2 = UIBezierPath()
                divPath2.move(to: CGPoint(x: margin, y: y))
                divPath2.addLine(to: CGPoint(x: pageW - margin, y: y))
                UIColor(Color.bzLine).setStroke(); divPath2.lineWidth = 0.5; divPath2.stroke()
                y += 12

                let roomHead = attr(label, size: 15, weight: .bold)
                y += drawText(roomHead) + 10

                // Items by category
                var byCat: [(String, [(FlatItem, Rating)])] = []
                for (fi, r) in answered {
                    if let idx = byCat.firstIndex(where: { $0.0 == fi.category }) {
                        byCat[idx].1.append((fi, r))
                    } else {
                        byCat.append((fi.category, [(fi, r)]))
                    }
                }

                let noteLabel = viewing.market.isEnglish ? "NOTE" : "OPMERKING"

                for (cat, catItems) in byCat {
                    checkPageBreak(needed: 30)
                    let catHead = attr(cat.uppercased(), size: 9, weight: .semibold, color: muted)
                    y += drawText(catHead) + 6
                    for (fi, rating) in catItems {
                        checkPageBreak(needed: 22)
                        // Item text
                        let itemA = attr(fi.item.label, size: 11.5, color: fg)
                        let ih = drawText(itemA, x: margin, width: contentW - 70)
                        // Badge
                        let badgeLabel = rating.reportBadge
                        let badgeFg: UIColor = rating == .goed ? good : rating == .niet ? bad : muted
                        let badgeBg: UIColor = rating == .goed ? goodSoft : rating == .niet ? badSoft : UIColor(Color.bzBg)
                        let badgeA = attr(badgeLabel, size: 9, weight: .semibold, color: badgeFg)
                        let bw: CGFloat = badgeA.size().width + 16
                        let bx = pageW - margin - bw
                        let br = CGRect(x: bx, y: y, width: bw, height: 16)
                        let bp = UIBezierPath(roundedRect: br, cornerRadius: 8)
                        badgeBg.setFill(); bp.fill()
                        badgeA.draw(at: CGPoint(x: bx + 8, y: y + 3.5))
                        y += max(ih, 16) + 5

                        // Item-level note
                        let itemNote = (viewing.itemNotes[fi.key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        if !itemNote.isEmpty {
                            let noteMs = NSMutableAttributedString(attributedString: attr("\(noteLabel)  ", size: 8, weight: .semibold, color: accent))
                            noteMs.append(attr(itemNote, size: 10, color: muted))
                            let noteH = noteMs.boundingRect(with: CGSize(width: contentW - 24, height: 1000),
                                                            options: .usesLineFragmentOrigin, context: nil).height
                            checkPageBreak(needed: noteH + 6)
                            noteMs.draw(in: CGRect(x: margin + 12, y: y, width: contentW - 24, height: noteH + 4))
                            y += noteH + 6
                        }

                        // Item-level photos
                        let itemPhotos = (viewing.itemPhotoIds[fi.key] ?? [])
                            .compactMap { PhotoStore.load(id: $0, viewingId: viewing.id) }
                        if !itemPhotos.isEmpty {
                            drawPhotoRow(itemPhotos, rowH: 150)
                            y += 2
                        }
                    }
                    y += 4
                }

                // Section-level note
                if !note.isEmpty {
                    checkPageBreak(needed: 50)
                    let noteMs = NSMutableAttributedString(attributedString: attr("\(noteLabel)\n", size: 9, weight: .bold, color: accent))
                    noteMs.append(attr(note, size: 11, color: fg))
                    let noteText: NSAttributedString = noteMs
                    let nh = noteText.boundingRect(with: CGSize(width: contentW - 20, height: 1000),
                                                  options: .usesLineFragmentOrigin, context: nil).height + 20
                    let np = UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: contentW, height: nh), cornerRadius: 6)
                    UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1).setFill(); np.fill()
                    // left accent bar
                    let barP = UIBezierPath(rect: CGRect(x: margin, y: y, width: 2, height: nh))
                    accent.setFill(); barP.fill()
                    noteText.draw(in: CGRect(x: margin + 12, y: y + 10, width: contentW - 20, height: nh))
                    y += nh + 10
                }

                // Section-level photos
                let sectionPhotos = sectionPhotoIds
                    .compactMap { PhotoStore.load(id: $0, viewingId: viewing.id) }
                if !sectionPhotos.isEmpty {
                    drawPhotoRow(sectionPhotos, rowH: 190)
                }
                y += 8
            }

            // Footer
            checkPageBreak(needed: 30)
            let today = df.string(from: Date())
            let generatedOn = viewing.market.isEnglish ? "Generated on" : "Gegenereerd op"
            let footerA = attr("\(generatedOn) \(today) · \(L.appName(viewing.market))", size: 9, color: muted)
            let divF = UIBezierPath()
            divF.move(to: CGPoint(x: margin, y: y)); divF.addLine(to: CGPoint(x: pageW - margin, y: y))
            UIColor(Color.bzLine).setStroke(); divF.lineWidth = 0.5; divF.stroke()
            y += 10
            footerA.draw(at: CGPoint(x: margin, y: y))
        }
    }
}

// MARK: – Share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
