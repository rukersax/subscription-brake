package com.example.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "subscriptions")
data class SubscriptionEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val serviceName: String,
    val category: String,
    val billingCycle: String = "monthly", // monthly, annual, weekly, quarterly
    val price: Double,
    val currency: String = "TRY", // TRY, USD, EUR
    val nextBillingDateMs: Long,
    val trialEndDateMs: Long? = null,
    val isTrial: Boolean = false,
    val alertTrial24h: Boolean = true,
    val catalogId: String? = null,
    val paymentMethodHint: String? = null,
    val cancellationUrl: String? = null,
    val reminderDays: String = "7,3,1,0", // [7, 3, 1, 0] days before billing
    val notes: String? = null,
    val baselineCatalogPrice: Double? = null,
    val isPriceHikeDetected: Boolean = false,
    val priceHikePercentage: Double? = null,
    val status: String = "active", // active, paused, cancelled
    val createdAtMs: Long = System.currentTimeMillis()
)

