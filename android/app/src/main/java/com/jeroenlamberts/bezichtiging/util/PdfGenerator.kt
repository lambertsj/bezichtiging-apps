package com.jeroenlamberts.bezichtiging.util

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.pdf.PdfDocument
import com.jeroenlamberts.bezichtiging.models.*
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

object PdfGenerator {

    private val bgColor   = Color.parseColor("#F4F1EC")
    private val fgColor   = Color.parseColor("#1C1917")
    private val mutedColor = Color.parseColor("#78716C")
    private val accentColor = Color.parseColor("#C2410C")
    private val goodColor  = Color.parseColor("#15803D")
    private val goodBgColor = Color.parseColor("#DCFCE7")
    private val badColor   = Color.parseColor("#B91C1C")
    private val badBgColor = Color.parseColor("#FEE2E2")

    fun generate(viewing: Viewing, outputFile: File) {
        val market = viewing.marketEnum()
        val isDutch = Market.isDeviceLanguageDutch
        val pageWidth = 595   // A4 points
        val pageHeight = 842

        val doc = PdfDocument()
        var pageNum = 1
        var page = doc.startPage(PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNum).create())
        var canvas = page.canvas
        var y = 0f

        fun newPage() {
            doc.finishPage(page)
            pageNum++
            page = doc.startPage(PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNum).create())
            canvas = page.canvas
            drawBackground(canvas, pageWidth, pageHeight)
            y = 40f
        }

        fun ensureSpace(needed: Float) {
            if (y + needed > pageHeight - 40f) newPage()
        }

        // Background
        drawBackground(canvas, pageWidth, pageHeight)
        y = 40f

        // Title
        val titlePaint = Paint().apply {
            color = fgColor
            textSize = 28f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            isAntiAlias = true
        }
        canvas.drawText(viewing.name, 40f, y + 28f, titlePaint)
        y += 44f

        // Meta info
        val metaPaint = Paint().apply {
            color = mutedColor
            textSize = 14f
            isAntiAlias = true
        }
        val fmt = SimpleDateFormat("d MMMM yyyy", if (isDutch) Locale("nl") else Locale.ENGLISH)
        val dateStr = fmt.format(Date(viewing.date))
        val typeStr = viewing.type.label(market)
        val tenureStr = viewing.tenure.longLabel(market)
        canvas.drawText("$typeStr · $tenureStr · $dateStr", 40f, y + 14f, metaPaint)
        y += 30f

        // Score summary
        val score = viewing.score()
        if (score.total > 0) {
            val scorePaint = Paint().apply {
                color = goodColor
                textSize = 14f
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                isAntiAlias = true
            }
            val label = if (isDutch) "${score.goed} van ${score.total} in orde" else "${score.goed} of ${score.total} good"
            canvas.drawText(label, 40f, y + 14f, scorePaint)
            y += 28f
        }

        // Separator
        val linePaint = Paint().apply { color = Color.parseColor("#1A1C1917"); strokeWidth = 1f }
        canvas.drawLine(40f, y, pageWidth - 40f, y, linePaint)
        y += 16f

        // Themes and items
        val themes = ChecklistData.themes(viewing.type, market)
        themes.forEach { theme ->
            val flat = ChecklistData.flatItems(theme.id, viewing.type, viewing.tenure, market)
            val answered = flat.filter { viewing.answers.containsKey(it.key) }
            if (answered.isEmpty()) return@forEach

            ensureSpace(40f)

            // Theme header
            val headerPaint = Paint().apply {
                color = accentColor
                textSize = 13f
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                isAntiAlias = true
            }
            canvas.drawText(theme.label.uppercase(), 40f, y + 13f, headerPaint)
            y += 24f

            answered.forEach { fi ->
                val rating = Rating.fromValue(viewing.answers[fi.key] ?: return@forEach)
                ensureSpace(26f)

                // Rating badge
                val badgeBg = when (rating) { Rating.GOED -> goodBgColor; Rating.NIET -> badBgColor; else -> Color.LTGRAY }
                val badgeFg = when (rating) { Rating.GOED -> goodColor; Rating.NIET -> badColor; else -> mutedColor }
                val badgePaint = Paint().apply { color = badgeBg; isAntiAlias = true }
                val badgeRect = android.graphics.RectF(40f, y + 2f, 108f, y + 20f)
                canvas.drawRoundRect(badgeRect, 6f, 6f, badgePaint)
                val badgeTextPaint = Paint().apply {
                    color = badgeFg; textSize = 10f
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                    isAntiAlias = true
                }
                canvas.drawText(rating.reportBadge(isDutch), 48f, y + 14f, badgeTextPaint)

                // Item label
                val itemPaint = Paint().apply { color = fgColor; textSize = 13f; isAntiAlias = true }
                canvas.drawText(fi.item.label, 120f, y + 14f, itemPaint)

                // Item note
                val itemNote = viewing.itemNotes[fi.key]
                if (!itemNote.isNullOrBlank()) {
                    y += 18f
                    ensureSpace(18f)
                    val notePaint = Paint().apply { color = mutedColor; textSize = 11f; isAntiAlias = true }
                    canvas.drawText("  ↳ $itemNote", 120f, y + 12f, notePaint)
                }

                y += 24f
            }

            // Section note
            val sectionNote = viewing.notes[theme.id]
            if (!sectionNote.isNullOrBlank()) {
                ensureSpace(36f)
                val notePaint = Paint().apply { color = mutedColor; textSize = 12f; isAntiAlias = true }
                canvas.drawText(if (isDutch) "Opmerking:" else "Note:", 40f, y + 14f, notePaint)
                y += 18f
                // Word-wrap the note
                wrapText(canvas, sectionNote, 40f, y, pageWidth - 80f, 12f, mutedColor) { newY -> y = newY }
                y += 8f
            }

            y += 8f
            canvas.drawLine(40f, y, pageWidth - 40f, y, linePaint)
            y += 16f
        }

        // Footer
        val footerPaint = Paint().apply { color = mutedColor; textSize = 10f; isAntiAlias = true }
        val footerText = if (isDutch) "Gegenereerd door Bezichtiging — www.bezichtiging.app" else "Generated by Home Viewing — www.bezichtiging.app"
        canvas.drawText(footerText, 40f, pageHeight - 24f, footerPaint)

        doc.finishPage(page)
        outputFile.parentFile?.mkdirs()
        doc.writeTo(FileOutputStream(outputFile))
        doc.close()
    }

    private fun drawBackground(canvas: Canvas, w: Int, h: Int) {
        val paint = Paint().apply { color = bgColor }
        canvas.drawRect(0f, 0f, w.toFloat(), h.toFloat(), paint)
    }

    private fun wrapText(
        canvas: Canvas,
        text: String,
        x: Float,
        startY: Float,
        maxWidth: Float,
        textSize: Float,
        color: Int,
        onNewY: (Float) -> Unit
    ) {
        val paint = Paint().apply { this.color = color; this.textSize = textSize; isAntiAlias = true }
        val words = text.split(" ")
        var line = ""
        var y = startY
        words.forEach { word ->
            val test = if (line.isEmpty()) word else "$line $word"
            if (paint.measureText(test) > maxWidth) {
                canvas.drawText(line, x, y + textSize, paint)
                y += textSize + 4f
                line = word
            } else {
                line = test
            }
        }
        if (line.isNotEmpty()) {
            canvas.drawText(line, x, y + textSize, paint)
            y += textSize + 4f
        }
        onNewY(y)
    }
}
