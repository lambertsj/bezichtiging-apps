package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewViewingSheet(onDismiss: () -> Unit, onCreated: (String) -> Unit) {
    val store = LocalStore.current
    val market by store.market.collectAsState()
    var name by remember { mutableStateOf("") }
    var type by remember { mutableStateOf(ViewingType.WONING) }
    var tenure by remember { mutableStateOf(Tenure.KOOP) }
    val focusRequester = remember { FocusRequester() }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    LaunchedEffect(Unit) { focusRequester.requestFocus() }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = BzBg
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            Text(L.newViewingSheetTitle(market), fontSize = 26.sp, fontWeight = FontWeight.Bold, color = BzFg)
            Spacer(Modifier.height(4.dp))
            Text(L.newViewingSheetDesc(market), fontSize = 15.sp, color = BzMuted)
            Spacer(Modifier.height(24.dp))

            // Type section
            SectionLabel("Type")
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                ViewingType.entries.forEach { t ->
                    TypeCard(
                        icon = iconForId(t.systemIcon),
                        title = t.label(market),
                        sub = t.sub(market),
                        selected = type == t,
                        modifier = Modifier.weight(1f)
                    ) { type = t }
                }
            }
            Spacer(Modifier.height(18.dp))

            // Tenure section
            SectionLabel(L.sectionTenure(market))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Tenure.entries.forEach { t ->
                    val selected = tenure == t
                    FilterChip(
                        selected = selected,
                        onClick = { tenure = t },
                        label = { Text(t.label(market)) },
                        modifier = Modifier.weight(1f),
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = BzFg,
                            selectedLabelColor = Color.White
                        )
                    )
                }
            }
            Spacer(Modifier.height(18.dp))

            // Name section
            SectionLabel(L.sectionName(market))
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                placeholder = { Text(L.namePlaceholder(type, market), color = BzMuted) },
                modifier = Modifier
                    .fillMaxWidth()
                    .focusRequester(focusRequester),
                shape = RoundedCornerShape(14.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = BzFg,
                    unfocusedBorderColor = BzLine,
                    focusedContainerColor = BzSurface,
                    unfocusedContainerColor = BzSurface
                ),
                singleLine = true,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                keyboardActions = KeyboardActions(onDone = {
                    if (name.isNotBlank()) {
                        val id = store.create(name.trim(), type, tenure)
                        onCreated(id)
                    }
                })
            )
            Spacer(Modifier.height(24.dp))

            // Action buttons
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedButton(
                    onClick = onDismiss,
                    modifier = Modifier.weight(1f).height(52.dp),
                    shape = RoundedCornerShape(50),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = BzFg)
                ) {
                    Text(L.cancel(market), fontWeight = FontWeight.SemiBold)
                }
                Button(
                    onClick = {
                        if (name.isNotBlank()) {
                            val id = store.create(name.trim(), type, tenure)
                            onCreated(id)
                        }
                    },
                    enabled = name.isNotBlank(),
                    modifier = Modifier.weight(2f).height(52.dp),
                    shape = RoundedCornerShape(50),
                    colors = ButtonDefaults.buttonColors(containerColor = BzFg)
                ) {
                    Text(L.begin(market), fontWeight = FontWeight.SemiBold, color = Color.White)
                }
            }
        }
    }
}

@Composable
private fun SectionLabel(text: String) {
    Text(
        text = text,
        fontSize = 13.sp,
        fontWeight = FontWeight.SemiBold,
        color = BzMuted,
        letterSpacing = 0.3.sp,
        modifier = Modifier.padding(bottom = 8.dp)
    )
}

@Composable
private fun TypeCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    sub: String,
    selected: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(if (selected) BzAccentSoft else BzSurface)
            .border(
                width = 1.5.dp,
                color = if (selected) BzAccent else BzLine,
                shape = RoundedCornerShape(16.dp)
            )
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(RoundedCornerShape(11.dp))
                .background(if (selected) BzSurface else BzBg),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, contentDescription = null, tint = if (selected) BzAccent else BzFg, modifier = Modifier.size(24.dp))
        }
        Spacer(Modifier.height(4.dp))
        Text(title, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
        Text(sub, fontSize = 12.5.sp, color = if (selected) BzAccent.copy(alpha = 0.85f) else BzMuted)
    }
}
