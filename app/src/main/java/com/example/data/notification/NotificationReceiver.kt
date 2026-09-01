package com.example.data.notification

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.example.MainActivity

class NotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val subId = intent.getLongExtra(EXTRA_SUB_ID, -1L)
        val serviceName = intent.getStringExtra(EXTRA_SERVICE_NAME) ?: "Abonelik"
        val price = intent.getDoubleExtra(EXTRA_PRICE, 0.0)
        val currency = intent.getStringExtra(EXTRA_CURRENCY) ?: "TRY"
        val daysBefore = intent.getIntExtra(EXTRA_DAYS_BEFORE, 0)
        val isTrial = intent.getBooleanExtra(EXTRA_IS_TRIAL, false)

        val currencySymbol = when (currency) {
            "TRY" -> "₺"
            "USD" -> "$"
            "EUR" -> "€"
            else -> currency
        }

        val title: String
        val message: String

        if (isTrial) {
            title = "⚠️ Deneme Süresi Uyarısı: $serviceName"
            message = if (daysBefore == 0) {
                "$serviceName deneme süreniz bugün bitiyor! İptal edilmezse $currencySymbol$price tahsil edilecektir."
            } else {
                "$serviceName deneme sürenizin bitmesine $daysBefore gün kaldı. Otomatik çekimi önlemek için inceleyin."
            }
        } else {
            if (daysBefore == 0) {
                title = "🚨 Fatura Günü: $serviceName"
                message = "$serviceName için $currencySymbol$price ödemeniz bugün yenilenecektir."
            } else {
                title = "⏰ $serviceName Yenileme Hatırlatması"
                message = "$serviceName aboneliğiniz $daysBefore gün sonra yenilenecek ($currencySymbol$price). İptal etmek veya incelemek için dokunun."
            }
        }

        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            subId.toInt(),
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, NotificationSchedulerService.CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationId = (subId.toString() + "_" + daysBefore).hashCode()
        notificationManager.notify(notificationId, notification)
    }

    companion object {
        const val EXTRA_SUB_ID = "extra_sub_id"
        const val EXTRA_SERVICE_NAME = "extra_service_name"
        const val EXTRA_PRICE = "extra_price"
        const val EXTRA_CURRENCY = "extra_currency"
        const val EXTRA_DAYS_BEFORE = "extra_days_before"
        const val EXTRA_IS_TRIAL = "extra_is_trial"
    }
}
