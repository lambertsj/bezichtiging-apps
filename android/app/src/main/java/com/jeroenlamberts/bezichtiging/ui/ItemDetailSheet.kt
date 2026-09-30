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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.data.PhotoStore
import com.jeroenlamberts.bezichtiging.models.*
import java.io.File

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ItemDetailSheet(
    viewingId: String,
    flatItem: FlatItem,
    market: Market,
    onDismiss: () -> Unit
) {
    val store = LocalStore.current
    val viewings by store.viewings.collectAsState()
    val viewing = viewings.firstOrNull { it.id == viewingId } ?: return
    val context = LocalContext.current

    val photoIds = viewing.itemPhotoIds[flatItem.key] ?: emptyList()
    val note = viewing.itemNotes[flatItem.key] ?: ""

    val photoPicker = rememberLauncherForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        uri?.let {
            val bmp = context.contentResolver.openInputStream(it)
                ?.use { s -> BitmapFactory.decodeStream(s) } ?: return@let
            store.addItemPhoto(viewingId, flatItem.key, bmp)
        }
    }

    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = BzBg
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            // Title
            Text(flatItem.item.label, fontSize = 20.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
            flatItem.item.hint?.let {
                Text(it, fontSize = 14.sp, color = BzMuted)
            }

            Spacer(Modifier.height(20.dp))

            // Photos section
            Text(L.photos(market).uppercase(), fontSize = 12.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 0.8.sp, color = BzMuted)
            Spacer(Modifier.height(8.dp))

            LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                items(photoIds.size) { idx ->
                    val photoId = photoIds[idx]
                    val path = PhotoStore.path(context, viewingId, photoId)
                    Box(modifier = Modifier.size(90.dp).clip(RoundedCornerShape(12.dp))) {
                        AsyncImage(
                            model = File(path),
                            contentDescription = null,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )
                        Box(
                            modifier = Modifier
                                .padding(4.dp)
                                .size(20.dp)
                                .clip(CircleShape)
                                .background(Color.Black.copy(alpha = 0.5f))
                                .clickable { store.removeItemPhoto(viewingId, flatItem.key, photoId) }
                                .align(Alignment.TopEnd),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Filled.Close, contentDescription = "Remove", tint = Color.White, modifier = Modifier.size(12.dp))
                        }
                    }
                }
                if (photoIds.size < 2) {
                    item {
                        Box(
                            modifier = Modifier
                                .size(90.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(BzBg)
                                .border(1.dp, BzLine, RoundedCornerShape(12.dp))
                                .clickable {
                                    photoPicker.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                Icon(Icons.Filled.CameraAlt, contentDescription = null, tint = BzMuted, modifier = Modifier.size(22.dp))
                                Text(L.addPhotoTitle(market), fontSize = 10.sp, color = BzMuted)
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // Note section
            Text(L.itemDetailNoteLabel(market).uppercase(), fontSize = 12.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 0.8.sp, color = BzMuted)
            Spacer(Modifier.height(8.dp))
            BZCard {
                NoteField(
                    text = note,
                    placeholder = L.itemDetailNotePlaceholder(market),
                    onChange = { store.setItemNote(viewingId, flatItem.key, it) }
                )
            }

            Spacer(Modifier.height(16.dp))

            Button(
                onClick = onDismiss,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(50),
                colors = ButtonDefaults.buttonColors(containerColor = BzFg)
            ) {
                Text(L.done(market), fontWeight = FontWeight.SemiBold, color = Color.White)
            }
        }
    }
}
