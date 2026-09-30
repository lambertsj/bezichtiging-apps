package com.jeroenlamberts.bezichtiging

import androidx.compose.animation.*
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.jeroenlamberts.bezichtiging.data.ViewingStore
import com.jeroenlamberts.bezichtiging.ui.*
import kotlinx.coroutines.delay

val LocalStore = compositionLocalOf<ViewingStore> { error("ViewingStore not provided") }

@Composable
fun BezichtigingApp(store: ViewingStore) {
    CompositionLocalProvider(LocalStore provides store) {
        val hasOnboarded by store.hasCompletedOnboarding.collectAsState()
        var showSplash by remember { mutableStateOf(true) }
        val navController = rememberNavController()

        LaunchedEffect(hasOnboarded) {
            if (hasOnboarded) {
                delay(1400)
                showSplash = false
            } else {
                showSplash = false
            }
        }

        Box(Modifier.fillMaxSize()) {
            NavHost(navController = navController, startDestination = "home") {
                composable("home") {
                    HomeScreen(navController = navController)
                }
                composable("rooms/{viewingId}") { back ->
                    val id = back.arguments?.getString("viewingId") ?: return@composable
                    RoomsScreen(viewingId = id, navController = navController)
                }
                composable("checklist/{viewingId}/{entryId}/{isRoom}") { back ->
                    val viewingId = back.arguments?.getString("viewingId") ?: return@composable
                    val entryId = back.arguments?.getString("entryId") ?: return@composable
                    val isRoom = back.arguments?.getString("isRoom") == "true"
                    ChecklistScreen(viewingId = viewingId, entryId = entryId, isRoom = isRoom, navController = navController)
                }
                composable("individualRooms/{viewingId}") { back ->
                    val id = back.arguments?.getString("viewingId") ?: return@composable
                    IndividualRoomsScreen(viewingId = id, navController = navController)
                }
                composable("export/{viewingId}") { back ->
                    val id = back.arguments?.getString("viewingId") ?: return@composable
                    ExportScreen(viewingId = id, navController = navController)
                }
                composable("settings") {
                    SettingsScreen(navController = navController)
                }
            }

            // Onboarding overlay
            AnimatedVisibility(
                visible = !hasOnboarded,
                enter = fadeIn(),
                exit = fadeOut()
            ) {
                OnboardingScreen()
            }

            // Splash overlay
            AnimatedVisibility(
                visible = showSplash && hasOnboarded,
                enter = fadeIn(),
                exit = fadeOut()
            ) {
                val market by store.market.collectAsState()
                SplashScreen(market = market)
            }
        }
    }
}
