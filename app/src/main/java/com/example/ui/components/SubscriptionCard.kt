package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material.icons.filled.Headphones
import androidx.compose.material.icons.filled.HourglassTop
import androidx.compose.material.icons.filled.Movie
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.ShoppingBag
import androidx.compose.material.icons.filled.SportsSoccer
import androidx.compose.material.icons.filled.Subscriptions
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.Tv
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.SubscriptionEntity
import com.example.ui.theme.AmberDark
import com.example.ui.theme.AmberLight
import com.example.ui.theme.CrimsonDark
import com.example.ui.theme.CrimsonLight
import com.example.ui.theme.EmeraldAccent
import com.example.ui.theme.NavyDark
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun SubscriptionCard(
    subscription: SubscriptionEntity,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val dateFormat = SimpleDateFormat("dd MMM yyyy", Locale.forLanguageTag("tr-TR"))
    val nextBillingStr = dateFormat.format(Date(subscription.nextBillingDateMs))

    val currencySymbol = when (subscription.currency) {
        "TRY" -> "₺"
        "USD" -> "$"
        "EUR" -> "€"
        else -> subscription.currency
    }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .clickable(onClick = onClick)
            .testTag("sub_card_${subscription.id}"),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    CategoryIconBadge(
                        category = subscription.category,
                        serviceName = subscription.serviceName
                    )

                    Spacer(modifier = Modifier.width(12.dp))

                    Column {
                        Text(
                            text = subscription.serviceName,
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurface
                            ),
                            maxLines = 1
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = subscription.category,
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        )
                    }
                }

                // Price Section
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "$currencySymbol${String.format(Locale.US, "%.2f", subscription.price)}",
                        style = MaterialTheme.typography.titleLarge.copy(
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary
                        )
                    )
                    Text(
                        text = "/${subscription.billingCycle}",
                        style = MaterialTheme.typography.labelSmall.copy(
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Badges & Next Billing Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Next Billing Date or Trial end
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = if (subscription.isTrial) Icons.Default.HourglassTop else Icons.Default.CreditCard,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = if (subscription.isTrial) Color(0xFFDC2626) else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = if (subscription.isTrial) "Deneme Bitişi: $nextBillingStr" else "Fatura: $nextBillingStr",
                        style = MaterialTheme.typography.bodySmall.copy(
                            fontSize = 12.sp,
                            color = if (subscription.isTrial) Color(0xFFDC2626) else MaterialTheme.colorScheme.onSurfaceVariant,
                            fontWeight = if (subscription.isTrial) FontWeight.SemiBold else FontWeight.Normal
                        )
                    )
                }

                // Badges (Trial or Hike)
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    if (subscription.isTrial) {
                        Surface(
                            color = CrimsonLight,
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.NotificationsActive,
                                    contentDescription = null,
                                    modifier = Modifier.size(12.dp),
                                    tint = CrimsonDark
                                )
                                Spacer(modifier = Modifier.width(3.dp))
                                Text(
                                    text = "DENEME",
                                    color = CrimsonDark,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }

                    if (subscription.isPriceHikeDetected && subscription.priceHikePercentage != null) {
                        Surface(
                            color = AmberLight,
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.AutoMirrored.Filled.TrendingUp,
                                    contentDescription = null,
                                    modifier = Modifier.size(12.dp),
                                    tint = AmberDark
                                )
                                Spacer(modifier = Modifier.width(3.dp))
                                Text(
                                    text = "+%${subscription.priceHikePercentage} ZAM",
                                    color = AmberDark,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }

            if (!subscription.paymentMethodHint.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "Ödeme: ${subscription.paymentMethodHint}",
                    style = MaterialTheme.typography.bodySmall.copy(
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.8f)
                    )
                )
            }
        }
    }
}

@Composable
fun CategoryIconBadge(
    category: String,
    serviceName: String,
    modifier: Modifier = Modifier
) {
    val (icon, bgColor) = getCategoryIconAndColor(category, serviceName)

    Box(
        modifier = modifier
            .size(44.dp)
            .background(bgColor.copy(alpha = 0.15f), shape = RoundedCornerShape(12.dp)),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = category,
            tint = bgColor,
            modifier = Modifier.size(24.dp)
        )
    }
}

fun getCategoryIconAndColor(category: String, serviceName: String): Pair<ImageVector, Color> {
    val nameLower = serviceName.lowercase()
    val catLower = category.lowercase()

    return when {
        catLower.contains("video") || nameLower.contains("netflix") || nameLower.contains("disney") || nameLower.contains("gain") || nameLower.contains("blutv") || nameLower.contains("exxen") -> {
            Icons.Default.Movie to Color(0xFFE11D48) // Rose Red
        }
        catLower.contains("music") || catLower.contains("müzik") || nameLower.contains("spotify") -> {
            Icons.Default.Headphones to Color(0xFF10B981) // Emerald Green
        }
        nameLower.contains("youtube") -> {
            Icons.Default.Tv to Color(0xFFDC2626) // YouTube Red
        }
        catLower.contains("ai") || nameLower.contains("gpt") || nameLower.contains("claude") || nameLower.contains("gemini") -> {
            Icons.Default.AutoAwesome to Color(0xFF8B5CF6) // Purple
        }
        catLower.contains("shopping") || nameLower.contains("prime") -> {
            Icons.Default.ShoppingBag to Color(0xFF0284C7) // Sky Blue
        }
        catLower.contains("sport") || nameLower.contains("tod") || nameLower.contains("sport") -> {
            Icons.Default.SportsSoccer to Color(0xFFF59E0B) // Amber
        }
        catLower.contains("cloud") || nameLower.contains("icloud") || nameLower.contains("drive") -> {
            Icons.Default.Cloud to Color(0xFF2563EB) // Royal Blue
        }
        catLower.contains("book") || nameLower.contains("storytel") -> {
            Icons.Default.Book to Color(0xFFD97706) // Orange
        }
        catLower.contains("education") || nameLower.contains("duolingo") -> {
            Icons.Default.School to Color(0xFF16A34A) // Green
        }
        else -> {
            Icons.Default.Subscriptions to NavyDark
        }
    }
}
