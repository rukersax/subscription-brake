package com.example.data.model

data class CatalogPlan(
    val id: String,
    val name: String,
    val priceTry: Double,
    val priceUsd: Double,
    val priceEur: Double,
    val description: String = "",
    val billingCycle: String = "monthly"
)

data class CatalogItem(
    val id: String,
    val name: String,
    val category: String,
    val tierName: String,
    val defaultBillingCycle: String = "monthly",
    val priceTry: Double,
    val priceUsd: Double,
    val priceEur: Double,
    val iconCategory: String,
    val isPopular: Boolean = false,
    val cancellationUrl: String? = null,
    val plans: List<CatalogPlan> = emptyList()
)

object CatalogData {
    val predefinedServices = listOf(
        CatalogItem(
            id = "cat-1",
            name = "Netflix",
            category = "Streaming Video",
            tierName = "Standart",
            defaultBillingCycle = "monthly",
            priceTry = 229.99,
            priceUsd = 15.49,
            priceEur = 13.49,
            iconCategory = "movie",
            isPopular = true,
            cancellationUrl = "https://www.netflix.com/youraccount",
            plans = listOf(
                CatalogPlan(
                    id = "netflix-basic",
                    name = "Temel Paket",
                    priceTry = 149.99,
                    priceUsd = 9.99,
                    priceEur = 8.99,
                    description = "720p HD Kalite • 1 Cihaz"
                ),
                CatalogPlan(
                    id = "netflix-standard",
                    name = "Standart Paket",
                    priceTry = 229.99,
                    priceUsd = 15.49,
                    priceEur = 13.49,
                    description = "1080p Full HD • 2 Cihaz"
                ),
                CatalogPlan(
                    id = "netflix-premium",
                    name = "Özel (Premium) Paket",
                    priceTry = 299.99,
                    priceUsd = 19.99,
                    priceEur = 17.99,
                    description = "4K Ultra HD + HDR • 4 Cihaz"
                )
            )
        ),
        CatalogItem(
            id = "cat-2",
            name = "Spotify",
            category = "Music & Audio",
            tierName = "Bireysel",
            defaultBillingCycle = "monthly",
            priceTry = 59.99,
            priceUsd = 11.99,
            priceEur = 10.99,
            iconCategory = "music",
            isPopular = true,
            cancellationUrl = "https://www.spotify.com/account/cancel/",
            plans = listOf(
                CatalogPlan(
                    id = "spotify-student",
                    name = "Öğrenci Paketi",
                    priceTry = 32.99,
                    priceUsd = 5.99,
                    priceEur = 5.49,
                    description = "1 Doğrulanmış Öğrenci Hesabı"
                ),
                CatalogPlan(
                    id = "spotify-individual",
                    name = "Bireysel Paket",
                    priceTry = 59.99,
                    priceUsd = 11.99,
                    priceEur = 10.99,
                    description = "1 Premium Hesap • Reklamsız & İndirme"
                ),
                CatalogPlan(
                    id = "spotify-duo",
                    name = "Duo Paketi",
                    priceTry = 79.99,
                    priceUsd = 14.99,
                    priceEur = 13.99,
                    description = "Aynı Evde Yaşayan 2 Hesap"
                ),
                CatalogPlan(
                    id = "spotify-family",
                    name = "Aile Paketi",
                    priceTry = 99.99,
                    priceUsd = 16.99,
                    priceEur = 15.99,
                    description = "6 Kişiye Kadar Premium Hesap"
                )
            )
        ),
        CatalogItem(
            id = "cat-3",
            name = "YouTube Premium",
            category = "Music & Video",
            tierName = "Bireysel",
            defaultBillingCycle = "monthly",
            priceTry = 79.99,
            priceUsd = 13.99,
            priceEur = 12.99,
            iconCategory = "video",
            isPopular = true,
            cancellationUrl = "https://www.youtube.com/paid_memberships",
            plans = listOf(
                CatalogPlan(
                    id = "yt-student",
                    name = "Öğrenci Paketi",
                    priceTry = 37.99,
                    priceUsd = 7.99,
                    priceEur = 6.99,
                    description = "Tek Kullanıcı • Reklamsız Video & Music"
                ),
                CatalogPlan(
                    id = "yt-individual",
                    name = "Bireysel Paket",
                    priceTry = 79.99,
                    priceUsd = 13.99,
                    priceEur = 12.99,
                    description = "Reklamsız YouTube + Arka Planda Oynatma"
                ),
                CatalogPlan(
                    id = "yt-family",
                    name = "Aile Paketi",
                    priceTry = 115.99,
                    priceUsd = 22.99,
                    priceEur = 20.99,
                    description = "5 Aile Üyesi Dahil"
                )
            )
        ),
        CatalogItem(
            id = "cat-4",
            name = "Exxen",
            category = "Streaming Video",
            tierName = "Reklamsız",
            defaultBillingCycle = "monthly",
            priceTry = 222.50,
            priceUsd = 7.00,
            priceEur = 6.50,
            iconCategory = "tv",
            isPopular = true,
            cancellationUrl = "https://www.exxen.com/tr/hesabim",
            plans = listOf(
                CatalogPlan(
                    id = "exxen-ad",
                    name = "Reklamlı Paket",
                    priceTry = 160.50,
                    priceUsd = 5.00,
                    priceEur = 4.60,
                    description = "Dizi ve Eğlence Programları"
                ),
                CatalogPlan(
                    id = "exxen-no-ad",
                    name = "Reklamsız Paket",
                    priceTry = 222.50,
                    priceUsd = 7.00,
                    priceEur = 6.50,
                    description = "Kesintisiz Reklamsız Yayın"
                ),
                CatalogPlan(
                    id = "exxen-sport-ad",
                    name = "ExxenSpor Reklamlı",
                    priceTry = 289.00,
                    priceUsd = 9.00,
                    priceEur = 8.50,
                    description = "Şampiyonlar Ligi & Avrupa Kupaları"
                ),
                CatalogPlan(
                    id = "exxen-sport-noad",
                    name = "ExxenSpor Reklamsız",
                    priceTry = 347.50,
                    priceUsd = 11.00,
                    priceEur = 10.20,
                    description = "Tüm Spor & Dizi İçerikleri Reklamsız"
                )
            )
        ),
        CatalogItem(
            id = "cat-5",
            name = "BluTV",
            category = "Streaming Video",
            tierName = "Standart Aylık",
            defaultBillingCycle = "monthly",
            priceTry = 139.90,
            priceUsd = 4.50,
            priceEur = 4.20,
            iconCategory = "tv",
            isPopular = true,
            cancellationUrl = "https://www.blutv.com/hesabim",
            plans = listOf(
                CatalogPlan(
                    id = "blutv-monthly",
                    name = "Aylık Standart Paket",
                    priceTry = 139.90,
                    priceUsd = 4.50,
                    priceEur = 4.20,
                    description = "HBO & Özel Yerli Yapımlar"
                ),
                CatalogPlan(
                    id = "blutv-annual",
                    name = "Yıllık Taahhütlü (Aylık)",
                    priceTry = 99.90,
                    priceUsd = 3.20,
                    priceEur = 3.00,
                    description = "12 Ay Taahhütlü İndirimli Fiyat"
                )
            )
        ),
        CatalogItem(
            id = "cat-6",
            name = "ChatGPT Plus",
            category = "AI & Productivity",
            tierName = "Plus (GPT-4o)",
            defaultBillingCycle = "monthly",
            priceTry = 649.99,
            priceUsd = 20.00,
            priceEur = 22.00,
            iconCategory = "ai",
            isPopular = true,
            cancellationUrl = "https://chatgpt.com/#settings/Subscription",
            plans = listOf(
                CatalogPlan(
                    id = "chatgpt-plus",
                    name = "Plus (Bireysel) Paket",
                    priceTry = 649.99,
                    priceUsd = 20.00,
                    priceEur = 22.00,
                    description = "GPT-4o, DALL-E & Erken Erişim Modelleri"
                ),
                CatalogPlan(
                    id = "chatgpt-team",
                    name = "Team (Ekip) Paketi",
                    priceTry = 999.00,
                    priceUsd = 30.00,
                    priceEur = 32.00,
                    description = "Kullanıcı Başına • Ekip Çalışma Alanı"
                )
            )
        ),
        CatalogItem(
            id = "cat-7",
            name = "Amazon Prime",
            category = "Shopping & Video",
            tierName = "Prime TR",
            defaultBillingCycle = "monthly",
            priceTry = 39.00,
            priceUsd = 14.99,
            priceEur = 8.99,
            iconCategory = "shopping",
            isPopular = true,
            cancellationUrl = "https://www.amazon.com.tr/mc/manage/your-memberships-and-subscriptions",
            plans = listOf(
                CatalogPlan(
                    id = "prime-tr",
                    name = "Prime TR Aylık Paket",
                    priceTry = 39.00,
                    priceUsd = 14.99,
                    priceEur = 8.99,
                    description = "Hızlı Kargo + Prime Video + Prime Gaming"
                )
            )
        ),
        CatalogItem(
            id = "cat-8",
            name = "Disney+",
            category = "Streaming Video",
            tierName = "Standart",
            defaultBillingCycle = "monthly",
            priceTry = 164.90,
            priceUsd = 13.99,
            priceEur = 11.99,
            iconCategory = "movie",
            isPopular = true,
            cancellationUrl = "https://www.disneyplus.com/account",
            plans = listOf(
                CatalogPlan(
                    id = "disney-standard",
                    name = "Standart Paket",
                    priceTry = 164.90,
                    priceUsd = 9.99,
                    priceEur = 8.99,
                    description = "1080p Full HD • 2 Eşzamanlı Cihaz"
                ),
                CatalogPlan(
                    id = "disney-premium",
                    name = "Özel (Premium) Paket",
                    priceTry = 229.90,
                    priceUsd = 13.99,
                    priceEur = 11.99,
                    description = "4K UHD & HDR • Dolby Atmos • 4 Cihaz"
                )
            )
        ),
        CatalogItem(
            id = "cat-9",
            name = "TOD (beIN)",
            category = "Sports & TV",
            tierName = "Süper Lig",
            defaultBillingCycle = "monthly",
            priceTry = 389.00,
            priceUsd = 12.00,
            priceEur = 11.00,
            iconCategory = "sports",
            isPopular = true,
            cancellationUrl = "https://www.todtv.com.tr/hesabim",
            plans = listOf(
                CatalogPlan(
                    id = "tod-entertainment",
                    name = "Eğlence Paketi",
                    priceTry = 129.00,
                    priceUsd = 4.00,
                    priceEur = 3.80,
                    description = "Dizi, Film & Canlı TV Kanalları"
                ),
                CatalogPlan(
                    id = "tod-team",
                    name = "Taraftar Paketi",
                    priceTry = 279.00,
                    priceUsd = 9.00,
                    priceEur = 8.20,
                    description = "Seçtiğin Takımın Tüm Lig Maçları"
                ),
                CatalogPlan(
                    id = "tod-superlig",
                    name = "Süper Lig Paketi",
                    priceTry = 389.00,
                    priceUsd = 12.00,
                    priceEur = 11.00,
                    description = "Tüm Süper Lig Maçları + Derbiler"
                )
            )
        ),
        CatalogItem(
            id = "cat-10",
            name = "Gain",
            category = "Streaming Video",
            tierName = "Premium",
            defaultBillingCycle = "monthly",
            priceTry = 149.00,
            priceUsd = 4.90,
            priceEur = 4.50,
            iconCategory = "tv",
            isPopular = false,
            cancellationUrl = "https://www.gain.tv/hesabim",
            plans = listOf(
                CatalogPlan(
                    id = "gain-student",
                    name = "Öğrenci Paketi",
                    priceTry = 69.00,
                    priceUsd = 2.30,
                    priceEur = 2.10,
                    description = "Öğrencilere Özel İndirimli Erişim"
                ),
                CatalogPlan(
                    id = "gain-premium",
                    name = "Premium Aylık Paket",
                    priceTry = 149.00,
                    priceUsd = 4.90,
                    priceEur = 4.50,
                    description = "Tüm Özel Gain Dizileri & Belgeseller"
                )
            )
        ),
        CatalogItem(
            id = "cat-11",
            name = "iCloud+",
            category = "Cloud Storage",
            tierName = "200 GB",
            defaultBillingCycle = "monthly",
            priceTry = 79.99,
            priceUsd = 2.99,
            priceEur = 2.99,
            iconCategory = "cloud",
            isPopular = true,
            cancellationUrl = "https://support.apple.com/HT207594",
            plans = listOf(
                CatalogPlan(
                    id = "icloud-50gb",
                    name = "50 GB Saklama Alanı",
                    priceTry = 19.99,
                    priceUsd = 0.99,
                    priceEur = 0.99,
                    description = "Gizli E-posta & HomeKit Desteği"
                ),
                CatalogPlan(
                    id = "icloud-200gb",
                    name = "200 GB Saklama Alanı",
                    priceTry = 79.99,
                    priceUsd = 2.99,
                    priceEur = 2.99,
                    description = "Aile Paylaşımı ile 5 Kişiye Kadar"
                ),
                CatalogPlan(
                    id = "icloud-2tb",
                    name = "2 TB Saklama Alanı",
                    priceTry = 249.99,
                    priceUsd = 9.99,
                    priceEur = 9.99,
                    description = "Geniş Arşiv & 4K Video Yedekleme"
                )
            )
        ),
        CatalogItem(
            id = "cat-12",
            name = "Xbox Game Pass",
            category = "Gaming",
            tierName = "Ultimate",
            defaultBillingCycle = "monthly",
            priceTry = 309.00,
            priceUsd = 19.99,
            priceEur = 17.99,
            iconCategory = "gaming",
            isPopular = true,
            cancellationUrl = "https://account.microsoft.com/services",
            plans = listOf(
                CatalogPlan(
                    id = "xbox-pc",
                    name = "PC Game Pass",
                    priceTry = 209.00,
                    priceUsd = 11.99,
                    priceEur = 10.99,
                    description = "100+ PC Oyunu + EA Play Dahil"
                ),
                CatalogPlan(
                    id = "xbox-ultimate",
                    name = "Ultimate Paket",
                    priceTry = 309.00,
                    priceUsd = 19.99,
                    priceEur = 17.99,
                    description = "Konsol + PC + Cloud Gaming + EA Play"
                )
            )
        ),
        CatalogItem(
            id = "cat-13",
            name = "Duolingo Super",
            category = "Education",
            tierName = "Super Bireysel",
            defaultBillingCycle = "monthly",
            priceTry = 129.99,
            priceUsd = 12.99,
            priceEur = 11.99,
            iconCategory = "education",
            isPopular = false,
            cancellationUrl = "https://www.duolingo.com/settings/super",
            plans = listOf(
                CatalogPlan(
                    id = "duo-ind",
                    name = "Super Bireysel Paket",
                    priceTry = 129.99,
                    priceUsd = 12.99,
                    priceEur = 11.99,
                    description = "Sınırsız Can & Reklamsız Dil Öğrenme"
                ),
                CatalogPlan(
                    id = "duo-fam",
                    name = "Super Aile Paketi",
                    priceTry = 199.99,
                    priceUsd = 19.99,
                    priceEur = 18.99,
                    description = "6 Aile Üyesi veya Arkadaş Dahil"
                )
            )
        ),
        CatalogItem(
            id = "cat-14",
            name = "S Sport Plus",
            category = "Sports & TV",
            tierName = "Aylık Paket",
            defaultBillingCycle = "monthly",
            priceTry = 99.99,
            priceUsd = 3.20,
            priceEur = 3.00,
            iconCategory = "sports",
            isPopular = false,
            cancellationUrl = "https://www.ssportplus.com/profilim",
            plans = listOf(
                CatalogPlan(
                    id = "ssport-monthly",
                    name = "Aylık Standart Paket",
                    priceTry = 99.99,
                    priceUsd = 3.20,
                    priceEur = 3.00,
                    description = "LaLiga, Serie A, EuroLeague & F1"
                ),
                CatalogPlan(
                    id = "ssport-annual",
                    name = "Yıllık İndirimli Paket",
                    priceTry = 699.99,
                    priceUsd = 22.00,
                    priceEur = 20.00,
                    description = "Tek Seferlik Yıllık Ödeme Avantajı",
                    billingCycle = "annual"
                )
            )
        ),
        CatalogItem(
            id = "cat-15",
            name = "Storytel",
            category = "Audiobooks",
            tierName = "Sınırsız Sesli Kitap",
            defaultBillingCycle = "monthly",
            priceTry = 149.99,
            priceUsd = 9.99,
            priceEur = 8.99,
            iconCategory = "book",
            isPopular = false,
            cancellationUrl = "https://www.storytel.com/tr/tr/hesabim",
            plans = listOf(
                CatalogPlan(
                    id = "storytel-individual",
                    name = "Sınırsız Bireysel Paket",
                    priceTry = 149.99,
                    priceUsd = 9.99,
                    priceEur = 8.99,
                    description = "1 Hesap • Sınırsız Sesli Kitap & E-Kitap"
                ),
                CatalogPlan(
                    id = "storytel-family",
                    name = "Aile Paketi",
                    priceTry = 249.99,
                    priceUsd = 15.99,
                    priceEur = 14.99,
                    description = "Ebeveyn & Çocuk Modu • 2 Hesap"
                )
            )
        )
    )
}
