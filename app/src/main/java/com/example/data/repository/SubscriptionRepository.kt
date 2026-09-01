package com.example.data.repository

import com.example.data.db.SubscriptionDao
import com.example.data.model.CatalogData
import com.example.data.model.SubscriptionEntity
import kotlinx.coroutines.flow.Flow
import java.math.BigDecimal
import java.math.RoundingMode

data class AlternativeRecommendation(
    val currentServiceName: String,
    val alternativeName: String,
    val description: String,
    val monthlyPrice: Double,
    val currency: String,
    val potentialSavingsPercentage: Int,
    val linkHint: String
)

class SubscriptionRepository(private val subscriptionDao: SubscriptionDao) {

    val allSubscriptions: Flow<List<SubscriptionEntity>> = subscriptionDao.getAllSubscriptions()

    // Currency exchange rates (relative to USD standard for clean cross conversion)
    companion object {
        const val USD_TO_TRY = 34.20
        const val EUR_TO_TRY = 37.80
        const val USD_TO_EUR = 0.90
    }

    suspend fun insert(subscription: SubscriptionEntity): Long {
        val checkedSub = evaluatePriceHike(subscription)
        return subscriptionDao.insertSubscription(checkedSub)
    }

    suspend fun restoreAll(subscriptions: List<SubscriptionEntity>) {
        val checkedList = subscriptions.map { evaluatePriceHike(it) }
        subscriptionDao.insertAll(checkedList)
    }

    suspend fun update(subscription: SubscriptionEntity) {
        val checkedSub = evaluatePriceHike(subscription)
        subscriptionDao.updateSubscription(checkedSub)
    }

    suspend fun delete(subscription: SubscriptionEntity) {
        subscriptionDao.deleteSubscription(subscription)
    }

    suspend fun deleteById(id: Long) {
        subscriptionDao.deleteById(id)
    }

    suspend fun getById(id: Long): SubscriptionEntity? {
        return subscriptionDao.getSubscriptionById(id)
    }

    private fun evaluatePriceHike(sub: SubscriptionEntity): SubscriptionEntity {
        val catalogMatch = CatalogData.predefinedServices.find {
            it.name.equals(sub.serviceName, ignoreCase = true) ||
            (sub.catalogId != null && it.id == sub.catalogId)
        }

        if (catalogMatch != null) {
            val basePriceInSubCurrency = when (sub.currency) {
                "TRY" -> catalogMatch.priceTry
                "USD" -> catalogMatch.priceUsd
                "EUR" -> catalogMatch.priceEur
                else -> catalogMatch.priceTry
            }

            if (sub.price > (basePriceInSubCurrency * 1.05)) { // 5% buffer threshold
                val diffPercent = ((sub.price - basePriceInSubCurrency) / basePriceInSubCurrency) * 100.0
                return sub.copy(
                    baselineCatalogPrice = basePriceInSubCurrency,
                    isPriceHikeDetected = true,
                    priceHikePercentage = BigDecimal(diffPercent).setScale(1, RoundingMode.HALF_UP).toDouble()
                )
            } else {
                return sub.copy(
                    baselineCatalogPrice = basePriceInSubCurrency,
                    isPriceHikeDetected = false,
                    priceHikePercentage = null
                )
            }
        }
        return sub
    }

    fun convertPrice(amount: Double, fromCurrency: String, toCurrency: String): Double {
        if (fromCurrency == toCurrency) return amount
        // Normalize to TRY first
        val amountInTry = when (fromCurrency) {
            "TRY" -> amount
            "USD" -> amount * USD_TO_TRY
            "EUR" -> amount * EUR_TO_TRY
            else -> amount
        }
        // Convert from TRY to target
        return when (toCurrency) {
            "TRY" -> amountInTry
            "USD" -> amountInTry / USD_TO_TRY
            "EUR" -> amountInTry / EUR_TO_TRY
            else -> amountInTry
        }
    }

    fun getAlternativesFor(serviceName: String, currentPrice: Double, currency: String): List<AlternativeRecommendation> {
        val lower = serviceName.lowercase()
        return when {
            lower.contains("netflix") -> listOf(
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "Amazon Prime Video",
                    description = "Prime kargo avantajları ve binlerce popüler film/dizi içerir.",
                    monthlyPrice = 39.00,
                    currency = "TRY",
                    potentialSavingsPercentage = 83,
                    linkHint = "primevideo.com"
                ),
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "BluTV (Hepsiburada Premium)",
                    description = "Hepsiburada Premium aboneliği ile BluTV hediye olarak gelir.",
                    monthlyPrice = 49.90,
                    currency = "TRY",
                    potentialSavingsPercentage = 78,
                    linkHint = "hepsiburada.com/premium"
                )
            )
            lower.contains("spotify") || lower.contains("müzik") -> listOf(
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "YouTube Premium (Müzik Dahil)",
                    description = "Hem YouTube reklamsız video hem de YouTube Music sınırsız streaming.",
                    monthlyPrice = 79.99,
                    currency = "TRY",
                    potentialSavingsPercentage = 30,
                    linkHint = "youtube.com/premium"
                ),
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "Spotify Aile / Öğrenci Planı",
                    description = "6 kişi paylaşımı ile kişi başı aylık maliyet ~16 TL'ye düşer.",
                    monthlyPrice = 16.50,
                    currency = "TRY",
                    potentialSavingsPercentage = 72,
                    linkHint = "spotify.com/family"
                )
            )
            lower.contains("chatgpt") || lower.contains("ai") -> listOf(
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "Google Gemini Advanced (Google One 2TB)",
                    description = "Gemini 1.5 Pro + 2TB Google Drive alanı dahil.",
                    monthlyPrice = 719.99,
                    currency = "TRY",
                    potentialSavingsPercentage = 15,
                    linkHint = "gemini.google.com"
                ),
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "Claude 3.5 Sonnet (Free / API)",
                    description = "Günlük ücretsiz kota veya kullandığın kadar öde API modeli.",
                    monthlyPrice = 0.0,
                    currency = "TRY",
                    potentialSavingsPercentage = 100,
                    linkHint = "claude.ai"
                )
            )
            lower.contains("storytel") -> listOf(
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "Audioteka / TRT Dinle",
                    description = "TRT Dinle üzerinden yüzlerce radyo tiyatrosu ve sesli kitap tamamen ücretsizdir.",
                    monthlyPrice = 0.0,
                    currency = "TRY",
                    potentialSavingsPercentage = 100,
                    linkHint = "trtdinle.com"
                )
            )
            else -> listOf(
                AlternativeRecommendation(
                    currentServiceName = serviceName,
                    alternativeName = "Yıllık Ödeme İndirimi",
                    description = "Aylık yerine yıllık faturalandırmaya geçerek ortalama 2 ay bedava kazanın.",
                    monthlyPrice = currentPrice * 0.83,
                    currency = currency,
                    potentialSavingsPercentage = 17,
                    linkHint = "Hesap Ayarları"
                )
            )
        }
    }
}
