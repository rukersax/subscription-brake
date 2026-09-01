package com.example.ui.screens

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.compose.foundation.background
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
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
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.example.data.backup.BackupService
import com.example.data.model.SubscriptionEntity
import com.example.data.notification.NotificationSchedulerService
import com.example.ui.theme.EmeraldAccent
import com.example.ui.theme.NavyDark

@Composable
fun BackupRestoreDialog(
    subscriptions: List<SubscriptionEntity>,
    onDismiss: () -> Unit,
    onRestoreSubscriptions: (List<SubscriptionEntity>) -> Unit
) {
    val context = LocalContext.current
    var selectedTab by remember { mutableIntStateOf(0) } // 0 = Dışa Aktar (Export), 1 = İçe Aktar (Import), 2 = Bildirim Testi

    // Export States
    var exportPassphrase by remember { mutableStateOf("") }
    var generatedEncryptedJson by remember { mutableStateOf<String?>(null) }
    var exportError by remember { mutableStateOf<String?>(null) }

    // Import States
    var importPassphrase by remember { mutableStateOf("") }
    var importPayloadJson by remember { mutableStateOf("") }
    var importError by remember { mutableStateOf<String?>(null) }
    var importSuccessMessage by remember { mutableStateOf<String?>(null) }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.85f)
                .clip(RoundedCornerShape(24.dp))
                .testTag("backup_restore_dialog"),
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
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(NavyDark),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Security,
                                contentDescription = null,
                                tint = EmeraldAccent,
                                modifier = Modifier.size(22.dp)
                            )
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text(
                                text = "Gizlilik ve Yedekleme",
                                style = MaterialTheme.typography.titleLarge.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            )
                            Text(
                                text = "AES-256 Şifreli Yerel Yedekleme",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            )
                        }
                    }

                    IconButton(
                        onClick = onDismiss,
                        modifier = Modifier.testTag("close_backup_dialog_button")
                    ) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Kapat")
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Tabs: Dışa Aktar & Yedekten Yükle & Bildirim Testi
                TabRow(
                    selectedTabIndex = selectedTab,
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f),
                    contentColor = NavyDark,
                    modifier = Modifier.clip(RoundedCornerShape(14.dp))
                ) {
                    Tab(
                        selected = selectedTab == 0,
                        onClick = { selectedTab = 0 },
                        modifier = Modifier.testTag("tab_export_backup"),
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(imageVector = Icons.Default.Upload, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Dışa Aktar", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                            }
                        }
                    )
                    Tab(
                        selected = selectedTab == 1,
                        onClick = { selectedTab = 1 },
                        modifier = Modifier.testTag("tab_import_backup"),
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(imageVector = Icons.Default.Download, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Yedekten Yükle", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                            }
                        }
                    )
                    Tab(
                        selected = selectedTab == 2,
                        onClick = { selectedTab = 2 },
                        modifier = Modifier.testTag("tab_notification_test"),
                        text = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(imageVector = Icons.Default.NotificationsActive, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Bildirim Testi", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                            }
                        }
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Tab Contents
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    when (selectedTab) {
                        0 -> {
                            // EXPORT TAB
                            Card(
                                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f)),
                                shape = RoundedCornerShape(14.dp)
                            ) {
                                Column(modifier = Modifier.padding(14.dp)) {
                                    Text(
                                        text = "🔒 Sıfır Bilgi Güvenliği (Zero-Knowledge AES-256)",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = NavyDark
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "${subscriptions.size} adet abonelik, notlar ve döngüler belirleyeceğiniz parola ile cihazınızda şifrelenir. Sunucuya hiçbir veri gönderilmez.",
                                        fontSize = 12.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }

                            OutlinedTextField(
                                value = exportPassphrase,
                                onValueChange = {
                                    exportPassphrase = it
                                    exportError = null
                                },
                                label = { Text("Yedekleme Parolası Belirleyin *") },
                                placeholder = { Text("En az 4 karakter") },
                                visualTransformation = PasswordVisualTransformation(),
                                leadingIcon = {
                                    Icon(imageVector = Icons.Default.Lock, contentDescription = null)
                                },
                                singleLine = true,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("export_passphrase_input"),
                                shape = RoundedCornerShape(12.dp)
                            )

                            if (exportError != null) {
                                Text(
                                    text = exportError!!,
                                    color = MaterialTheme.colorScheme.error,
                                    fontSize = 12.sp
                                )
                            }

                            Button(
                                onClick = {
                                    if (exportPassphrase.length < 4) {
                                        exportError = "Lütfen en az 4 karakterli bir parola girin."
                                    } else {
                                        try {
                                            val encryptedJson = BackupService.exportEncryptedBackup(subscriptions, exportPassphrase)
                                            generatedEncryptedJson = encryptedJson
                                            exportError = null
                                            Toast.makeText(context, "AES-256 Yedeği Başarıyla Oluşturuldu!", Toast.LENGTH_SHORT).show()
                                        } catch (e: Exception) {
                                            exportError = "Yedekleme hatası: ${e.localizedMessage}"
                                        }
                                    }
                                },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(48.dp)
                                    .testTag("btn_create_encrypted_backup"),
                                colors = ButtonDefaults.buttonColors(containerColor = NavyDark),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(imageVector = Icons.Default.Security, contentDescription = null, tint = EmeraldAccent)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("AES-256 ile Şifrele & Dışa Aktar", fontWeight = FontWeight.Bold)
                            }

                            if (generatedEncryptedJson != null) {
                                Spacer(modifier = Modifier.height(6.dp))
                                Card(
                                    colors = CardDefaults.cardColors(containerColor = EmeraldAccent.copy(alpha = 0.15f)),
                                    shape = RoundedCornerShape(12.dp)
                                ) {
                                    Column(modifier = Modifier.padding(12.dp)) {
                                        Text(
                                            text = "✅ Şifrelenmiş Yedek Metni Hazır",
                                            fontWeight = FontWeight.Bold,
                                            color = NavyDark,
                                            fontSize = 13.sp
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text(
                                            text = "Bu şifreli metni kopyalayabilir veya e-posta/not uygulamalarınıza gönderebilirsiniz.",
                                            fontSize = 11.sp,
                                            color = MaterialTheme.colorScheme.onSurfaceVariant
                                        )
                                    }
                                }

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    OutlinedButton(
                                        onClick = {
                                            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                            val clip = ClipData.newPlainText("SubscriptionBrake_Backup", generatedEncryptedJson)
                                            clipboard.setPrimaryClip(clip)
                                            Toast.makeText(context, "Şifreli yedek panoya kopyalandı!", Toast.LENGTH_SHORT).show()
                                        },
                                        modifier = Modifier
                                            .weight(1f)
                                            .height(44.dp)
                                            .testTag("btn_copy_backup"),
                                        shape = RoundedCornerShape(10.dp)
                                    ) {
                                        Icon(imageVector = Icons.Default.ContentCopy, contentDescription = null, modifier = Modifier.size(16.dp))
                                        Spacer(modifier = Modifier.width(4.dp))
                                        Text("Kopyala", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                    }

                                    Button(
                                        onClick = {
                                            val sendIntent = Intent().apply {
                                                action = Intent.ACTION_SEND
                                                putExtra(Intent.EXTRA_TEXT, generatedEncryptedJson)
                                                type = "text/plain"
                                            }
                                            val shareIntent = Intent.createChooser(sendIntent, "Şifreli Abonelik Yedeğini Paylaş")
                                            context.startActivity(shareIntent)
                                        },
                                        modifier = Modifier
                                            .weight(1f)
                                            .height(44.dp)
                                            .testTag("btn_share_backup"),
                                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldAccent),
                                        shape = RoundedCornerShape(10.dp)
                                    ) {
                                        Icon(imageVector = Icons.Default.Share, contentDescription = null, tint = NavyDark, modifier = Modifier.size(16.dp))
                                        Spacer(modifier = Modifier.width(4.dp))
                                        Text("Paylaş", color = NavyDark, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }

                        1 -> {
                            // IMPORT TAB
                            Card(
                                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f)),
                                shape = RoundedCornerShape(14.dp)
                            ) {
                                Column(modifier = Modifier.padding(14.dp)) {
                                    Text(
                                        text = "📥 Şifreli Yedekten Geri Yükleme",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = NavyDark
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "Daha önce dışa aktardığınız şifreli JSON metnini ve parolanızı girerek aboneliklerinizi geri yükleyin.",
                                        fontSize = 12.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }

                            OutlinedTextField(
                                value = importPayloadJson,
                                onValueChange = {
                                    importPayloadJson = it
                                    importError = null
                                },
                                label = { Text("Şifreli Yedek Metnini Yapıştırın *") },
                                placeholder = { Text("{\n  \"schema\": \"subbrake_aes256_v1\",\n  \"iv\": \"...\",\n  \"data\": \"...\"\n}") },
                                maxLines = 6,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(120.dp)
                                    .testTag("import_payload_input"),
                                shape = RoundedCornerShape(12.dp)
                            )

                            OutlinedTextField(
                                value = importPassphrase,
                                onValueChange = {
                                    importPassphrase = it
                                    importError = null
                                },
                                label = { Text("Yedekleme Parolası *") },
                                placeholder = { Text("Oluştururken kullandığınız parola") },
                                visualTransformation = PasswordVisualTransformation(),
                                leadingIcon = {
                                    Icon(imageVector = Icons.Default.Lock, contentDescription = null)
                                },
                                singleLine = true,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("import_passphrase_input"),
                                shape = RoundedCornerShape(12.dp)
                            )

                            if (importError != null) {
                                Text(
                                    text = importError!!,
                                    color = MaterialTheme.colorScheme.error,
                                    fontSize = 12.sp
                                )
                            }

                            if (importSuccessMessage != null) {
                                Text(
                                    text = importSuccessMessage!!,
                                    color = EmeraldAccent,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 13.sp
                                )
                            }

                            Button(
                                onClick = {
                                    if (importPayloadJson.isBlank()) {
                                        importError = "Lütfen şifreli yedek metnini yapıştırın."
                                    } else if (importPassphrase.isBlank()) {
                                        importError = "Lütfen parolanızı girin."
                                    } else {
                                        try {
                                            val restored = BackupService.importEncryptedBackup(importPayloadJson, importPassphrase)
                                            onRestoreSubscriptions(restored)
                                            importSuccessMessage = "✅ ${restored.size} adet abonelik başarıyla geri yüklendi!"
                                            importError = null
                                            Toast.makeText(context, "${restored.size} adet abonelik başarıyla yüklendi!", Toast.LENGTH_LONG).show()
                                        } catch (e: Exception) {
                                            importError = e.message ?: "Şifre çözme hatası! Parola veya veri bozuk olabilir."
                                        }
                                    }
                                },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(48.dp)
                                    .testTag("btn_execute_restore"),
                                colors = ButtonDefaults.buttonColors(containerColor = NavyDark),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(imageVector = Icons.Default.Download, contentDescription = null, tint = EmeraldAccent)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Şifreyi Çöz ve Geri Yükle", fontWeight = FontWeight.Bold)
                            }
                        }

                        2 -> {
                            // NOTIFICATION TEST TAB
                            Card(
                                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f)),
                                shape = RoundedCornerShape(14.dp)
                            ) {
                                Column(modifier = Modifier.padding(14.dp)) {
                                    Text(
                                        text = "⏰ Çevrimdışı Push Bildirim Testi ($0 Sunucu Maliyeti)",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = NavyDark
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = "Subscription Brake, tüm fatura hatırlatmalarını (7 Gün, 3 Gün, 24 Saat ve Fatura Günü) yerel AlarmManager ile %100 çevrimdışı zamanlar.",
                                        fontSize = 12.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }

                            Button(
                                onClick = {
                                    NotificationSchedulerService.sendImmediateTestNotification(
                                        context = context,
                                        title = "🚨 Subscription Brake: Fatura Uyarısı",
                                        message = "Netflix ₺229.99 ödemeniz 3 gün sonra gerçekleşecek. Çevrimdışı zamanlayıcı devrede!"
                                    )
                                    Toast.makeText(context, "Test bildirimi gönderildi!", Toast.LENGTH_SHORT).show()
                                },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(48.dp)
                                    .testTag("btn_send_test_notification"),
                                colors = ButtonDefaults.buttonColors(containerColor = EmeraldAccent),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Icon(imageVector = Icons.Default.NotificationsActive, contentDescription = null, tint = NavyDark)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Şimdi Test Bildirimi Gönder", color = NavyDark, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }
        }
    }
}
