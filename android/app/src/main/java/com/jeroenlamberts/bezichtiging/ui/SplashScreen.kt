package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.animation.*
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.L
import com.jeroenlamberts.bezichtiging.models.Market

@Composable
fun SplashScreen(market: Market) {
    var appeared by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { appeared = true }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(BzBg),
        contentAlignment = Alignment.Center
    ) {
        AnimatedVisibility(
            visible = appeared,
            enter = scaleIn(animationSpec = spring(dampingRatio = 0.75f, stiffness = 300f)) + fadeIn()
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(18.dp)) {
                Box(
                    modifier = Modifier
                        .size(96.dp)
                        .clip(CircleShape)
                        .background(BzAccent.copy(alpha = 0.10f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Filled.Home, contentDescription = null, tint = BzAccent, modifier = Modifier.size(44.dp))
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(L.appName(market), fontSize = 26.sp, fontWeight = FontWeight.SemiBold, color = BzFg)
                    Text(L.splashSubtitle(market), fontSize = 14.sp, color = BzMuted)
                }
            }
        }
    }
}
