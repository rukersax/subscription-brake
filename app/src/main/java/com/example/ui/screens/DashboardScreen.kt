package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarDuration
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.ui.components.BurnRateHeroCard
import com.example.ui.components.PriceHikeAlertCard
import com.example.ui.components.SubscriptionCard
import com.example.ui.components.TrialGuardianAlertCard
import com.example.ui.theme.EmeraldAccent
import com.example.ui.theme.NavyDark
import com.example.ui.viewmodel.SubscriptionViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    viewModel: SubscriptionViewModel,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    val categories = listOf(
        "Tümü",
        "Streaming Video",
        "Music & Audio",
        "AI & Productivity",
        "Cloud Storage",
        "Gaming",
        "Sports & TV",
        "Education"
    )

    // Handle Undo Delete Snackbar
    LaunchedEffect(uiState.recentlyDeletedSub) {
        uiState.recentlyDeletedSub?.let { deleted ->
            val result = snackbarHostState.showSnackbar(
                message = "${deleted.serviceName} silindi",
                actionLabel = "GERİ AL",
                duration = SnackbarDuration.Short
            )
            if (result == SnackbarResult.ActionPerformed) {
                viewModel.undoDelete()
            }
        }
    }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(38.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(NavyDark),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Shield,
                                contentDescription = null,
                                tint = EmeraldAccent,
                                modifier = Modifier.size(22.dp)
                            )
                        }

                        Spacer(modifier = Modifier.width(10.dp))

                        Column {
                            Text(
                                text = "Subscription Brake",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.ExtraBold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            )
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Default.Lock,
                                    contentDescription = null,
                                    tint = EmeraldAccent,
                                    modifier = Modifier.size(10.dp)
                                )
                                Spacer(modifier = Modifier.width(3.dp))
                                Text(
                                    text = "Privacy-First • Financial Guard Dog",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        fontSize = 10.sp
                                    )
                                )
                            }
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                ),
                actions = {
                    IconButton(
                        onClick = { viewModel.openBackupDialog() },
                        modifier = Modifier.testTag("open_backup_dialog_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Security,
                            contentDescription = "Gizlilik ve Yedekleme",
                            tint = NavyDark
                        )
                    }

                    Surface(
                        color = EmeraldAccent.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.padding(end = 12.dp)
                    ) {
                        Text(
                            text = "${uiState.activeSubscriptionCount} Aktif",
                            color = Color(0xFF047857),
                            fontWeight = FontWeight.Bold,
                            fontSize = 12.sp,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                        )
                    }
                }
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = { viewModel.openAddDialog() },
                containerColor = NavyDark,
                contentColor = Color.White,
                shape = RoundedCornerShape(16.dp),
                modifier = Modifier.testTag("add_subscription_fab"),
                icon = {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "Abonelik Ekle",
                        tint = EmeraldAccent
                    )
                },
                text = {
                    Text(
                        text = "Abonelik Ekle",
                        fontWeight = FontWeight.Bold
                    )
                }
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) },
        containerColor = MaterialTheme.colorScheme.background
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Hero Burn Rate Card
            item {
                BurnRateHeroCard(
                    monthlyBurnRate = uiState.monthlyBurnRate,
                    annualBurnRate = uiState.annualBurnRate,
                    activeCount = uiState.activeSubscriptionCount,
                    selectedCurrency = uiState.selectedCurrency,
                    onCurrencySelect = { viewModel.setCurrency(it) }
                )
            }

            // Trial Expiry Guardian Alerts (24-48h warning)
            if (uiState.trialExpiringCount > 0) {
                item {
                    TrialGuardianAlertCard(expiringList = uiState.trialExpiringList)
                }
            }

            // Silent Price Hike Alerts
            if (uiState.priceHikeCount > 0) {
                item {
                    PriceHikeAlertCard(hikeList = uiState.priceHikeList)
                }
            }

            // Category Filter Chips
            item {
                Column {
                    Text(
                        text = "Kategoriler",
                        style = MaterialTheme.typography.titleSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        categories.forEach { cat ->
                            val isSelected = uiState.selectedCategory == cat
                            FilterChip(
                                selected = isSelected,
                                onClick = { viewModel.setCategory(cat) },
                                label = {
                                    Text(
                                        text = cat,
                                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                                    )
                                },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = NavyDark,
                                    selectedLabelColor = Color.White,
                                    containerColor = MaterialTheme.colorScheme.surface,
                                    labelColor = MaterialTheme.colorScheme.onSurface
                                ),
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.testTag("category_chip_$cat")
                            )
                        }
                    }
                }
            }

            // Section Header
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Aboneliklerim (${uiState.filteredSubscriptions.size})",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    )

                    Text(
                        text = "Detay için dokunun",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            fontSize = 11.sp
                        )
                    )
                }
            }

            // Subscriptions List
            if (uiState.filteredSubscriptions.isEmpty()) {
                item {
                    Surface(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 24.dp),
                        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(24.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(
                                text = "Abonelik Bulunamadı",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold
                                )
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Seçili filtrede abonelik yok veya henüz abonelik eklemediniz.",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            )
                        }
                    }
                }
            } else {
                items(
                    items = uiState.filteredSubscriptions,
                    key = { it.id }
                ) { subscription ->
                    SubscriptionCard(
                        subscription = subscription,
                        onClick = { viewModel.selectSubscription(subscription) }
                    )
                }
            }

            item {
                Spacer(modifier = Modifier.height(60.dp)) // Padding for FAB
            }
        }
    }

    // Add Subscription Dialog
    if (uiState.showAddDialog) {
        AddEditSubscriptionDialog(
            selectedCurrency = uiState.selectedCurrency,
            onDismiss = { viewModel.closeAddDialog() },
            onAddFromCatalogPlan = { catalogItem, plan, currency, dateMs, cardHint ->
                viewModel.addFromCatalogPlan(catalogItem, plan, currency, dateMs, cardHint)
            },
            onAddCustom = { entity ->
                viewModel.addSubscription(entity)
            }
        )
    }

    // Detail Bottom Sheet
    if (uiState.showDetailSheet && uiState.selectedSubscription != null) {
        SubscriptionDetailSheet(
            subscription = uiState.selectedSubscription!!,
            onDismiss = { viewModel.closeDetailSheet() },
            onDelete = { sub -> viewModel.deleteSubscription(sub) },
            onViewAlternatives = { sub -> viewModel.openAlternatives(sub) }
        )
    }

    // Alternatives Dialog
    if (uiState.showAlternativesDialog) {
        AlternativesDialog(
            alternatives = uiState.alternativesList,
            onDismiss = { viewModel.closeAlternativesDialog() }
        )
    }

    // Backup & Privacy Dialog (AES-256 Export/Restore + Notification Test)
    if (uiState.showBackupDialog) {
        BackupRestoreDialog(
            subscriptions = uiState.subscriptions,
            onDismiss = { viewModel.closeBackupDialog() },
            onRestoreSubscriptions = { restoredList ->
                viewModel.restoreSubscriptions(restoredList)
            }
        )
    }
}
