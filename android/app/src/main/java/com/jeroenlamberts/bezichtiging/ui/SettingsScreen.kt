package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.L
import com.jeroenlamberts.bezichtiging.models.Market

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(navController: NavController) {
    val store = LocalStore.current
    val market by store.market.collectAsState()
    var showPrivacy by remember { mutableStateOf(false) }
    var showAbout by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(L.settingsTitle(market), fontWeight = FontWeight.SemiBold) },
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
        LazyColumn(modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 20.dp)) {
            item { Spacer(Modifier.height(8.dp)) }

            item {
                BZCard {
                    SettingsRow(label = L.privacyStatementTitle(market)) { showPrivacy = true }
                    BZDivider(Modifier.padding(start = 16.dp))
                    SettingsRow(label = L.aboutTitle(market)) { showAbout = true }
                }
            }
        }
    }

    if (showPrivacy) {
        InfoListSheet(
            title = L.privacyStatementTitle(market),
            items = L.privacyItems(market),
            onDismiss = { showPrivacy = false }
        )
    }

    if (showAbout) {
        InfoListSheet(
            title = L.aboutTitle(market),
            items = L.aboutItems(market),
            onDismiss = { showAbout = false }
        )
    }
}

@Composable
private fun SettingsRow(label: String, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 16.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label, fontSize = 16.sp, color = BzFg)
        Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = BzMuted)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun InfoListSheet(title: String, items: List<Pair<String, String>>, onDismiss: () -> Unit) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState, containerColor = BzBg) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(title, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = BzFg)
            items.forEach { (heading, body) ->
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(heading, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
                    Text(body, fontSize = 14.sp, color = BzMuted)
                }
                BZDivider()
            }
        }
    }
}

// Standalone settings sheet used from HomeScreen
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsSheet(onDismiss: () -> Unit) {
    val store = LocalStore.current
    val market by store.market.collectAsState()
    var showPrivacy by remember { mutableStateOf(false) }
    var showAbout by remember { mutableStateOf(false) }

    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState, containerColor = BzBg) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .padding(bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            Text(L.settingsTitle(market), fontSize = 22.sp, fontWeight = FontWeight.Bold, color = BzFg, modifier = Modifier.padding(bottom = 16.dp))
            BZCard {
                SettingsRow(label = L.privacyStatementTitle(market)) { showPrivacy = true }
                BZDivider(Modifier.padding(start = 16.dp))
                SettingsRow(label = L.aboutTitle(market)) { showAbout = true }
            }
        }
    }

    if (showPrivacy) {
        InfoListSheet(title = L.privacyStatementTitle(market), items = L.privacyItems(market), onDismiss = { showPrivacy = false })
    }
    if (showAbout) {
        InfoListSheet(title = L.aboutTitle(market), items = L.aboutItems(market), onDismiss = { showAbout = false })
    }
}
