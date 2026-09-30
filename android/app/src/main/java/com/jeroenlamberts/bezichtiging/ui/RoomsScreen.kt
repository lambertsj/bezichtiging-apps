package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoomsScreen(viewingId: String, navController: NavController) {
    val store = LocalStore.current
    val viewings by store.viewings.collectAsState()
    val viewing = viewings.firstOrNull { it.id == viewingId } ?: return
    val market = viewing.marketEnum()
    var showInfo by remember { mutableStateOf(false) }

    val allThemes = ChecklistData.themes(viewing.type, market)
    val featured = allThemes.firstOrNull { it.featured }
    val rest = allThemes.filter { !it.featured }
    val rooms = ChecklistData.rooms(viewing.type, market)
    val roomsAnswered = rooms.count {
        ChecklistData.answeredCount(it.id, viewing.answers, viewing.type, viewing.tenure, market) > 0
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(viewing.name, fontWeight = FontWeight.SemiBold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { showInfo = true }) {
                        Icon(Icons.Filled.Info, contentDescription = "Info")
                    }
                    IconButton(onClick = { navController.navigate("export/$viewingId") }) {
                        Icon(Icons.Filled.Share, contentDescription = "Export")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = BzBg)
            )
        },
        containerColor = BzBg
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(bottom = 32.dp)
        ) {
            // Header
            item {
                Column(
                    modifier = Modifier.padding(horizontal = 20.dp).padding(top = 8.dp, bottom = 4.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(viewing.name, fontSize = 32.sp, fontWeight = FontWeight.Bold, color = BzFg)
                    Text(L.roomsSubtitle(market), fontSize = 15.sp, color = BzMuted)
                }
            }

            // Featured theme card
            featured?.let { f ->
                item {
                    FeaturedCard(
                        theme = f,
                        viewing = viewing,
                        market = market,
                        modifier = Modifier
                            .padding(horizontal = 20.dp)
                            .padding(top = 20.dp)
                            .clickable { navController.navigate("checklist/$viewingId/${f.id}/false") }
                    )
                }
            }

            // Category list
            item {
                Column(
                    modifier = Modifier.padding(horizontal = 20.dp).padding(top = 24.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(
                            L.categories(market).uppercase(),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 0.5.sp,
                            color = BzMuted
                        )
                        Text("${rest.size}", fontSize = 14.sp, color = BzMuted)
                    }
                    BZCard {
                        rest.forEachIndexed { idx, theme ->
                            EntryRow(
                                entryId = theme.id,
                                label = theme.label,
                                sub = theme.sub,
                                viewing = viewing,
                                market = market,
                                icon = theme.icon,
                                onClick = { navController.navigate("checklist/$viewingId/${theme.id}/false") }
                            )
                            if (idx < rest.size - 1) BZDivider(Modifier.padding(start = 56.dp))
                        }
                    }
                }
            }

            // Individual rooms button
            item {
                Row(
                    modifier = Modifier
                        .padding(horizontal = 20.dp)
                        .padding(top = 16.dp)
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(18.dp))
                        .background(BzSurface)
                        .border(1.dp, BzLine, RoundedCornerShape(18.dp))
                        .clickable { navController.navigate("individualRooms/$viewingId") }
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier.size(36.dp).clip(RoundedCornerShape(12.dp)).background(BzBg),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Filled.List, contentDescription = null, tint = BzFg, modifier = Modifier.size(18.dp))
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(L.individualRooms(market), fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
                        Text(L.individualRoomsSub(market), fontSize = 13.sp, color = BzMuted)
                    }
                    Text("$roomsAnswered/${rooms.size}", fontSize = 14.sp, color = BzMuted)
                    BZChevron()
                }
            }

            // Export button
            item {
                Row(
                    modifier = Modifier
                        .padding(horizontal = 20.dp)
                        .padding(top = 10.dp)
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(18.dp))
                        .background(BzSurface)
                        .border(1.dp, BzLine, RoundedCornerShape(18.dp))
                        .clickable { navController.navigate("export/$viewingId") }
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier.size(36.dp).clip(RoundedCornerShape(12.dp)).background(BzBg),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Filled.Share, contentDescription = null, tint = BzFg, modifier = Modifier.size(18.dp))
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(L.exportPDF(market), fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
                        Text(L.exportPDFSub(market), fontSize = 13.sp, color = BzMuted)
                    }
                    BZChevron()
                }
            }
        }
    }

    // Info sheet
    if (showInfo) {
        ViewingInfoSheet(viewing = viewing, market = market, onDismiss = { showInfo = false })
    }
}

@Composable
private fun FeaturedCard(theme: Theme, viewing: Viewing, market: Market, modifier: Modifier = Modifier) {
    val ans = ChecklistData.answeredCount(theme.id, viewing.answers, viewing.type, viewing.tenure, market)
    val tot = ChecklistData.totalItems(theme.id, viewing.type, viewing.tenure, market)
    val hasNote = (viewing.notes[theme.id] ?: "").isNotEmpty()

    Row(
        modifier = modifier
            .fillMaxWidth()
            .shadow(4.dp, RoundedCornerShape(22.dp))
            .clip(RoundedCornerShape(22.dp))
            .background(BzSurface)
            .border(1.5.dp, BzAccent.copy(alpha = 0.35f), RoundedCornerShape(22.dp))
            .padding(22.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Icon(iconForId(theme.icon), contentDescription = null, tint = BzMuted, modifier = Modifier.size(13.dp))
                Text(
                    L.beginHere(market).uppercase(),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    letterSpacing = 0.8.sp,
                    color = BzAccent
                )
            }
            Text(theme.label, fontSize = 22.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
            Text(theme.sub, fontSize = 14.sp, color = BzMuted)
        }
        Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(6.dp)) {
            if (hasNote) NoteBadge()
            Text("$ans/$tot", fontSize = 14.sp, color = BzAccent)
            Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = BzAccent, modifier = Modifier.size(16.dp))
        }
    }
}

@Composable
fun EntryRow(
    entryId: String,
    label: String,
    sub: String,
    viewing: Viewing,
    market: Market,
    icon: String? = null,
    onClick: () -> Unit
) {
    val ans = ChecklistData.answeredCount(entryId, viewing.answers, viewing.type, viewing.tenure, market)
    val tot = ChecklistData.totalItems(entryId, viewing.type, viewing.tenure, market)
    val hasNote = (viewing.notes[entryId] ?: "").isNotEmpty()

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        if (icon != null) {
            Box(
                modifier = Modifier.size(36.dp).clip(RoundedCornerShape(11.dp)).background(BzBg),
                contentAlignment = Alignment.Center
            ) {
                Icon(iconForId(icon), contentDescription = null, tint = BzMuted, modifier = Modifier.size(17.dp))
            }
        } else {
            RoomMarker(ans, tot, label.take(1))
        }
        Column(modifier = Modifier.weight(1f)) {
            Text(label, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
            Text(sub, fontSize = 13.sp, color = BzMuted)
        }
        if (hasNote) NoteBadge()
        Text("$ans/$tot", fontSize = 14.sp, color = BzMuted)
        BZChevron()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ViewingInfoSheet(viewing: Viewing, market: Market, onDismiss: () -> Unit) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState, containerColor = BzBg) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 32.dp)
        ) {
            Text(viewing.name, fontSize = 20.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
            Spacer(Modifier.height(16.dp))
            BZCard {
                InfoRow(label = L.labelType(market), value = viewing.type.label(market), iconName = viewing.type.systemIcon)
                BZDivider(Modifier.padding(start = 56.dp))
                InfoRow(label = L.labelTenure(market), value = viewing.tenure.longLabel(market), iconName = viewing.tenure.systemIcon)
            }
            Spacer(Modifier.height(32.dp))
        }
    }
}

@Composable
private fun InfoRow(label: String, value: String, iconName: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier.size(36.dp).clip(RoundedCornerShape(11.dp)).background(BzBg),
            contentAlignment = Alignment.Center
        ) {
            Icon(iconForId(iconName), contentDescription = null, tint = BzFg, modifier = Modifier.size(17.dp))
        }
        Text(label, fontSize = 16.sp, color = BzMuted, modifier = Modifier.weight(1f))
        Text(value, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
    }
}
