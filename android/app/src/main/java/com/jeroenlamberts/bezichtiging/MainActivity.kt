package com.jeroenlamberts.bezichtiging

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.jeroenlamberts.bezichtiging.data.ViewingStore

class MainActivity : ComponentActivity() {

    lateinit var viewingStore: ViewingStore

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewingStore = ViewingStore(applicationContext)
        enableEdgeToEdge()
        setContent {
            BezichtigingTheme {
                BezichtigingApp(store = viewingStore)
            }
        }
    }
}

@Composable
fun BezichtigingTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            background = BzBg,
            surface = BzSurface,
            primary = BzFg,
            secondary = BzAccent,
            onBackground = BzFg,
            onSurface = BzFg,
            onPrimary = Color.White
        ),
        content = content
    )
}
