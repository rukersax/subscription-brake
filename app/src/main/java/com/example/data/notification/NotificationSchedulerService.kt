package com.example.data.notification

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.example.MainActivity
import com.example.data.model.SubscriptionEntity
import java.util.Calendar

/**
 * 100% Client-Side Offline Push Notification Scheduler ($0 Server Costs)
 * Schedules triggers for:
 * - 7 Days Before (Yenilemeye 1 Hafta Kala)
 * - 3 Days Before (Son 3 Gün Uyarısı)
 * - 24 Hours / 1 Day Before (Son 24 Saat Uyarısı)
 * - 0 Days (Fatura Günü)
 */
object NotificationSchedulerService {

    const val CHANNEL_ID = "subscription_brake_alerts"
    private const val CHANNEL_NAME = "Abonelik ve Fatura Bildirimleri"
    private const val CHANNEL_DESC = "Fatura günü, deneme süresi ve zam bildirimleri"

    fun initialize(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = CHANNEL_DESC
                enableVibration(true)
                setShowBadge(true)
            }
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Schedules all reminder intervals for a subscription: [7, 3, 1, 0] days before.
     */
    fun scheduleRemindersForSubscription(context: Context, subscription: SubscriptionEntity) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        // First cancel any existing alarms for this subscription
        cancelRemindersForSubscription(context, subscription.id)

        // Parse reminder days from CSV string e.g. "7,3,1,0"
        val reminderOffsets = subscription.reminderDays
            .split(",")
            .mapNotNull { it.trim().toIntOrNull() }
            .ifEmpty { listOf(7, 3, 1, 0) }

        val targetBillingDateMs = if (subscription.isTrial && subscription.trialEndDateMs != null) {
            subscription.trialEndDateMs
        } else {
            subscription.nextBillingDateMs
        }

        for (daysBefore in reminderOffsets) {
            val triggerCal = Calendar.getInstance().apply {
                timeInMillis = targetBillingDateMs
                add(Calendar.DAY_OF_MONTH, -daysBefore)
                // Trigger at 09:00 AM local time
                set(Calendar.HOUR_OF_DAY, 9)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            val triggerTimeMs = triggerCal.timeInMillis
            val now = System.currentTimeMillis()

            if (triggerTimeMs > now) {
                val intent = Intent(context, NotificationReceiver::class.java).apply {
                    putExtra(NotificationReceiver.EXTRA_SUB_ID, subscription.id)
                    putExtra(NotificationReceiver.EXTRA_SERVICE_NAME, subscription.serviceName)
                    putExtra(NotificationReceiver.EXTRA_PRICE, subscription.price)
                    putExtra(NotificationReceiver.EXTRA_CURRENCY, subscription.currency)
                    putExtra(NotificationReceiver.EXTRA_DAYS_BEFORE, daysBefore)
                    putExtra(NotificationReceiver.EXTRA_IS_TRIAL, subscription.isTrial)
                }

                val requestCode = (subscription.id.toString() + "_" + daysBefore).hashCode()
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        alarmManager.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            triggerTimeMs,
                            pendingIntent
                        )
                    } else {
                        alarmManager.set(
                            AlarmManager.RTC_WAKEUP,
                            triggerTimeMs,
                            pendingIntent
                        )
                    }
                } catch (e: SecurityException) {
                    // Fallback to inexact alarm if exact alarm permission is restricted
                    alarmManager.set(
                        AlarmManager.RTC_WAKEUP,
                        triggerTimeMs,
                        pendingIntent
                    )
                }
            }
        }
    }

    /**
     * Cancels all scheduled reminder alarms for a given subscription ID.
     */
    fun cancelRemindersForSubscription(context: Context, subscriptionId: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val offsets = listOf(7, 3, 1, 0, 14, 30)
        for (daysBefore in offsets) {
            val intent = Intent(context, NotificationReceiver::class.java)
            val requestCode = (subscriptionId.toString() + "_" + daysBefore).hashCode()
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }
    }

    /**
     * Sends an immediate test notification to verify notification channel & display.
     */
    fun sendImmediateTestNotification(context: Context, title: String = "🚨 Subscription Brake: Test Bildirimi", message: String = "Çevrimdışı bildirim motoru devrede! 7G, 3G, 24S ve fatura günü uyarıları hazır.") {
        initialize(context)
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            9999,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(9999, notification)
    }
}
