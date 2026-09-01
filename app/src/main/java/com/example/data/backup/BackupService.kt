package com.example.data.backup

import android.util.Base64
import com.example.data.model.SubscriptionEntity
import org.json.JSONArray
import org.json.JSONObject
import java.security.MessageDigest
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * Privacy-First AES-256 Encrypted Offline Backup & Export Engine ($0 Server Costs, 100% On-Device)
 */
object BackupService {

    private const val ALGORITHM = "AES/CBC/PKCS5Padding"
    private const val APP_TAG = "Subscription Brake"
    private const val BACKUP_VERSION = 1

    /**
     * Serializes subscriptions to JSON and encrypts with AES-256 using the provided passphrase.
     * Returns a formatted JSON string containing IV and encrypted ciphertext in Base64.
     */
    fun exportEncryptedBackup(subscriptions: List<SubscriptionEntity>, passphrase: String): String {
        require(passphrase.isNotBlank()) { "Yedekleme şifresi boş olamaz." }

        // Build internal data JSON
        val rootObj = JSONObject().apply {
            put("app", APP_TAG)
            put("version", BACKUP_VERSION)
            put("exportedAtMs", System.currentTimeMillis())
            put("count", subscriptions.size)

            val subsArray = JSONArray()
            for (sub in subscriptions) {
                val subObj = JSONObject().apply {
                    put("id", sub.id)
                    put("serviceName", sub.serviceName)
                    put("category", sub.category)
                    put("billingCycle", sub.billingCycle)
                    put("price", sub.price)
                    put("currency", sub.currency)
                    put("nextBillingDateMs", sub.nextBillingDateMs)
                    if (sub.trialEndDateMs != null) put("trialEndDateMs", sub.trialEndDateMs)
                    put("isTrial", sub.isTrial)
                    put("alertTrial24h", sub.alertTrial24h)
                    if (sub.catalogId != null) put("catalogId", sub.catalogId)
                    if (sub.paymentMethodHint != null) put("paymentMethodHint", sub.paymentMethodHint)
                    if (sub.cancellationUrl != null) put("cancellationUrl", sub.cancellationUrl)
                    put("reminderDays", sub.reminderDays)
                    if (sub.notes != null) put("notes", sub.notes)
                    if (sub.baselineCatalogPrice != null) put("baselineCatalogPrice", sub.baselineCatalogPrice)
                    put("isPriceHikeDetected", sub.isPriceHikeDetected)
                    if (sub.priceHikePercentage != null) put("priceHikePercentage", sub.priceHikePercentage)
                    put("status", sub.status)
                    put("createdAtMs", sub.createdAtMs)
                }
                subsArray.put(subObj)
            }
            put("subscriptions", subsArray)
        }

        val rawJsonBytes = rootObj.toString().toByteArray(Charsets.UTF_8)

        // Derive 256-bit AES key via SHA-256
        val digest = MessageDigest.getInstance("SHA-256")
        val keyBytes = digest.digest(passphrase.toByteArray(Charsets.UTF_8))
        val secretKey = SecretKeySpec(keyBytes, "AES")

        // 16-byte random IV
        val ivBytes = ByteArray(16)
        SecureRandom().nextBytes(ivBytes)
        val ivSpec = IvParameterSpec(ivBytes)

        val cipher = Cipher.getInstance(ALGORITHM)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec)
        val encryptedBytes = cipher.doFinal(rawJsonBytes)

        val ivBase64 = Base64.encodeToString(ivBytes, Base64.NO_WRAP)
        val encryptedBase64 = Base64.encodeToString(encryptedBytes, Base64.NO_WRAP)

        val bundleObj = JSONObject().apply {
            put("schema", "subbrake_aes256_v1")
            put("iv", ivBase64)
            put("data", encryptedBase64)
            put("created_at", System.currentTimeMillis())
        }

        return bundleObj.toString(2)
    }

    /**
     * Decrypts an encrypted JSON bundle using the passphrase and restores subscription entities.
     */
    fun importEncryptedBackup(encryptedBundleJson: String, passphrase: String): List<SubscriptionEntity> {
        require(passphrase.isNotBlank()) { "Şifre çözmek için parola giriniz." }

        val bundleObj = JSONObject(encryptedBundleJson.trim())
        if (!bundleObj.has("iv") || !bundleObj.has("data")) {
            throw IllegalArgumentException("Geçersiz yedek formatı. 'iv' veya 'data' alanı eksik.")
        }

        val ivBase64 = bundleObj.getString("iv")
        val encryptedBase64 = bundleObj.getString("data")

        val ivBytes = Base64.decode(ivBase64, Base64.NO_WRAP)
        val encryptedBytes = Base64.decode(encryptedBase64, Base64.NO_WRAP)

        // Derive 256-bit AES key via SHA-256
        val digest = MessageDigest.getInstance("SHA-256")
        val keyBytes = digest.digest(passphrase.toByteArray(Charsets.UTF_8))
        val secretKey = SecretKeySpec(keyBytes, "AES")
        val ivSpec = IvParameterSpec(ivBytes)

        val cipher = Cipher.getInstance(ALGORITHM)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
        val decryptedBytes = try {
            cipher.doFinal(encryptedBytes)
        } catch (e: Exception) {
            throw IllegalArgumentException("Şifre çözülemedi! Lütfen girdiğiniz parolanın doğru olduğundan emin olun.")
        }

        val decryptedJsonStr = String(decryptedBytes, Charsets.UTF_8)
        val rootObj = JSONObject(decryptedJsonStr)
        val subsArray = rootObj.getJSONArray("subscriptions")

        val list = mutableListOf<SubscriptionEntity>()
        for (i in 0 until subsArray.length()) {
            val obj = subsArray.getJSONObject(i)
            val sub = SubscriptionEntity(
                id = 0, // Auto-generate new primary key on restore to prevent collision
                serviceName = obj.getString("serviceName"),
                category = obj.optString("category", "Other"),
                billingCycle = obj.optString("billingCycle", "monthly"),
                price = obj.getDouble("price"),
                currency = obj.optString("currency", "TRY"),
                nextBillingDateMs = obj.getLong("nextBillingDateMs"),
                trialEndDateMs = if (obj.has("trialEndDateMs")) obj.getLong("trialEndDateMs") else null,
                isTrial = obj.optBoolean("isTrial", false),
                alertTrial24h = obj.optBoolean("alertTrial24h", true),
                catalogId = if (obj.has("catalogId")) obj.getString("catalogId") else null,
                paymentMethodHint = if (obj.has("paymentMethodHint")) obj.getString("paymentMethodHint") else null,
                cancellationUrl = if (obj.has("cancellationUrl")) obj.getString("cancellationUrl") else null,
                reminderDays = obj.optString("reminderDays", "7,3,1,0"),
                notes = if (obj.has("notes")) obj.getString("notes") else null,
                baselineCatalogPrice = if (obj.has("baselineCatalogPrice")) obj.getDouble("baselineCatalogPrice") else null,
                isPriceHikeDetected = obj.optBoolean("isPriceHikeDetected", false),
                priceHikePercentage = if (obj.has("priceHikePercentage")) obj.getDouble("priceHikePercentage") else null,
                status = obj.optString("status", "active"),
                createdAtMs = obj.optLong("createdAtMs", System.currentTimeMillis())
            )
            list.add(sub)
        }

        return list
    }
}
