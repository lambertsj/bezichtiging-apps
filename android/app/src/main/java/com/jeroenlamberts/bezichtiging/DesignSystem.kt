package com.jeroenlamberts.bezichtiging

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.jeroenlamberts.bezichtiging.models.Viewing
import com.jeroenlamberts.bezichtiging.models.ViewingType

// MARK: – Colours (matching iOS palette)
val BzBg      = Color(0xFFF4F1EC)
val BzSurface = Color.White
val BzFg      = Color(0xFF1C1917)
val BzMuted   = Color(0xFF78716C)
val BzLine    = Color(0x0F1C1917)
val BzAccent     = Color(0xFFC2410C)
val BzAccentSoft = Color(0xFFFED7AA)
val BzGood       = Color(0xFF16A34A)
val BzGoodSoft   = Color(0xFFDCFCE7)
val BzGoodInk    = Color(0xFF15803D)
val BzBad        = Color(0xFFDC2626)
val BzBadSoft    = Color(0xFFFEE2E2)
val BzBadInk     = Color(0xFFB91C1C)

// MARK: – Card
@Composable
fun BZCard(modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = modifier
            .shadow(elevation = 2.dp, shape = RoundedCornerShape(20.dp), ambientColor = Color.Black.copy(alpha = 0.04f))
            .clip(RoundedCornerShape(20.dp))
            .background(BzSurface),
        content = content
    )
}

// MARK: – Category header
@Composable
fun CatHeader(label: String) {
    Text(
        text = label.uppercase(),
        fontSize = 12.sp,
        fontWeight = FontWeight.SemiBold,
        letterSpacing = 0.8.sp,
        color = BzMuted,
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 4.dp)
    )
}

// MARK: – Row divider
@Composable
fun BZDivider(modifier: Modifier = Modifier) {
    HorizontalDivider(modifier = modifier, color = BzLine, thickness = 0.5.dp)
}

// MARK: – Score pill
@Composable
fun ScorePill(viewing: Viewing) {
    val score = viewing.score()
    if (score.total == 0) {
        Text("—", style = MaterialTheme.typography.bodyMedium, color = BzMuted)
    } else {
        Row(
            modifier = Modifier
                .clip(CircleShape)
                .background(BzBg)
                .padding(horizontal = 10.dp, vertical = 5.dp),
            horizontalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = "${score.goed}",
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                color = BzGoodInk
            )
            Text(
                text = "/${score.total}",
                fontSize = 14.sp,
                color = BzMuted
            )
        }
    }
}

// MARK: – Type badge
@Composable
fun TypeBadge(type: ViewingType) {
    val icon = if (type == ViewingType.WONING) Icons.Filled.Home else Icons.Filled.Apartment
    Box(
        modifier = Modifier
            .size(38.dp)
            .clip(RoundedCornerShape(11.dp))
            .background(BzAccentSoft),
        contentAlignment = Alignment.Center
    ) {
        Icon(icon, contentDescription = null, tint = BzAccent, modifier = Modifier.size(20.dp))
    }
}

// MARK: – Note badge
@Composable
fun NoteBadge() {
    Box(
        modifier = Modifier
            .size(22.dp)
            .clip(RoundedCornerShape(7.dp))
            .background(BzAccentSoft),
        contentAlignment = Alignment.Center
    ) {
        Icon(Icons.Filled.Note, contentDescription = null, tint = BzAccent, modifier = Modifier.size(12.dp))
    }
}

// MARK: – Room marker
@Composable
fun RoomMarker(answered: Int, total: Int, firstLetter: String) {
    val state = when {
        answered == 0 -> 0    // idle
        answered == total -> 2 // done
        else -> 1              // partial
    }
    val bg = when (state) {
        2 -> BzGoodSoft
        1 -> BzAccentSoft
        else -> BzBg
    }
    Box(
        modifier = Modifier
            .size(36.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(bg),
        contentAlignment = Alignment.Center
    ) {
        if (state == 2) {
            Icon(Icons.Filled.Check, contentDescription = null, tint = BzGoodInk, modifier = Modifier.size(14.dp))
        } else {
            Text(
                text = firstLetter,
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
                color = if (state == 1) BzAccent else BzFg
            )
        }
    }
}

// MARK: – Chevron
@Composable
fun BZChevron() {
    Icon(
        imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
        contentDescription = null,
        tint = BzMuted,
        modifier = Modifier.size(20.dp)
    )
}

// MARK: – Icon helper (maps iOS SF Symbol names to Material Icons)
fun iconForId(id: String): ImageVector = when (id) {
    "Park", "tree"                     -> Icons.Filled.Park
    "SentimentSatisfied", "face.smiling" -> Icons.Filled.SentimentSatisfied
    "Construction", "hammer"           -> Icons.Filled.Construction
    "Brush", "paintbrush"              -> Icons.Filled.Brush
    "Power", "powerplug"               -> Icons.Filled.Power
    "AcUnit", "snowflake"              -> Icons.Filled.AcUnit
    "Euro", "eurosign.circle"          -> Icons.Filled.Euro
    "Build", "wrench.and.screwdriver"  -> Icons.Filled.Build
    "Description", "doc.text"         -> Icons.Filled.Description
    "List", "list.bullet"              -> Icons.Filled.List
    "Home", "house", "house.fill"      -> Icons.Filled.Home
    "Apartment", "building.2"          -> Icons.Filled.Apartment
    "Settings", "gearshape"            -> Icons.Filled.Settings
    "Share", "square.and.arrow.up"     -> Icons.Filled.Share
    "Info", "info.circle"              -> Icons.Filled.Info
    "Delete", "trash"                  -> Icons.Filled.Delete
    "Add", "plus"                      -> Icons.Filled.Add
    "Check", "checkmark"               -> Icons.Filled.Check
    "Camera", "camera.fill"            -> Icons.Filled.CameraAlt
    "Star", "star"                     -> Icons.Filled.Star
    "VpnKey", "key"                    -> Icons.Filled.VpnKey
    "Sell", "tag"                      -> Icons.Filled.Sell
    else                               -> Icons.Filled.Home
}
