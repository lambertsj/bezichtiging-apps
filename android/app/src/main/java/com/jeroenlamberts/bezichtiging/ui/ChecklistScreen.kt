package com.jeroenlamberts.bezichtiging.ui

import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChecklistScreen(viewingId: String, entryId: String, isRoom: Boolean, navController: NavController) {
    val store = LocalStore.current
    val viewings by store.viewings.collectAsState()
    val viewing = viewings.firstOrNull { it.id == viewingId } ?: return
    val market = viewing.marketEnum()
    val context = LocalContext.current

    val entryLabel = remember(viewing.type, market) {
        ChecklistData.themes(viewing.type, market).firstOrNull { it.id == entryId }?.label
            ?: ChecklistData.rooms(viewing.type, market).firstOrNull { it.id == entryId }?.label
            ?: entryId
    }

    val groups = remember(viewing.type, viewing.tenure, market) {
        ChecklistData.groups(entryId, viewing.type, viewing.tenure, market)
    }
    val flat = remember(viewing.type, viewing.tenure, market) {
        ChecklistData.flatItems(entryId, viewing.type, viewing.tenure, market)
    }
    val answered = flat.count { viewing.answers.containsKey(it.key) }
    val note = viewing.notes[entryId] ?: ""

    var showItemDetail by remember { mutableStateOf<FlatItem?>(null) }

    // Photo picker for entry-level photos
    val photoPicker = rememberLauncherForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        uri?.let {
            val bmp = context.contentResolver.openInputStream(it)
                ?.use { s -> BitmapFactory.decodeStream(s) } ?: return@let
            store.addPhoto(viewingId, entryId, bmp)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(entryLabel, fontWeight = FontWeight.SemiBold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = BzBg)
            )
        },
        containerColor = BzBg
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(bottom = 40.dp)
        ) {
            // Header
            item {
                Column(
                    modifier = Modifier.padding(horizontal = 20.dp).padding(top = 8.dp, bottom = 20.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(entryLabel, fontSize = 32.sp, fontWeight = FontWeight.Bold, color = BzFg)
                    Text(L.answeredOf(answered, flat.size, market), fontSize = 15.sp, color = BzMuted)
                }
            }

            // Photo strip
            item {
                PhotoStripRow(
                    viewingId = viewingId,
                    entryId = entryId,
                    photoIds = viewing.photoIds[entryId] ?: emptyList(),
                    market = market,
                    onAddPhoto = {
                        photoPicker.launch(
                            androidx.activity.result.PickVisualMediaRequest(
                                ActivityResultContracts.PickVisualMedia.ImageOnly
                            )
                        )
                    },
                    onRemovePhoto = { photoId -> store.removePhoto(viewingId, entryId, photoId) }
                )
            }

            // Checklist groups
            groups.forEach { group ->
                item {
                    Column(
                        modifier = Modifier.padding(horizontal = 20.dp).padding(top = 24.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        CatHeader(group.category)
                        BZCard {
                            group.items.forEachIndexed { idx, item ->
                                val fi = flat.firstOrNull { it.item.label == item.label && it.item.hint == item.hint }
                                fi?.let {
                                    ItemRow(
                                        viewingId = viewingId,
                                        flatItem = it,
                                        value = viewing.rating(it.key),
                                        market = market,
                                        itemNote = viewing.itemNotes[it.key],
                                        itemPhotoIds = viewing.itemPhotoIds[it.key] ?: emptyList(),
                                        onChange = { rating -> store.setAnswer(viewingId, it.key, rating) },
                                        onOpenDetail = { showItemDetail = it }
                                    )
                                    if (idx < group.items.size - 1) BZDivider(Modifier.padding(start = 16.dp))
                                }
                            }
                        }
                    }
                }
            }

            // Note field
            item {
                Column(
                    modifier = Modifier.padding(horizontal = 20.dp).padding(top = 24.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    CatHeader(L.note(market))
                    BZCard {
                        NoteField(
                            text = note,
                            placeholder = if (isRoom) L.notePlaceholder(market) else L.notePlaceholderSection(market),
                            onChange = { store.setNote(viewingId, entryId, it) }
                        )
                    }
                }
            }

            // Done button
            item {
                Button(
                    onClick = { navController.popBackStack() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp)
                        .padding(top = 20.dp)
                        .height(56.dp),
                    shape = RoundedCornerShape(50),
                    colors = ButtonDefaults.buttonColors(containerColor = BzFg)
                ) {
                    Text(
                        L.doneWith(entryLabel, market),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.White
                    )
                }
            }
        }
    }

    // Item detail sheet
    showItemDetail?.let { fi ->
        ItemDetailSheet(
            viewingId = viewingId,
            flatItem = fi,
            market = market,
            onDismiss = { showItemDetail = null }
        )
    }
}

@Composable
private fun ItemRow(
    viewingId: String,
    flatItem: FlatItem,
    value: Rating?,
    market: Market,
    itemNote: String?,
    itemPhotoIds: List<String>,
    onChange: (Rating?) -> Unit,
    onOpenDetail: () -> Unit
) {
    val hasItemDetail = itemPhotoIds.isNotEmpty() || !itemNote.isNullOrBlank()

    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                flatItem.item.label,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = BzFg
            )
            flatItem.item.hint?.let {
                Text(it, fontSize = 13.sp, color = BzMuted)
            }
        }
        RatingControl(value = value, market = market) { rating ->
            onChange(rating)
            if (rating == Rating.NIET) onOpenDetail()
        }
        if (hasItemDetail) {
            ItemDetailBadge(
                photoCount = itemPhotoIds.size,
                hasNote = !itemNote.isNullOrBlank(),
                market = market,
                onTap = onOpenDetail
            )
        }
    }
}

@Composable
private fun ItemDetailBadge(photoCount: Int, hasNote: Boolean, market: Market, onTap: () -> Unit) {
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .background(BzBadSoft)
            .clickable(onClick = onTap)
            .padding(horizontal = 10.dp, vertical = 5.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (photoCount > 0) {
            Icon(Icons.Filled.CameraAlt, contentDescription = null, tint = BzBadInk, modifier = Modifier.size(12.dp))
            Text("$photoCount", fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = BzBadInk)
        }
        if (hasNote) {
            Icon(Icons.Filled.FormatQuote, contentDescription = null, tint = BzBadInk, modifier = Modifier.size(12.dp))
        }
        Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = BzBadInk.copy(alpha = 0.6f), modifier = Modifier.size(11.dp))
    }
}

@Composable
fun RatingControl(value: Rating?, market: Market, onChange: (Rating?) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
        RatingPill(
            label = L.ratingGood(market),
            icon = Icons.Filled.Check,
            rating = Rating.GOED,
            current = value,
            modifier = Modifier.weight(1f),
            onChange = onChange
        )
        RatingPill(
            label = L.ratingBad(market),
            icon = Icons.Filled.PriorityHigh,
            rating = Rating.NIET,
            current = value,
            modifier = Modifier.weight(1f),
            onChange = onChange
        )
        // N/A button
        val naActive = value == Rating.NA
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(12.dp))
                .background(if (naActive) BzBg else Color.Transparent)
                .border(
                    width = 1.dp,
                    color = if (naActive) BzFg.copy(alpha = 0.18f) else BzLine,
                    shape = RoundedCornerShape(12.dp)
                )
                .clickable { onChange(if (naActive) null else Rating.NA) }
                .padding(horizontal = 10.dp, vertical = 10.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                L.ratingNA(market),
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (naActive) BzFg else BzMuted
            )
        }
    }
}

@Composable
private fun RatingPill(
    label: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    rating: Rating,
    current: Rating?,
    modifier: Modifier = Modifier,
    onChange: (Rating?) -> Unit
) {
    val active = current == rating
    val isGood = rating == Rating.GOED
    val bg = when { active && isGood -> BzGoodSoft; active -> BzBadSoft; else -> Color.Transparent }
    val border = when { active && isGood -> BzGood; active -> BzBad; else -> BzLine }
    val fg = when { active && isGood -> BzGoodInk; active -> BzBadInk; else -> BzMuted }
    val markBg = when { active && isGood -> BzGood; active -> BzBad; else -> BzLine.copy(alpha = 0.5f) }

    Row(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(bg)
            .border(1.5.dp, border, RoundedCornerShape(12.dp))
            .clickable { onChange(if (active) null else rating) }
            .padding(horizontal = 12.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(18.dp)
                .clip(CircleShape)
                .background(if (active) markBg else Color.Transparent),
            contentAlignment = Alignment.Center
        ) {
            if (active) {
                Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(11.dp))
            } else {
                Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(Color.Transparent))
            }
        }
        Spacer(Modifier.width(6.dp))
        Text(label, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = fg)
    }
}

@Composable
fun NoteField(text: String, placeholder: String, onChange: (String) -> Unit) {
    var local by remember(text) { mutableStateOf(text) }
    Column(
        modifier = Modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box {
            BasicTextField(
                value = local,
                onValueChange = { v ->
                    if (v.length <= 240) {
                        local = v
                        onChange(v)
                    }
                },
                modifier = Modifier.fillMaxWidth().defaultMinSize(minHeight = 64.dp),
                textStyle = MaterialTheme.typography.bodyMedium.copy(color = BzFg, fontSize = 15.sp),
                decorationBox = { inner ->
                    Box {
                        if (local.isEmpty()) {
                            Text(placeholder, fontSize = 15.sp, color = BzMuted)
                        }
                        inner()
                    }
                }
            )
        }
        Text(
            "${local.length}/240",
            fontSize = 12.sp,
            color = BzMuted,
            modifier = Modifier.align(Alignment.End)
        )
    }
}

