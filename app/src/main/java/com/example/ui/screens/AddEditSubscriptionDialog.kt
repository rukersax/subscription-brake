package com.example.ui.screens

import android.app.DatePickerDialog
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.EditCalendar
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material.icons.filled.FlashOn
import androidx.compose.material.icons.filled.LibraryAdd
import androidx.compose.material.icons.filled.RadioButtonChecked
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.example.data.model.CatalogData
import com.example.data.model.CatalogItem
import com.example.data.model.CatalogPlan
import com.example.data.model.SubscriptionEntity
import com.example.ui.components.CategoryIconBadge
import com.example.ui.theme.EmeraldAccent
import com.example.ui.theme.NavyDark
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Format and validate DD/MM/YYYY (--/--/----) input.
 * Day: max 2 digits (01-31)
 * Month: max 2 digits (01-12)
 * Year: max 4 digits (>= currentYear)
 */
fun formatAndValidateDateInput(
    rawInput: String,
    currentYear: Int
): Triple<String, String?, Long?> {
    val digits = rawInput.filter { it.isDigit() }.take(8)
    val sb = StringBuilder()
    var dayPart = ""
    var monthPart = ""
    var yearPart = ""

    if (digits.length >= 2) {
        var dayVal = digits.substring(0, 2).toIntOrNull() ?: 1
        if (dayVal > 31) dayVal = 31
        if (dayVal < 1 && digits.substring(0, 2) == "00") dayVal = 1
        dayPart = String.format(Locale.getDefault(), "%02d", dayVal)
        sb.append(dayPart).append("/")
    } else if (digits.isNotEmpty()) {
        dayPart = digits
        sb.append(dayPart)
    }

    if (digits.length >= 4) {
        var monthVal = digits.substring(2, 4).toIntOrNull() ?: 1
        if (monthVal > 12) monthVal = 12
        if (monthVal < 1 && digits.substring(2, 4) == "00") monthVal = 1
        monthPart = String.format(Locale.getDefault(), "%02d", monthVal)
        sb.append(monthPart).append("/")
    } else if (digits.length > 2) {
        monthPart = digits.substring(2)
        sb.append(monthPart)
    }

    if (digits.length > 4) {
        yearPart = digits.substring(4)
        sb.append(yearPart)
    }

    val formattedText = sb.toString()
    var errorMsg: String? = null
    var parsedTimestamp: Long? = null

    if (digits.length == 8) {
        val yearVal = yearPart.toIntOrNull() ?: 0
        if (yearVal < currentYear) {
            errorMsg = "Yıl en az $currentYear (bulunulan yıl) veya ileri bir yıl olmalıdır."
        } else {
            try {
                val dayInt = dayPart.toInt()
                val monthInt = monthPart.toInt() - 1
                val cal = Calendar.getInstance().apply {
                    set(Calendar.YEAR, yearVal)
                    set(Calendar.MONTH, monthInt)
                    val maxDayInMonth = getActualMaximum(Calendar.DAY_OF_MONTH)
                    val safeDay = if (dayInt > maxDayInMonth) maxDayInMonth else dayInt
                    set(Calendar.DAY_OF_MONTH, safeDay)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                parsedTimestamp = cal.timeInMillis
            } catch (e: Exception) {
                errorMsg = "Geçersiz tarih"
            }
        }
    } else if (digits.isNotEmpty() && digits.length < 8) {
        errorMsg = "Tarihi GG/AA/YYYY (--/--/----) olarak tamamlayın"
    }

    return Triple(formattedText, errorMsg, parsedTimestamp)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditSubscriptionDialog(
    selectedCurrency: String,
    onDismiss: () -> Unit,
    onAddFromCatalogPlan: (CatalogItem, CatalogPlan, String, Long, String) -> Unit,
    onAddCustom: (SubscriptionEntity) -> Unit
) {
    var selectedTab by remember { mutableIntStateOf(0) } // 0 = Hızlı Seçim, 1 = Özel Abonelik
    var selectedCatalogItemForModal by remember { mutableStateOf<CatalogItem?>(null) }
    var activeCurrency by remember { mutableStateOf(selectedCurrency) }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.90f)
                .clip(RoundedCornerShape(24.dp))
                .testTag("add_subscription_dialog"),
            color = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(24.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "Abonelik Ekle",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        )
                        Text(
                            text = "Hızlı seçim ile paketi ve tarihi belirleyin",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        )
                    }

                    IconButton(
                        onClick = onDismiss,
                        modifier = Modifier.testTag("close_add_dialog_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Kapat"
                        )
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Dual-Mode Tabs: Hızlı Seçim & Özel Abonelik
                TabRow(
                    selectedTabIndex = selectedTab,
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f),
                    contentColor = NavyDark,
                    modifier = Modifier.clip(RoundedCornerShape(14.dp))
                ) {
                    Tab(
                        selected = selectedTab == 0,
                        onClick = { selectedTab = 0 },
                        modifier = Modifier.testTag("tab_fast_selection"),
                        text = {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.FlashOn,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp),
                                    tint = if (selectedTab == 0) EmeraldAccent else MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Hızlı Seçim",
                                    fontWeight = if (selectedTab == 0) FontWeight.Bold else FontWeight.Medium,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    )
                    Tab(
                        selected = selectedTab == 1,
                        onClick = { selectedTab = 1 },
                        modifier = Modifier.testTag("tab_custom_sub"),
                        text = {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.LibraryAdd,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp),
                                    tint = if (selectedTab == 1) NavyDark else MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Özel Abonelik",
                                    fontWeight = if (selectedTab == 1) FontWeight.Bold else FontWeight.Medium,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                if (selectedTab == 0) {
                    FastSelectionCatalogContent(
                        selectedCurrency = activeCurrency,
                        onCurrencyChange = { activeCurrency = it },
                        onSelectApp = { item ->
                            selectedCatalogItemForModal = item
                        }
                    )
                } else {
                    CustomSubscriptionTabContent(
                        initialCurrency = activeCurrency,
                        onSubmit = { entity ->
                            onAddCustom(entity)
                        }
                    )
                }
            }
        }
    }

    // 2-Step Fast Subscription Creation Modal (Adım 1: Paket Seçimi -> Adım 2: Yenilenme Tarihi)
    if (selectedCatalogItemForModal != null) {
        FastPlanAndDateModal(
            catalogItem = selectedCatalogItemForModal!!,
            currency = activeCurrency,
            onDismiss = { selectedCatalogItemForModal = null },
            onConfirm = { item, plan, nextDateMs, cardHint ->
                onAddFromCatalogPlan(item, plan, activeCurrency, nextDateMs, cardHint)
                selectedCatalogItemForModal = null
            }
        )
    }
}

/**
 * Hızlı Seçim Bölümü: Uygulama Listesi, Arama ve Kategori Filtresi
 */
@Composable
private fun FastSelectionCatalogContent(
    selectedCurrency: String,
    onCurrencyChange: (String) -> Unit,
    onSelectApp: (CatalogItem) -> Unit
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategoryFilter by remember { mutableStateOf("Tümü") }

    val categories = listOf(
        "Tümü",
        "Streaming Video",
        "Music & Audio",
        "Music & Video",
        "AI & Productivity",
        "Cloud Storage",
        "Gaming",
        "Sports & TV",
        "Education",
        "Audiobooks",
        "Shopping & Video"
    )

    val filteredList = remember(searchQuery, selectedCategoryFilter) {
        CatalogData.predefinedServices.filter { item ->
            val matchesSearch = searchQuery.isBlank() ||
                    item.name.contains(searchQuery, ignoreCase = true) ||
                    item.category.contains(searchQuery, ignoreCase = true)
            val matchesCategory = selectedCategoryFilter == "Tümü" ||
                    item.category.equals(selectedCategoryFilter, ignoreCase = true)
            matchesSearch && matchesCategory
        }
    }

    Column(modifier = Modifier.fillMaxSize()) {
        // Search and Currency bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Uygulama Seçin",
                style = MaterialTheme.typography.labelLarge.copy(
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
            )

            // Currency Switcher (TRY, USD, EUR)
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                listOf("TRY", "USD", "EUR").forEach { curr ->
                    Surface(
                        color = if (selectedCurrency == curr) EmeraldAccent else MaterialTheme.colorScheme.surfaceVariant,
                        shape = RoundedCornerShape(8.dp),
                        onClick = { onCurrencyChange(curr) },
                        modifier = Modifier.testTag("currency_switch_$curr")
                    ) {
                        Text(
                            text = curr,
                            color = if (selectedCurrency == curr) NavyDark else MaterialTheme.colorScheme.onSurface,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 7.dp, vertical = 3.dp)
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Search Input
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            placeholder = { Text("Uygulama ara (Netflix, Spotify, ChatGPT, Exxen...)") },
            leadingIcon = {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            },
            trailingIcon = {
                if (searchQuery.isNotEmpty()) {
                    IconButton(onClick = { searchQuery = "" }) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Temizle",
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .testTag("fast_catalog_search_input"),
            singleLine = true,
            shape = RoundedCornerShape(12.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedBorderColor = NavyDark
            )
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Category Horizontal Filter Pills
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            items(categories) { cat ->
                val isSelected = selectedCategoryFilter == cat
                FilterChip(
                    selected = isSelected,
                    onClick = { selectedCategoryFilter = cat },
                    label = {
                        Text(
                            text = when (cat) {
                                "Streaming Video" -> "Dizi & Film"
                                "Music & Audio" -> "Müzik"
                                "Music & Video" -> "Müzik/Video"
                                "AI & Productivity" -> "Yapay Zeka"
                                "Cloud Storage" -> "Bulut"
                                "Sports & TV" -> "Spor & Maç"
                                "Audiobooks" -> "Sesli Kitap"
                                "Shopping & Video" -> "Alışveriş & Prime"
                                else -> cat
                            },
                            fontSize = 11.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                        )
                    },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = NavyDark,
                        selectedLabelColor = Color.White,
                        containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                        labelColor = MaterialTheme.colorScheme.onSurface
                    ),
                    shape = RoundedCornerShape(10.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // App List
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(filteredList, key = { it.id }) { item ->
                val planCount = if (item.plans.isNotEmpty()) item.plans.size else 3
                val minPrice = when (selectedCurrency) {
                    "TRY" -> "₺${item.plans.minOfOrNull { it.priceTry } ?: item.priceTry}"
                    "USD" -> "$${item.plans.minOfOrNull { it.priceUsd } ?: item.priceUsd}"
                    "EUR" -> "€${item.plans.minOfOrNull { it.priceEur } ?: item.priceEur}"
                    else -> "₺${item.priceTry}"
                }

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .clickable { onSelectApp(item) }
                        .testTag("catalog_item_${item.id}"),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f)
                    ),
                    shape = RoundedCornerShape(14.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.weight(1f)
                        ) {
                            CategoryIconBadge(
                                category = item.category,
                                serviceName = item.name,
                                modifier = Modifier.size(42.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Column {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text(
                                        text = item.name,
                                        style = MaterialTheme.typography.titleMedium.copy(
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                    if (item.isPopular) {
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Surface(
                                            color = EmeraldAccent.copy(alpha = 0.2f),
                                            shape = RoundedCornerShape(6.dp)
                                        ) {
                                            Text(
                                                text = "POPÜLER",
                                                color = EmeraldAccent,
                                                fontSize = 9.sp,
                                                fontWeight = FontWeight.ExtraBold,
                                                modifier = Modifier.padding(horizontal = 5.dp, vertical = 1.dp)
                                            )
                                        }
                                    }
                                }
                                Spacer(modifier = Modifier.height(2.dp))
                                Text(
                                    text = "$planCount Farklı Paket Seçeneği • ${item.category}",
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        fontSize = 11.sp
                                    )
                                )
                            }
                        }

                        Column(horizontalAlignment = Alignment.End) {
                            Text(
                                text = minPrice,
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.ExtraBold,
                                    color = EmeraldAccent
                                )
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Surface(
                                color = NavyDark,
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                ) {
                                    Text(
                                        text = "Seç",
                                        color = Color.White,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Spacer(modifier = Modifier.width(2.dp))
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                                        contentDescription = null,
                                        tint = Color.White,
                                        modifier = Modifier.size(12.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * 2-Adımlı Hızlı Seçim Penceresi
 * Adım 1: Paket Seçimi (Temel, Standart, Özel vb. hazır fiyatlı seçenekler)
 * Adım 2: Yenilenme Tarihi (Takvim + GG/AA/YYYY Formatlı Elle Giriş)
 */
@Composable
fun FastPlanAndDateModal(
    catalogItem: CatalogItem,
    currency: String,
    onDismiss: () -> Unit,
    onConfirm: (CatalogItem, CatalogPlan, Long, String) -> Unit
) {
    val context = LocalContext.current
    val currentYear = remember { Calendar.getInstance().get(Calendar.YEAR) }

    // Fallback plans if item has empty plans
    val plans = remember(catalogItem) {
        if (catalogItem.plans.isNotEmpty()) {
            catalogItem.plans
        } else {
            listOf(
                CatalogPlan(
                    id = "${catalogItem.id}-basic",
                    name = "Temel Plan",
                    priceTry = catalogItem.priceTry * 0.75,
                    priceUsd = catalogItem.priceUsd * 0.75,
                    priceEur = catalogItem.priceEur * 0.75,
                    description = "Standart Erişim"
                ),
                CatalogPlan(
                    id = "${catalogItem.id}-standard",
                    name = catalogItem.tierName.ifBlank { "Standart Plan" },
                    priceTry = catalogItem.priceTry,
                    priceUsd = catalogItem.priceUsd,
                    priceEur = catalogItem.priceEur,
                    description = "Önerilen Paket"
                ),
                CatalogPlan(
                    id = "${catalogItem.id}-premium",
                    name = "Özel (Premium) Plan",
                    priceTry = catalogItem.priceTry * 1.4,
                    priceUsd = catalogItem.priceUsd * 1.4,
                    priceEur = catalogItem.priceEur * 1.4,
                    description = "Tüm Özellikler Dahil"
                )
            )
        }
    }

    var currentStep by remember { mutableIntStateOf(1) } // 1 = Paket Seçimi, 2 = Yenilenme Tarihi
    var selectedPlan by remember {
        mutableStateOf(
            plans.firstOrNull { it.name.contains("Standart", ignoreCase = true) } ?: plans.first()
        )
    }

    // Date state (default 30 days ahead)
    val calendar = remember {
        Calendar.getInstance().apply {
            add(Calendar.DAY_OF_MONTH, 30)
        }
    }
    val dateFormat = remember { SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()) }
    var selectedDateMs by remember { mutableStateOf(calendar.timeInMillis) }
    var manualDateText by remember { mutableStateOf(dateFormat.format(Date(selectedDateMs))) }
    var dateValidationError by remember { mutableStateOf<String?>(null) }
    var paymentCardHint by remember { mutableStateOf("") }

    val formattedDisplayDate = remember(selectedDateMs) {
        dateFormat.format(Date(selectedDateMs))
    }

    // Android DatePickerDialog Helper with minDate restriction
    val showDatePickerDialog = {
        val cal = Calendar.getInstance().apply { timeInMillis = selectedDateMs }
        val dateDialog = DatePickerDialog(
            context,
            { _, year, month, dayOfMonth ->
                val newCal = Calendar.getInstance().apply {
                    set(Calendar.YEAR, year)
                    set(Calendar.MONTH, month)
                    set(Calendar.DAY_OF_MONTH, dayOfMonth)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                }
                selectedDateMs = newCal.timeInMillis
                manualDateText = dateFormat.format(newCal.time)
                dateValidationError = null
            },
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH),
            cal.get(Calendar.DAY_OF_MONTH)
        )
        // Ensure calendar cannot pick past dates
        dateDialog.datePicker.minDate = System.currentTimeMillis() - 1000L
        dateDialog.show()
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .clip(RoundedCornerShape(24.dp))
                .testTag("fast_plan_date_modal"),
            color = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(24.dp),
            tonalElevation = 8.dp
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(22.dp)
            ) {
                // Header with App Identity and Step Progress
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        CategoryIconBadge(
                            category = catalogItem.category,
                            serviceName = catalogItem.name,
                            modifier = Modifier.size(44.dp)
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text(
                                text = catalogItem.name,
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.ExtraBold,
                                    fontSize = 18.sp
                                )
                            )
                            Text(
                                text = "${catalogItem.category} • Hızlı Ekleme",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    fontSize = 12.sp
                                )
                            )
                        }
                    }

                    IconButton(
                        onClick = onDismiss,
                        modifier = Modifier.testTag("modal_close_button")
                    ) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Kapat")
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Step Indicator Pills
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // Step 1 Pill
                    Surface(
                        modifier = Modifier
                            .weight(1f)
                            .clickable { currentStep = 1 },
                        color = if (currentStep == 1) NavyDark else EmeraldAccent.copy(alpha = 0.2f),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(vertical = 8.dp, horizontal = 10.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(20.dp)
                                    .background(
                                        if (currentStep == 1) EmeraldAccent else NavyDark,
                                        CircleShape
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "1",
                                    color = if (currentStep == 1) NavyDark else Color.White,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Paket Seçimi",
                                color = if (currentStep == 1) Color.White else NavyDark,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }

                    // Step 2 Pill
                    Surface(
                        modifier = Modifier
                            .weight(1f)
                            .clickable { currentStep = 2 },
                        color = if (currentStep == 2) NavyDark else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(vertical = 8.dp, horizontal = 10.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(20.dp)
                                    .background(
                                        if (currentStep == 2) EmeraldAccent else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                                        CircleShape
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "2",
                                    color = if (currentStep == 2) NavyDark else MaterialTheme.colorScheme.onSurface,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Yenilenme Tarihi",
                                color = if (currentStep == 2) Color.White else MaterialTheme.colorScheme.onSurface,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // STEP 1: PAKET SEÇİMİ (Plan Selection - SELECT ONLY)
                AnimatedVisibility(
                    visible = currentStep == 1,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "1. Paket Seçeneği",
                                style = MaterialTheme.typography.titleSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = NavyDark
                                )
                            )
                            Text(
                                text = "Tıklayarak seçin",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    fontSize = 11.sp
                                )
                            )
                        }

                        Spacer(modifier = Modifier.height(10.dp))

                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            plans.forEach { plan ->
                                val isSelected = selectedPlan.id == plan.id
                                val planPrice = when (currency) {
                                    "TRY" -> "₺${plan.priceTry}"
                                    "USD" -> "$${plan.priceUsd}"
                                    "EUR" -> "€${plan.priceEur}"
                                    else -> "₺${plan.priceTry}"
                                }

                                Surface(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(14.dp))
                                        .border(
                                            width = if (isSelected) 2.dp else 1.dp,
                                            color = if (isSelected) NavyDark else MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                                            shape = RoundedCornerShape(14.dp)
                                        )
                                        .clickable {
                                            selectedPlan = plan
                                        }
                                        .testTag("plan_option_${plan.id}"),
                                    color = if (isSelected) NavyDark.copy(alpha = 0.05f) else MaterialTheme.colorScheme.surface,
                                    shape = RoundedCornerShape(14.dp)
                                ) {
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(14.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.SpaceBetween
                                    ) {
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            modifier = Modifier.weight(1f)
                                        ) {
                                            Icon(
                                                imageVector = if (isSelected) Icons.Default.RadioButtonChecked else Icons.Default.RadioButtonUnchecked,
                                                contentDescription = null,
                                                tint = if (isSelected) NavyDark else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                                                modifier = Modifier.size(22.dp)
                                            )
                                            Spacer(modifier = Modifier.width(12.dp))
                                            Column {
                                                Text(
                                                    text = plan.name,
                                                    style = MaterialTheme.typography.bodyMedium.copy(
                                                        fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.SemiBold,
                                                        color = if (isSelected) NavyDark else MaterialTheme.colorScheme.onSurface
                                                    )
                                                )
                                                if (plan.description.isNotBlank()) {
                                                    Text(
                                                        text = plan.description,
                                                        style = MaterialTheme.typography.bodySmall.copy(
                                                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                                                            fontSize = 11.sp
                                                        )
                                                    )
                                                }
                                            }
                                        }

                                        Column(horizontalAlignment = Alignment.End) {
                                            Text(
                                                text = planPrice,
                                                style = MaterialTheme.typography.titleMedium.copy(
                                                    fontWeight = FontWeight.ExtraBold,
                                                    color = if (isSelected) NavyDark else MaterialTheme.colorScheme.onSurface
                                                )
                                            )
                                            Text(
                                                text = if (plan.billingCycle == "annual") "/yıl" else "/ay",
                                                style = MaterialTheme.typography.bodySmall.copy(
                                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                                    fontSize = 10.sp
                                                )
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(18.dp))

                        // Next Step Button
                        Button(
                            onClick = { currentStep = 2 },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(48.dp)
                                .testTag("btn_go_to_step_2"),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = NavyDark
                            ),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Text(
                                text = "2. Adıma Geç: Yenilenme Tarihi",
                                fontWeight = FontWeight.Bold,
                                fontSize = 14.sp,
                                color = Color.White
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }

                // STEP 2: YENİLENME TARİHİ (Billing Renewal Date - Calendar & --/--/---- Format)
                AnimatedVisibility(
                    visible = currentStep == 2,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "2. Yenilenme Tarihi",
                                style = MaterialTheme.typography.titleSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = NavyDark
                                )
                            )
                            Text(
                                text = "Seçilen: ${selectedPlan.name}",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = EmeraldAccent,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 11.sp
                                )
                            )
                        }

                        Spacer(modifier = Modifier.height(10.dp))

                        // Interactive Date Picker Trigger Card
                        Surface(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(14.dp))
                                .border(
                                    width = 1.5.dp,
                                    color = NavyDark.copy(alpha = 0.5f),
                                    shape = RoundedCornerShape(14.dp)
                                )
                                .clickable { showDatePickerDialog() }
                                .testTag("date_picker_trigger"),
                            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                            shape = RoundedCornerShape(14.dp)
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(14.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Default.CalendarMonth,
                                        contentDescription = null,
                                        tint = NavyDark,
                                        modifier = Modifier.size(24.dp)
                                    )
                                    Spacer(modifier = Modifier.width(12.dp))
                                    Column {
                                        Text(
                                            text = "Sonraki Fatura Günü",
                                            style = MaterialTheme.typography.bodySmall.copy(
                                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                                fontSize = 11.sp
                                            )
                                        )
                                        Text(
                                            text = formattedDisplayDate,
                                            style = MaterialTheme.typography.titleMedium.copy(
                                                fontWeight = FontWeight.ExtraBold,
                                                color = NavyDark
                                            )
                                        )
                                    }
                                }

                                Surface(
                                    color = NavyDark.copy(alpha = 0.1f),
                                    shape = RoundedCornerShape(8.dp)
                                ) {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 6.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.EditCalendar,
                                            contentDescription = null,
                                            tint = NavyDark,
                                            modifier = Modifier.size(14.dp)
                                        )
                                        Spacer(modifier = Modifier.width(4.dp))
                                        Text(
                                            text = "Takvimden Seç",
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = NavyDark
                                        )
                                    }
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(10.dp))

                        // Quick Date Preset Chips
                        Text(
                            text = "Hızlı Tarih Kısayolları:",
                            style = MaterialTheme.typography.bodySmall.copy(
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                fontSize = 11.sp
                            )
                        )
                        Spacer(modifier = Modifier.height(6.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            val presets = listOf(
                                "+30 Gün" to 30,
                                "+14 Gün" to 14,
                                "Gelecek Ayın 1'i" to -1,
                                "Gelecek Ayın 15'i" to -15
                            )

                            presets.forEach { (label, days) ->
                                Surface(
                                    modifier = Modifier
                                        .weight(1f)
                                        .clickable {
                                            val cal = Calendar.getInstance()
                                            when (days) {
                                                -1 -> {
                                                    cal.add(Calendar.MONTH, 1)
                                                    cal.set(Calendar.DAY_OF_MONTH, 1)
                                                }
                                                -15 -> {
                                                    cal.add(Calendar.MONTH, 1)
                                                    cal.set(Calendar.DAY_OF_MONTH, 15)
                                                }
                                                else -> {
                                                    cal.add(Calendar.DAY_OF_MONTH, days)
                                                }
                                            }
                                            selectedDateMs = cal.timeInMillis
                                            manualDateText = dateFormat.format(cal.time)
                                            dateValidationError = null
                                        },
                                    color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                                    shape = RoundedCornerShape(8.dp)
                                ) {
                                    Text(
                                        text = label,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        modifier = Modifier.padding(vertical = 6.dp, horizontal = 4.dp),
                                        color = MaterialTheme.colorScheme.onSurface
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        // Manual Date Input Field: GG/AA/YYYY (--/--/----)
                        // Limits: Day (max 2 digits, 01-31), Month (max 2 digits, 01-12), Year (max 4 digits, >= currentYear)
                        OutlinedTextField(
                            value = manualDateText,
                            onValueChange = { input ->
                                val (formatted, error, parsedTime) = formatAndValidateDateInput(input, currentYear)
                                manualDateText = formatted
                                dateValidationError = error
                                if (parsedTime != null) {
                                    selectedDateMs = parsedTime
                                }
                            },
                            label = { Text("Tarihi Elle Yazın (GG/AA/YYYY)") },
                            placeholder = { Text("--/--/----") },
                            trailingIcon = {
                                IconButton(onClick = { showDatePickerDialog() }) {
                                    Icon(
                                        imageVector = Icons.Default.CalendarMonth,
                                        contentDescription = "Takvimi Aç",
                                        tint = NavyDark
                                    )
                                }
                            },
                            supportingText = {
                                if (dateValidationError != null) {
                                    Text(
                                        text = dateValidationError!!,
                                        color = MaterialTheme.colorScheme.error,
                                        fontSize = 11.sp
                                    )
                                } else {
                                    Text(
                                        text = "Format: GG/AA/YYYY • Yalnızca $currentYear ve ileri yıllar girilebilir",
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        fontSize = 11.sp
                                    )
                                }
                            },
                            isError = dateValidationError != null,
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("manual_date_input"),
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                        )

                        Spacer(modifier = Modifier.height(6.dp))

                        // Payment card note hint
                        OutlinedTextField(
                            value = paymentCardHint,
                            onValueChange = { paymentCardHint = it },
                            label = { Text("Ödeme Yöntemi İpucu (İsteğe bağlı)") },
                            placeholder = { Text("Örn: Garanti ••4092") },
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("card_hint_input"),
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp)
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // Action Buttons: Geri & Oluştur
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Button(
                                onClick = { currentStep = 1 },
                                modifier = Modifier
                                    .weight(1f)
                                    .height(48.dp),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = MaterialTheme.colorScheme.surfaceVariant,
                                    contentColor = MaterialTheme.colorScheme.onSurface
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                    contentDescription = null,
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Geri", fontWeight = FontWeight.Bold)
                            }

                            Button(
                                onClick = {
                                    onConfirm(
                                        catalogItem,
                                        selectedPlan,
                                        selectedDateMs,
                                        paymentCardHint
                                    )
                                },
                                modifier = Modifier
                                    .weight(2f)
                                    .height(48.dp)
                                    .testTag("btn_finalize_subscription"),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = NavyDark
                                ),
                                shape = RoundedCornerShape(12.dp),
                                enabled = dateValidationError == null
                            ) {
                                Icon(
                                    imageVector = Icons.Default.CheckCircle,
                                    contentDescription = null,
                                    tint = EmeraldAccent,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Aboneliği Oluştur",
                                    fontWeight = FontWeight.ExtraBold,
                                    fontSize = 14.sp,
                                    color = Color.White
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * Özel / Manuel Abonelik Formu (Takvim ve GG/AA/YYYY tarih girişi destekli)
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CustomSubscriptionTabContent(
    initialCurrency: String,
    onSubmit: (SubscriptionEntity) -> Unit
) {
    val context = LocalContext.current
    val currentYear = remember { Calendar.getInstance().get(Calendar.YEAR) }

    var name by remember { mutableStateOf("") }
    var priceStr by remember { mutableStateOf("") }
    var currency by remember { mutableStateOf(initialCurrency) }
    var category by remember { mutableStateOf("Streaming Video") }
    var billingCycle by remember { mutableStateOf("monthly") }
    var isTrial by remember { mutableStateOf(false) }
    var cardHint by remember { mutableStateOf("") }
    var cancellationUrl by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

    // Date state
    val defaultCalendar = remember {
        Calendar.getInstance().apply {
            add(Calendar.DAY_OF_MONTH, 30)
        }
    }
    val dateFormat = remember { SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()) }
    var selectedDateMs by remember { mutableStateOf(defaultCalendar.timeInMillis) }
    var manualDateText by remember { mutableStateOf(dateFormat.format(Date(selectedDateMs))) }
    var dateValidationError by remember { mutableStateOf<String?>(null) }

    val showDatePicker = {
        val cal = Calendar.getInstance().apply { timeInMillis = selectedDateMs }
        val dialog = DatePickerDialog(
            context,
            { _, year, month, dayOfMonth ->
                val newCal = Calendar.getInstance().apply {
                    set(Calendar.YEAR, year)
                    set(Calendar.MONTH, month)
                    set(Calendar.DAY_OF_MONTH, dayOfMonth)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                }
                selectedDateMs = newCal.timeInMillis
                manualDateText = dateFormat.format(newCal.time)
                dateValidationError = null
            },
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH),
            cal.get(Calendar.DAY_OF_MONTH)
        )
        dialog.datePicker.minDate = System.currentTimeMillis() - 1000L
        dialog.show()
    }

    val categories = listOf(
        "Streaming Video",
        "Music & Audio",
        "AI & Productivity",
        "Cloud Storage",
        "Gaming",
        "Sports & TV",
        "Education",
        "Shopping & Video",
        "Other"
    )

    val cycles = listOf("monthly", "annual", "weekly", "quarterly")
    val currencies = listOf("TRY", "USD", "EUR")

    var isCategoryExpanded by remember { mutableStateOf(false) }
    var isCycleExpanded by remember { mutableStateOf(false) }
    var isCurrencyExpanded by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        item {
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Servis / Abonelik Adı *") },
                placeholder = { Text("Örn: Notion Plus, Midjourney") },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("custom_sub_name_input"),
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
            )
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = priceStr,
                    onValueChange = { priceStr = it },
                    label = { Text("Fiyat *") },
                    placeholder = { Text("199.90") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier
                        .weight(1.5f)
                        .testTag("custom_sub_price_input"),
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp)
                )

                // Currency Dropdown
                ExposedDropdownMenuBox(
                    expanded = isCurrencyExpanded,
                    onExpandedChange = { isCurrencyExpanded = !isCurrencyExpanded },
                    modifier = Modifier.weight(1f)
                ) {
                    OutlinedTextField(
                        value = currency,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Para Birimi") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = isCurrencyExpanded) },
                        modifier = Modifier
                            .menuAnchor(MenuAnchorType.PrimaryNotEditable)
                            .fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp)
                    )
                    ExposedDropdownMenu(
                        expanded = isCurrencyExpanded,
                        onDismissRequest = { isCurrencyExpanded = false }
                    ) {
                        currencies.forEach { curr ->
                            DropdownMenuItem(
                                text = { Text(curr) },
                                onClick = {
                                    currency = curr
                                    isCurrencyExpanded = false
                                }
                            )
                        }
                    }
                }
            }
        }

        item {
            // Category Dropdown
            ExposedDropdownMenuBox(
                expanded = isCategoryExpanded,
                onExpandedChange = { isCategoryExpanded = !isCategoryExpanded },
                modifier = Modifier.fillMaxWidth()
            ) {
                OutlinedTextField(
                    value = category,
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Kategori") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = isCategoryExpanded) },
                    modifier = Modifier
                        .menuAnchor(MenuAnchorType.PrimaryNotEditable)
                        .fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp)
                )
                ExposedDropdownMenu(
                    expanded = isCategoryExpanded,
                    onDismissRequest = { isCategoryExpanded = false }
                ) {
                    categories.forEach { cat ->
                        DropdownMenuItem(
                            text = { Text(cat) },
                            onClick = {
                                category = cat
                                isCategoryExpanded = false
                            }
                        )
                    }
                }
            }
        }

        item {
            // Billing Cycle Dropdown
            ExposedDropdownMenuBox(
                expanded = isCycleExpanded,
                onExpandedChange = { isCycleExpanded = !isCycleExpanded },
                modifier = Modifier.fillMaxWidth()
            ) {
                OutlinedTextField(
                    value = when (billingCycle) {
                        "monthly" -> "Aylık (Monthly)"
                        "annual" -> "Yıllık (Annual)"
                        "weekly" -> "Haftalık (Weekly)"
                        "quarterly" -> "3 Aylık (Quarterly)"
                        else -> billingCycle
                    },
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Fatura Periyodu") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = isCycleExpanded) },
                    modifier = Modifier
                        .menuAnchor(MenuAnchorType.PrimaryNotEditable)
                        .fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp)
                )
                ExposedDropdownMenu(
                    expanded = isCycleExpanded,
                    onDismissRequest = { isCycleExpanded = false }
                ) {
                    cycles.forEach { cyc ->
                        val label = when (cyc) {
                            "monthly" -> "Aylık (Monthly)"
                            "annual" -> "Yıllık (Annual)"
                            "weekly" -> "Haftalık (Weekly)"
                            "quarterly" -> "3 Aylık (Quarterly)"
                            else -> cyc
                        }
                        DropdownMenuItem(
                            text = { Text(label) },
                            onClick = {
                                billingCycle = cyc
                                isCycleExpanded = false
                            }
                        )
                    }
                }
            }
        }

        // Custom Date Field (Takvim + GG/AA/YYYY Giriş)
        item {
            OutlinedTextField(
                value = manualDateText,
                onValueChange = { input ->
                    val (formatted, error, parsedTime) = formatAndValidateDateInput(input, currentYear)
                    manualDateText = formatted
                    dateValidationError = error
                    if (parsedTime != null) {
                        selectedDateMs = parsedTime
                    }
                },
                label = { Text("Sonraki Yenilenme Tarihi (GG/AA/YYYY)") },
                placeholder = { Text("--/--/----") },
                trailingIcon = {
                    IconButton(onClick = { showDatePicker() }) {
                        Icon(
                            imageVector = Icons.Default.CalendarMonth,
                            contentDescription = "Takvimi Aç",
                            tint = NavyDark
                        )
                    }
                },
                supportingText = {
                    if (dateValidationError != null) {
                        Text(
                            text = dateValidationError!!,
                            color = MaterialTheme.colorScheme.error,
                            fontSize = 11.sp
                        )
                    } else {
                        Text(
                            text = "Format: GG/AA/YYYY • Yalnızca $currentYear ve ileri yıllar girilebilir",
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            fontSize = 11.sp
                        )
                    }
                },
                isError = dateValidationError != null,
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("custom_sub_date_input"),
                singleLine = true,
                shape = RoundedCornerShape(12.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
            )
        }

        item {
            // Trial Switch
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                ),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Ücretsiz Deneme (Trial Modu)",
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp
                        )
                        Text(
                            text = "Deneme bitimine 24-48 saat kala otomatik bildirim gönderilsin",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Switch(
                        checked = isTrial,
                        onCheckedChange = { isTrial = it },
                        modifier = Modifier.testTag("trial_mode_switch")
                    )
                }
            }
        }

        item {
            OutlinedTextField(
                value = cardHint,
                onValueChange = { cardHint = it },
                label = { Text("Ödeme Kartı İpucu") },
                placeholder = { Text("Örn: İş Bankası ••3091") },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("custom_card_hint_input"),
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
            )
        }

        item {
            OutlinedTextField(
                value = cancellationUrl,
                onValueChange = { cancellationUrl = it },
                label = { Text("Doğrudan İptal Bağlantısı (Opsiyonel)") },
                placeholder = { Text("https://www.ornek.com/hesabim/iptal") },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("custom_cancellation_url_input"),
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
            )
        }

        item {
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                label = { Text("Notlar") },
                placeholder = { Text("Örn: Deneme süresinde iptal et") },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("custom_notes_input"),
                shape = RoundedCornerShape(12.dp)
            )
        }

        item {
            Spacer(modifier = Modifier.height(8.dp))
            Button(
                onClick = {
                    val priceVal = priceStr.toDoubleOrNull() ?: 0.0
                    if (name.isNotBlank() && priceVal > 0 && dateValidationError == null) {
                        val trialEnd = if (isTrial) selectedDateMs else null

                        val entity = SubscriptionEntity(
                            serviceName = name.trim(),
                            category = category,
                            billingCycle = billingCycle,
                            price = priceVal,
                            currency = currency,
                            nextBillingDateMs = selectedDateMs,
                            trialEndDateMs = trialEnd,
                            isTrial = isTrial,
                            alertTrial24h = true,
                            paymentMethodHint = cardHint.ifBlank { null },
                            cancellationUrl = cancellationUrl.ifBlank { null },
                            reminderDays = "7,3,1,0",
                            notes = notes.ifBlank { null }
                        )
                        onSubmit(entity)
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
                    .testTag("save_custom_subscription_button"),
                colors = ButtonDefaults.buttonColors(
                    containerColor = NavyDark
                ),
                shape = RoundedCornerShape(12.dp),
                enabled = name.isNotBlank() && (priceStr.toDoubleOrNull() ?: 0.0) > 0 && dateValidationError == null
            ) {
                Text(
                    text = "Aboneliği Kaydet",
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    color = Color.White
                )
            }
        }
    }
}
