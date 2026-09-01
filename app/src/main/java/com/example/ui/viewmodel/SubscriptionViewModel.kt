package com.example.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.model.CatalogData
import com.example.data.model.CatalogItem
import com.example.data.model.SubscriptionEntity
import com.example.data.notification.NotificationSchedulerService
import com.example.data.repository.AlternativeRecommendation
import com.example.data.repository.SubscriptionRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.math.BigDecimal
import java.math.RoundingMode

data class DashboardUiState(
    val subscriptions: List<SubscriptionEntity> = emptyList(),
    val filteredSubscriptions: List<SubscriptionEntity> = emptyList(),
    val selectedCategory: String = "Tümü",
    val selectedCurrency: String = "TRY", // TRY, USD, EUR
    val monthlyBurnRate: Double = 0.0,
    val annualBurnRate: Double = 0.0,
    val trialExpiringCount: Int = 0,
    val trialExpiringList: List<SubscriptionEntity> = emptyList(),
    val priceHikeCount: Int = 0,
    val priceHikeList: List<SubscriptionEntity> = emptyList(),
    val activeSubscriptionCount: Int = 0,
    val selectedSubscription: SubscriptionEntity? = null,
    val showAddDialog: Boolean = false,
    val showDetailSheet: Boolean = false,
    val showAlternativesDialog: Boolean = false,
    val showBackupDialog: Boolean = false,
    val alternativesList: List<AlternativeRecommendation> = emptyList(),
    val recentlyDeletedSub: SubscriptionEntity? = null
)

class SubscriptionViewModel(
    application: Application,
    private val repository: SubscriptionRepository
) : AndroidViewModel(application) {

    init {
        NotificationSchedulerService.initialize(application)
    }

    private val _selectedCategory = MutableStateFlow("Tümü")
    val selectedCategory = _selectedCategory.asStateFlow()

    private val _selectedCurrency = MutableStateFlow("TRY")
    val selectedCurrency = _selectedCurrency.asStateFlow()

    private val _selectedSubscription = MutableStateFlow<SubscriptionEntity?>(null)
    val selectedSubscription = _selectedSubscription.asStateFlow()

    private val _showAddDialog = MutableStateFlow(false)
    val showAddDialog = _showAddDialog.asStateFlow()

    private val _showDetailSheet = MutableStateFlow(false)
    val showDetailSheet = _showDetailSheet.asStateFlow()

    private val _showAlternativesDialog = MutableStateFlow(false)
    val showAlternativesDialog = _showAlternativesDialog.asStateFlow()

    private val _showBackupDialog = MutableStateFlow(false)
    val showBackupDialog = _showBackupDialog.asStateFlow()

    private val _alternativesList = MutableStateFlow<List<AlternativeRecommendation>>(emptyList())
    val alternativesList = _alternativesList.asStateFlow()

    private val _recentlyDeletedSub = MutableStateFlow<SubscriptionEntity?>(null)
    val recentlyDeletedSub = _recentlyDeletedSub.asStateFlow()

    val uiState: StateFlow<DashboardUiState> = combine(
        repository.allSubscriptions,
        _selectedCategory,
        _selectedCurrency,
        _selectedSubscription,
        _showAddDialog,
        _showDetailSheet,
        _showAlternativesDialog,
        _showBackupDialog,
        _alternativesList,
        _recentlyDeletedSub
    ) { args: Array<Any?> ->
        @Suppress("UNCHECKED_CAST")
        val subs = args[0] as List<SubscriptionEntity>
        val category = args[1] as String
        val currency = args[2] as String
        val selectedSub = args[3] as SubscriptionEntity?
        val showAdd = args[4] as Boolean
        val showDetail = args[5] as Boolean
        val showAlts = args[6] as Boolean
        val showBackup = args[7] as Boolean
        @Suppress("UNCHECKED_CAST")
        val alts = args[8] as List<AlternativeRecommendation>
        val deletedSub = args[9] as SubscriptionEntity?

        val filtered = if (category == "Tümü") {
            subs
        } else {
            subs.filter { it.category.equals(category, ignoreCase = true) }
        }

        // Calculate Monthly Burn Rate normalized to selected currency
        var totalMonthly = 0.0
        subs.forEach { sub ->
            val normalizedToSub = when (sub.billingCycle.lowercase()) {
                "annual", "yıllık" -> sub.price / 12.0
                "weekly", "haftalık" -> sub.price * 4.33
                "quarterly", "3 aylık" -> sub.price / 3.0
                else -> sub.price
            }
            val converted = repository.convertPrice(normalizedToSub, sub.currency, currency)
            totalMonthly += converted
        }

        val roundedMonthly = BigDecimal(totalMonthly).setScale(2, RoundingMode.HALF_UP).toDouble()
        val roundedAnnual = BigDecimal(totalMonthly * 12).setScale(2, RoundingMode.HALF_UP).toDouble()

        // 24-48h Trial Expiring Guardian Filter
        val now = System.currentTimeMillis()
        val twoDaysMs = 48L * 60 * 60 * 1000
        val trialList = subs.filter {
            it.isTrial && it.trialEndDateMs != null && (it.trialEndDateMs - now) in 0..twoDaysMs
        }

        // Price Hike Filter
        val hikeList = subs.filter { it.isPriceHikeDetected }

        DashboardUiState(
            subscriptions = subs,
            filteredSubscriptions = filtered,
            selectedCategory = category,
            selectedCurrency = currency,
            monthlyBurnRate = roundedMonthly,
            annualBurnRate = roundedAnnual,
            trialExpiringCount = trialList.size,
            trialExpiringList = trialList,
            priceHikeCount = hikeList.size,
            priceHikeList = hikeList,
            activeSubscriptionCount = subs.size,
            selectedSubscription = selectedSub,
            showAddDialog = showAdd,
            showDetailSheet = showDetail,
            showAlternativesDialog = showAlts,
            showBackupDialog = showBackup,
            alternativesList = alts,
            recentlyDeletedSub = deletedSub
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = DashboardUiState()
    )

    fun setCategory(category: String) {
        _selectedCategory.value = category
    }

    fun setCurrency(currency: String) {
        _selectedCurrency.value = currency
    }

    fun openAddDialog() {
        _showAddDialog.value = true
    }

    fun closeAddDialog() {
        _showAddDialog.value = false
    }

    fun openBackupDialog() {
        _showBackupDialog.value = true
    }

    fun closeBackupDialog() {
        _showBackupDialog.value = false
    }

    fun selectSubscription(subscription: SubscriptionEntity) {
        _selectedSubscription.value = subscription
        _showDetailSheet.value = true
    }

    fun closeDetailSheet() {
        _showDetailSheet.value = false
        _selectedSubscription.value = null
    }

    fun openAlternatives(subscription: SubscriptionEntity) {
        val alts = repository.getAlternativesFor(subscription.serviceName, subscription.price, subscription.currency)
        _alternativesList.value = alts
        _showAlternativesDialog.value = true
    }

    fun closeAlternativesDialog() {
        _showAlternativesDialog.value = false
    }

    fun addSubscription(subscription: SubscriptionEntity) {
        viewModelScope.launch {
            val insertedId = repository.insert(subscription)
            val fullEntity = subscription.copy(id = insertedId)
            NotificationSchedulerService.scheduleRemindersForSubscription(getApplication(), fullEntity)
            _showAddDialog.value = false
        }
    }

    fun addFromCatalog(catalogItem: CatalogItem, currency: String, paymentHint: String = "") {
        val price = when (currency) {
            "TRY" -> catalogItem.priceTry
            "USD" -> catalogItem.priceUsd
            "EUR" -> catalogItem.priceEur
            else -> catalogItem.priceTry
        }
        val nextMonth = System.currentTimeMillis() + (30L * 24 * 60 * 60 * 1000)
        val entity = SubscriptionEntity(
            serviceName = catalogItem.name,
            category = catalogItem.category,
            billingCycle = catalogItem.defaultBillingCycle,
            price = price,
            currency = currency,
            nextBillingDateMs = nextMonth,
            catalogId = catalogItem.id,
            paymentMethodHint = paymentHint.ifBlank { null },
            cancellationUrl = catalogItem.cancellationUrl,
            reminderDays = "7,3,1,0",
            baselineCatalogPrice = price,
            isPriceHikeDetected = false
        )
        viewModelScope.launch {
            val insertedId = repository.insert(entity)
            NotificationSchedulerService.scheduleRemindersForSubscription(getApplication(), entity.copy(id = insertedId))
            _showAddDialog.value = false
        }
    }

    fun addFromCatalogPlan(
        catalogItem: CatalogItem,
        plan: com.example.data.model.CatalogPlan,
        currency: String,
        nextBillingDateMs: Long,
        paymentHint: String = ""
    ) {
        val price = when (currency) {
            "TRY" -> plan.priceTry
            "USD" -> plan.priceUsd
            "EUR" -> plan.priceEur
            else -> plan.priceTry
        }
        val displayName = if (plan.name.contains(catalogItem.name, ignoreCase = true)) {
            plan.name
        } else {
            "${catalogItem.name} - ${plan.name}"
        }
        val entity = SubscriptionEntity(
            serviceName = displayName,
            category = catalogItem.category,
            billingCycle = plan.billingCycle,
            price = price,
            currency = currency,
            nextBillingDateMs = nextBillingDateMs,
            catalogId = catalogItem.id,
            paymentMethodHint = paymentHint.ifBlank { null },
            cancellationUrl = catalogItem.cancellationUrl,
            reminderDays = "7,3,1,0",
            baselineCatalogPrice = price,
            isPriceHikeDetected = false
        )
        viewModelScope.launch {
            val insertedId = repository.insert(entity)
            NotificationSchedulerService.scheduleRemindersForSubscription(getApplication(), entity.copy(id = insertedId))
            _showAddDialog.value = false
        }
    }

    fun deleteSubscription(subscription: SubscriptionEntity) {
        viewModelScope.launch {
            NotificationSchedulerService.cancelRemindersForSubscription(getApplication(), subscription.id)
            _recentlyDeletedSub.value = subscription
            repository.delete(subscription)
            if (_selectedSubscription.value?.id == subscription.id) {
                closeDetailSheet()
            }
        }
    }

    fun undoDelete() {
        _recentlyDeletedSub.value?.let { sub ->
            viewModelScope.launch {
                val insertedId = repository.insert(sub)
                NotificationSchedulerService.scheduleRemindersForSubscription(getApplication(), sub.copy(id = insertedId))
                _recentlyDeletedSub.value = null
            }
        }
    }

    fun restoreSubscriptions(restoredList: List<SubscriptionEntity>) {
        viewModelScope.launch {
            repository.restoreAll(restoredList)
            restoredList.forEach { sub ->
                NotificationSchedulerService.scheduleRemindersForSubscription(getApplication(), sub)
            }
        }
    }
}

class SubscriptionViewModelFactory(
    private val application: Application,
    private val repository: SubscriptionRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(SubscriptionViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return SubscriptionViewModel(application, repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}

