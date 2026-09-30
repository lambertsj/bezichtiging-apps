package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.*
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun HomeScreen(navController: NavController) {
    val store = LocalStore.current
    val viewings by store.viewings.collectAsState()
    val market by store.market.collectAsState()
    var showNew by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }
    var contextViewing by remember { mutableStateOf<Viewing?>(null) }
    var pendingDelete by remember { mutableStateOf<Viewing?>(null) }
    var exportViewing by remember { mutableStateOf<Viewing?>(null) }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(BzBg),
        contentPadding = PaddingValues(bottom = 40.dp)
    ) {
        // Hero
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .padding(top = 56.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top
                ) {
                    Text(
                        text = L.homeTagline(market) + " 🏠",
                        fontSize = 30.sp,
                        fontWeight = FontWeight.Bold,
                        color = BzFg,
                        modifier = Modifier.weight(1f)
                    )
                    IconButton(
                        onClick = { showSettings = true },
                        modifier = Modifier
                            .shadow(4.dp, CircleShape)
                            .clip(CircleShape)
                            .background(BzSurface)
                    ) {
                        Icon(Icons.Filled.Settings, contentDescription = "Settings", tint = BzFg)
                    }
                }
                Text(
                    text = L.homeDescription(market),
                    fontSize = 15.sp,
                    color = BzMuted
                )
            }
        }

        // CTA button
        item {
            Button(
                onClick = { showNew = true },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 20.dp)
                    .height(84.dp)
                    .shadow(12.dp, RoundedCornerShape(22.dp)),
                shape = RoundedCornerShape(22.dp),
                colors = ButtonDefaults.buttonColors(containerColor = BzFg),
                contentPadding = PaddingValues(20.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(RoundedCornerShape(14.dp))
                            .background(BzAccent),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Filled.Add, contentDescription = null, tint = Color.White, modifier = Modifier.size(22.dp))
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(L.newViewingCTA(market), fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
                        Text(L.newViewingCTASub(market), fontSize = 13.sp, color = Color.White.copy(alpha = 0.72f))
                    }
                    Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = Color.White.copy(alpha = 0.6f))
                }
            }
        }

        // Section header
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .padding(top = 8.dp, bottom = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Bottom
            ) {
                Text(
                    text = L.pastViewings(market).uppercase(),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    letterSpacing = 0.5.sp,
                    color = BzMuted
                )
                Text(
                    text = "${viewings.size}",
                    fontSize = 14.sp,
                    color = BzMuted
                )
            }
        }

        // Empty state
        if (viewings.isEmpty()) {
            item {
                Text(
                    text = L.noPastViewings(market),
                    fontSize = 15.sp,
                    color = BzMuted,
                    textAlign = TextAlign.Center,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(28.dp)
                )
            }
        } else {
            // Viewing list
            item {
                BZCard(modifier = Modifier.padding(horizontal = 20.dp)) {
                    viewings.forEachIndexed { idx, v ->
                        ViewingRow(
                            viewing = v,
                            market = market,
                            onClick = { navController.navigate("rooms/${v.id}") },
                            onLongClick = { contextViewing = v }
                        )
                        if (idx < viewings.size - 1) {
                            BZDivider(Modifier.padding(start = 68.dp))
                        }
                    }
                }
            }
        }
    }

    // New viewing bottom sheet
    if (showNew) {
        NewViewingSheet(
            onDismiss = { showNew = false },
            onCreated = { id ->
                showNew = false
                navController.navigate("rooms/$id")
            }
        )
    }

    // Settings bottom sheet
    if (showSettings) {
        SettingsSheet(onDismiss = { showSettings = false })
    }

    // Context menu (long press)
    contextViewing?.let { v ->
        AlertDialog(
            onDismissRequest = { contextViewing = null },
            title = { Text(v.name) },
            text = null,
            confirmButton = {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    TextButton(onClick = {
                        exportViewing = v
                        contextViewing = null
                    }) {
                        Text(L.exportAction(market))
                    }
                    TextButton(onClick = {
                        pendingDelete = v
                        contextViewing = null
                    }) {
                        Text(L.deleteAction(v.name, market), color = MaterialTheme.colorScheme.error)
                    }
                    TextButton(onClick = { contextViewing = null }) {
                        Text(L.cancel(market))
                    }
                }
            },
            dismissButton = null
        )
    }

    // Delete confirm
    pendingDelete?.let { v ->
        AlertDialog(
            onDismissRequest = { pendingDelete = null },
            title = { Text(L.deleteConfirmTitle(market)) },
            text = { Text(L.deleteConfirmMsg(market)) },
            confirmButton = {
                TextButton(onClick = {
                    store.delete(v.id)
                    pendingDelete = null
                }) {
                    Text(L.deleteAction(v.name, market), color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { pendingDelete = null }) {
                    Text(L.cancel(market))
                }
            }
        )
    }

    // Navigate to export
    exportViewing?.let { v ->
        LaunchedEffect(v.id) {
            navController.navigate("export/${v.id}")
            exportViewing = null
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ViewingRow(
    viewing: Viewing,
    market: Market,
    onClick: () -> Unit,
    onLongClick: () -> Unit
) {
    val fmt = remember { SimpleDateFormat("d MMM yyyy", Locale.getDefault()) }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .combinedClickable(onClick = onClick, onLongClick = onLongClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        TypeBadge(viewing.type)
        Column(modifier = Modifier.weight(1f)) {
            Text(viewing.name, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
            Text(
                viewing.type.label(market),
                fontSize = 13.sp,
                color = BzMuted
            )
        }
        ScorePill(viewing)
        BZChevron()
    }
}
