package com.jeroenlamberts.bezichtiging.ui

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.core.content.FileProvider
import androidx.navigation.NavController
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.*
import com.jeroenlamberts.bezichtiging.util.PdfGenerator
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExportScreen(viewingId: String, navController: NavController) {
    val store = LocalStore.current
    val viewings by store.viewings.collectAsState()
    val viewing = viewings.firstOrNull { it.id == viewingId } ?: return
    val market = viewing.marketEnum()
    val context = LocalContext.current
    val isDutch = Market.isDeviceLanguageDutch

    var pdfFile by remember { mutableStateOf<File?>(null) }
    var isGenerating by remember { mutableStateOf(true) }

    LaunchedEffect(viewingId) {
        withContext(Dispatchers.IO) {
            val file = File(context.cacheDir, "${viewing.name.replace(" ", "_")}_rapport.pdf")
            PdfGenerator.generate(viewing, file)
            pdfFile = file
        }
        isGenerating = false
    }

    val score = viewing.score()
    val allThemes = ChecklistData.themes(viewing.type, market)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (isDutch) "Rapport" else "Report", fontWeight = FontWeight.SemiBold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    if (!isGenerating) {
                        IconButton(onClick = {
                            pdfFile?.let { file ->
                                val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
                                val intent = Intent(Intent.ACTION_SEND).apply {
                                    type = "application/pdf"
                                    putExtra(Intent.EXTRA_STREAM, uri)
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                                context.startActivity(Intent.createChooser(intent, if (isDutch) "Opslaan als PDF" else "Save as PDF"))
                            }
                        }) {
                            Icon(Icons.Filled.Share, contentDescription = "Share PDF")
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = BzBg)
            )
        },
        containerColor = BzBg
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(horizontal = 20.dp, vertical = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Header card
            item {
                BZCard {
                    Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(viewing.name, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = BzFg)
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Chip(viewing.type.label(market))
                            Chip(viewing.tenure.longLabel(market))
                        }
                        if (score.total > 0) {
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(20.dp))
                                        .background(BzGoodSoft)
                                        .padding(horizontal = 12.dp, vertical = 6.dp),
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(Icons.Filled.Check, contentDescription = null, tint = BzGoodInk, modifier = Modifier.size(14.dp))
                                    Text("${score.goed}", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = BzGoodInk)
                                    Text(if (isDutch) "in orde" else "good", fontSize = 13.sp, color = BzGoodInk)
                                }
                                val bad = score.total - score.goed
                                if (bad > 0) {
                                    Row(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(20.dp))
                                            .background(BzBadSoft)
                                            .padding(horizontal = 12.dp, vertical = 6.dp),
                                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                                    ) {
                                        Icon(Icons.Filled.PriorityHigh, contentDescription = null, tint = BzBadInk, modifier = Modifier.size(14.dp))
                                        Text("$bad", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = BzBadInk)
                                        Text(if (isDutch) "aandacht" else "attention", fontSize = 13.sp, color = BzBadInk)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Generating indicator
            if (isGenerating) {
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        CircularProgressIndicator(modifier = Modifier.size(20.dp), color = BzAccent, strokeWidth = 2.dp)
                        Text(if (isDutch) "PDF genereren…" else "Generating PDF…", fontSize = 14.sp, color = BzMuted)
                    }
                }
            } else {
                item {
                    Button(
                        onClick = {
                            pdfFile?.let { file ->
                                val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
                                val intent = Intent(Intent.ACTION_SEND).apply {
                                    type = "application/pdf"
                                    putExtra(Intent.EXTRA_STREAM, uri)
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                                context.startActivity(Intent.createChooser(intent, if (isDutch) "Opslaan als PDF" else "Save as PDF"))
                            }
                        },
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape = RoundedCornerShape(50),
                        colors = ButtonDefaults.buttonColors(containerColor = BzFg)
                    ) {
                        Icon(Icons.Filled.Share, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(8.dp))
                        Text(if (isDutch) "Opslaan als PDF" else "Save as PDF", fontWeight = FontWeight.SemiBold, color = Color.White)
                    }
                }
            }

            // Theme summaries with notes
            allThemes.forEach { theme ->
                val flat = ChecklistData.flatItems(theme.id, viewing.type, viewing.tenure, market)
                val answered = flat.filter { viewing.answers.containsKey(it.key) }
                if (answered.isEmpty()) return@forEach

                item {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        CatHeader(theme.label)
                        BZCard {
                            answered.forEachIndexed { idx, fi ->
                                val rating = viewing.rating(fi.key) ?: return@forEachIndexed
                                val note = viewing.itemNotes[fi.key]
                                Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)) {
                                    Row(
                                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        RatingBadge(rating, isDutch)
                                        Text(fi.item.label, fontSize = 14.sp, color = BzFg, modifier = Modifier.weight(1f))
                                    }
                                    if (!note.isNullOrBlank()) {
                                        Text("  $note", fontSize = 12.sp, color = BzMuted, modifier = Modifier.padding(top = 4.dp, start = 4.dp))
                                    }
                                }
                                if (idx < answered.size - 1) BZDivider(Modifier.padding(start = 16.dp))
                            }
                        }

                        // Section note
                        val sectionNote = viewing.notes[theme.id]
                        if (!sectionNote.isNullOrBlank()) {
                            BZCard {
                                Column(modifier = Modifier.padding(16.dp)) {
                                    Text(if (isDutch) "Opmerking" else "Note", fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = BzMuted)
                                    Text(sectionNote, fontSize = 14.sp, color = BzFg, modifier = Modifier.padding(top = 4.dp))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun RatingBadge(rating: Rating, isDutch: Boolean) {
    val bg = when (rating) { Rating.GOED -> BzGoodSoft; Rating.NIET -> BzBadSoft; else -> BzBg }
    val fg = when (rating) { Rating.GOED -> BzGoodInk; Rating.NIET -> BzBadInk; else -> BzMuted }
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(6.dp))
            .background(bg)
            .padding(horizontal = 8.dp, vertical = 3.dp)
    ) {
        Text(rating.reportBadge(isDutch), fontSize = 11.sp, fontWeight = FontWeight.Bold, color = fg)
    }
}

@Composable
private fun Chip(label: String) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(BzBg)
            .padding(horizontal = 10.dp, vertical = 4.dp)
    ) {
        Text(label, fontSize = 12.sp, color = BzMuted)
    }
}
