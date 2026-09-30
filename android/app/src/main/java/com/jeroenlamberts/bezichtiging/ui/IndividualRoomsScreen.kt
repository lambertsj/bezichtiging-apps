package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun IndividualRoomsScreen(viewingId: String, navController: NavController) {
    val store = LocalStore.current
    val viewings by store.viewings.collectAsState()
    val viewing = viewings.firstOrNull { it.id == viewingId } ?: return
    val market = viewing.marketEnum()
    val rooms = ChecklistData.rooms(viewing.type, market)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(L.indivRoomsTitle(market), fontWeight = FontWeight.SemiBold) },
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
            contentPadding = PaddingValues(bottom = 32.dp)
        ) {
            item {
                Column(
                    modifier = Modifier.padding(horizontal = 20.dp).padding(top = 8.dp, bottom = 20.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(L.indivRoomsTitle(market), fontSize = 32.sp, fontWeight = FontWeight.Bold, color = BzFg)
                    Text(L.indivRoomsSub(market), fontSize = 15.sp, color = BzMuted)
                }
            }

            item {
                BZCard(modifier = Modifier.padding(horizontal = 20.dp)) {
                    rooms.forEachIndexed { idx, room ->
                        EntryRow(
                            entryId = room.id,
                            label = room.label,
                            sub = room.sub,
                            viewing = viewing,
                            market = market,
                            icon = null,
                            onClick = { navController.navigate("checklist/$viewingId/${room.id}/true") }
                        )
                        if (idx < rooms.size - 1) BZDivider(Modifier.padding(start = 56.dp))
                    }
                }
            }
        }
    }
}
