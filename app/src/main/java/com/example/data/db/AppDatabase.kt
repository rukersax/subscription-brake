package com.example.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.data.model.SubscriptionEntity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Database(entities = [SubscriptionEntity::class], version = 2, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun subscriptionDao(): SubscriptionDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context, scope: CoroutineScope): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "subscription_brake.db"
                )
                .fallbackToDestructiveMigration(dropAllTables = true)
                .build()
                INSTANCE = instance

                // Ensure initial seed data is present
                scope.launch(Dispatchers.IO) {
                    try {
                        val count = instance.subscriptionDao().getCount()
                        if (count == 0) {
                            populateInitialData(instance.subscriptionDao())
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }

                instance
            }
        }

        suspend fun populateInitialData(dao: SubscriptionDao) {
            val now = System.currentTimeMillis()
            val dayMs = 24L * 60 * 60 * 1000

            val sampleData = listOf(
                SubscriptionEntity(
                    serviceName = "Netflix",
                    category = "Streaming Video",
                    billingCycle = "monthly",
                    price = 269.99, // Intentional price hike above 229.99 standard
                    currency = "TRY",
                    nextBillingDateMs = now + (12 * dayMs),
                    baselineCatalogPrice = 229.99,
                    isPriceHikeDetected = true,
                    priceHikePercentage = 17.39,
                    paymentMethodHint = "Garanti BBVA ••4092",
                    cancellationUrl = "https://www.netflix.com/youraccount",
                    notes = "Aile Paketi HD 2 Ekran"
                ),
                SubscriptionEntity(
                    serviceName = "Spotify Premium",
                    category = "Music & Audio",
                    billingCycle = "monthly",
                    price = 59.99,
                    currency = "TRY",
                    nextBillingDateMs = now + (5 * dayMs),
                    baselineCatalogPrice = 59.99,
                    isPriceHikeDetected = false,
                    cancellationUrl = "https://www.spotify.com/account/cancel/",
                    paymentMethodHint = "Papara Card ••1024"
                ),
                SubscriptionEntity(
                    serviceName = "Exxen Reklamsız",
                    category = "Streaming Video",
                    billingCycle = "monthly",
                    price = 222.50,
                    currency = "TRY",
                    nextBillingDateMs = now + (18 * dayMs),
                    baselineCatalogPrice = 222.50,
                    isPriceHikeDetected = false,
                    cancellationUrl = "https://www.exxen.com/tr/hesabim",
                    paymentMethodHint = "Enpara ••8831"
                ),
                SubscriptionEntity(
                    serviceName = "ChatGPT Plus",
                    category = "AI & Productivity",
                    billingCycle = "monthly",
                    price = 649.99,
                    currency = "TRY",
                    nextBillingDateMs = now + (22 * dayMs),
                    baselineCatalogPrice = 649.99,
                    isPriceHikeDetected = false,
                    cancellationUrl = "https://chatgpt.com/#settings/Subscription",
                    paymentMethodHint = "İş Bankası ••3091"
                ),
                SubscriptionEntity(
                    serviceName = "Storytel Deneme",
                    category = "Audiobooks",
                    billingCycle = "monthly",
                    price = 149.99,
                    currency = "TRY",
                    nextBillingDateMs = now + (dayMs - 4 * 3600 * 1000), // In 20 hours
                    trialEndDateMs = now + (dayMs - 4 * 3600 * 1000),
                    isTrial = true,
                    alertTrial24h = true,
                    cancellationUrl = "https://www.storytel.com/tr/tr/hesabim",
                    paymentMethodHint = "Garanti BBVA ••4092",
                    notes = "Deneme bitmeden iptal et veya 149.99 TL çeker"
                )
            )
            dao.insertAll(sampleData)
        }
    }
}
