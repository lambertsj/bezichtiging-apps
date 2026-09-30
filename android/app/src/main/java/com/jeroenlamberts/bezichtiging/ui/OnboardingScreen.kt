package com.jeroenlamberts.bezichtiging.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Home
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
import com.jeroenlamberts.bezichtiging.*
import com.jeroenlamberts.bezichtiging.models.L
import com.jeroenlamberts.bezichtiging.models.Market

@Composable
fun OnboardingScreen() {
    val store = LocalStore.current
    val isDutch = Market.isDeviceLanguageDutch
    var selected by remember { mutableStateOf(Market.onboardingDefault()) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(BzBg)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.weight(1f))

            // Icon
            Box(
                modifier = Modifier
                    .size(88.dp)
                    .clip(CircleShape)
                    .background(BzAccent.copy(alpha = 0.10f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Filled.Home, contentDescription = null, tint = BzAccent, modifier = Modifier.size(40.dp))
            }

            Spacer(Modifier.height(28.dp))

            Text(
                text = L.onboardingTitle(isDutch),
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = BzFg,
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(8.dp))

            Text(
                text = L.onboardingSubtitle(isDutch),
                fontSize = 15.sp,
                color = BzMuted,
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(36.dp))

            Column(verticalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
                Market.onboardingMarkets.forEach { market ->
                    MarketOption(market = market, isSelected = selected == market) {
                        selected = market
                    }
                }
            }

            Spacer(Modifier.weight(1f))

            Button(
                onClick = { store.completeOnboarding(selected) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = BzFg)
            ) {
                Text(L.onboardingCTA(isDutch), fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = Color.White)
            }

            Spacer(Modifier.height(40.dp))
        }
    }
}

@Composable
private fun MarketOption(market: Market, isSelected: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(if (isSelected) 3.dp else 1.dp, RoundedCornerShape(16.dp))
            .clip(RoundedCornerShape(16.dp))
            .background(BzSurface)
            .border(
                width = if (isSelected) 2.dp else 0.dp,
                color = if (isSelected) BzAccent else Color.Transparent,
                shape = RoundedCornerShape(16.dp)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 18.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Text(market.flag, fontSize = 28.sp)
        Text(
            text = market.label,
            fontSize = 17.sp,
            fontWeight = FontWeight.SemiBold,
            color = BzFg,
            modifier = Modifier.weight(1f)
        )
        if (isSelected) {
            Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = BzAccent, modifier = Modifier.size(22.dp))
        } else {
            Box(
                modifier = Modifier
                    .size(22.dp)
                    .border(1.5.dp, BzMuted.copy(alpha = 0.3f), CircleShape)
            )
        }
    }
}
