package com.jeroenlamberts.bezichtiging.ui

import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.data.PhotoStore
import com.jeroenlamberts.bezichtiging.models.L
import com.jeroenlamberts.bezichtiging.models.Market
import java.io.File

@Composable
fun PhotoStripRow(
    viewingId: String,
    entryId: String,
    photoIds: List<String>,
    market: Market,
    onAddPhoto: () -> Unit,
    onRemovePhoto: (String) -> Unit
) {
    val context = LocalContext.current
    var removeTarget by remember { mutableStateOf<String?>(null) }

    // Nothing to show if no photos and can't add (shouldn't happen, but guard it)
    if (photoIds.isEmpty() && photoIds.size >= 2) return

    LazyRow(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Existing photos
        items(photoIds.size) { idx ->
            val photoId = photoIds[idx]
            val path = PhotoStore.path(context, viewingId, photoId)
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(12.dp))
            ) {
                AsyncImage(
                    model = File(path),
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )
                // Remove button
                Box(
                    modifier = Modifier
                        .padding(4.dp)
                        .size(20.dp)
                        .clip(CircleShape)
                        .background(Color.Black.copy(alpha = 0.5f))
                        .clickable { removeTarget = photoId }
                        .align(Alignment.TopEnd),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Filled.Close,
                        contentDescription = "Remove",
                        tint = Color.White,
                        modifier = Modifier.size(12.dp)
                    )
                }
            }
        }

        // Add button (max 2 photos)
        if (photoIds.size < 2) {
            item {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(BzBg)
                        .border(1.dp, BzLine, RoundedCornerShape(12.dp))
                        .clickable(onClick = onAddPhoto),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(Icons.Filled.CameraAlt, contentDescription = "Add photo", tint = BzMuted, modifier = Modifier.size(22.dp))
                        Text(L.photoButtonLabel(market), fontSize = 10.sp, color = BzMuted)
                    }
                }
            }
        }
    }

    // Remove confirm
    removeTarget?.let { photoId ->
        AlertDialog(
            onDismissRequest = { removeTarget = null },
            title = { Text("Remove photo?") },
            confirmButton = {
                TextButton(onClick = {
                    onRemovePhoto(photoId)
                    removeTarget = null
                }) { Text("Remove", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = {
                TextButton(onClick = { removeTarget = null }) { Text("Cancel") }
            }
        )
    }
}
