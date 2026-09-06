import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/subscription_model.dart';
import 'add_catalog_subscription_dialog.dart';
import 'add_subscription_modal_bottom_sheet.dart';

class CatalogTile extends StatelessWidget {
  final SubscriptionCatalogItem item;
  final VoidCallback? onTap;

  const CatalogTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () {
              showAddCatalogSubscriptionDialog(context, catalogItem: item);
            },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Service Avatar Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getBrandColor(item.name).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForCategory(item.category),
                  color: _getBrandColor(item.name),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isPopular) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentEmerald.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentEmerald,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${item.tierName}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${item.priceTry.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  Text(
                    '/${item.defaultBillingCycle == "annual" ? "yr" : "mo"}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.add_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBrandColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('netflix')) return const Color(0xFFE50914);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('youtube')) return const Color(0xFFFF0000);
    if (lower.contains('exxen')) return const Color(0xFFFFCC00);
    if (lower.contains('blutv')) return const Color(0xFF00A2E8);
    if (lower.contains('chatgpt')) return const Color(0xFF10A37F);
    if (lower.contains('prime')) return const Color(0xFF00A8E1);
    if (lower.contains('disney')) return const Color(0xFF113CCF);
    if (lower.contains('game pass') || lower.contains('xbox')) return const Color(0xFF107C10);
    if (lower.contains('icloud') || lower.contains('apple')) return const Color(0xFF555555);
    return AppTheme.primaryNavy;
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'streaming video':
      case 'shopping & video':
        return Icons.movie_outlined;
      case 'music & audio':
      case 'music & video':
        return Icons.music_note_outlined;
      case 'ai & productivity':
        return Icons.psychology_outlined;
      case 'cloud storage':
        return Icons.cloud_outlined;
      case 'gaming':
        return Icons.sports_esports_outlined;
      case 'sports & tv':
        return Icons.sports_soccer_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'audiobooks':
        return Icons.auto_stories_outlined;
      default:
        return Icons.subscriptions_outlined;
    }
  }
}
