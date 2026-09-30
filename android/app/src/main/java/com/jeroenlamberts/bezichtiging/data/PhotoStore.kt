package com.jeroenlamberts.bezichtiging.data

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File
import java.util.UUID

object PhotoStore {

    private fun dir(context: Context, viewingId: String): File =
        File(context.filesDir, "photos/$viewingId").also { it.mkdirs() }

    fun save(context: Context, viewingId: String, bitmap: Bitmap): String {
        val id = UUID.randomUUID().toString()
        val file = File(dir(context, viewingId), "$id.jpg")
        file.outputStream().use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out)
        }
        return id
    }

    fun load(context: Context, viewingId: String, photoId: String): Bitmap? {
        val file = File(dir(context, viewingId), "$photoId.jpg")
        return if (file.exists()) BitmapFactory.decodeFile(file.absolutePath) else null
    }

    fun path(context: Context, viewingId: String, photoId: String): String =
        File(dir(context, viewingId), "$photoId.jpg").absolutePath

    fun delete(context: Context, viewingId: String, photoId: String) {
        File(dir(context, viewingId), "$photoId.jpg").delete()
    }

    fun deleteAll(context: Context, viewingId: String) {
        dir(context, viewingId).deleteRecursively()
    }
}
