import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../domain/entities/devotional.dart';

class DevotionalCard extends StatelessWidget {
  final Devotional devotional;
  final VoidCallback? onRefresh;

  const DevotionalCard({
    super.key,
    required this.devotional,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // Responsive padding and sizing
    final cardMargin = EdgeInsets.all(isTablet ? 24.0 : 16.0);
    final cardPadding = EdgeInsets.all(isTablet ? 28.0 : 20.0);
    final iconSize = isTablet ? 24.0 : 20.0;

    return Container(
      margin: cardMargin,
      child: Card(
        elevation: isTablet ? 6 : 4,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Devocional de Hoje',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: isTablet ? 14 : 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            app_date_utils.DateUtils.formatDateDisplay(
                                devotional.date),
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 20 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRefresh != null)
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: onRefresh,
                          icon: Icon(
                            Icons.refresh,
                            color: colorScheme.primary,
                            size: iconSize,
                          ),
                          tooltip: 'Atualizar',
                        ),
                      ),
                  ],
                ),

                SizedBox(height: isTablet ? 24 : 16),

                // Biblical verse section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.4),
                        colorScheme.primaryContainer.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: colorScheme.primary,
                            size: iconSize,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Versículo',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        devotional.verse,
                        style: textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: colorScheme.onSurface,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 28 : 20),

                // Reflection message section
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                      size: iconSize,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reflexão',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 12 : 8),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 4 : 2,
                    horizontal: isTablet ? 8 : 4,
                  ),
                  child: Text(
                    devotional.message,
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurface,
                      fontSize: isTablet ? 16 : 14,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),

                // Add some bottom spacing for better visual balance
                SizedBox(height: isTablet ? 8 : 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DevotionalCardSkeleton extends StatelessWidget {
  const DevotionalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // Responsive padding and sizing
    final cardMargin = EdgeInsets.all(isTablet ? 24.0 : 16.0);
    final cardPadding = EdgeInsets.all(isTablet ? 28.0 : 20.0);

    return Container(
      margin: cardMargin,
      child: Card(
        elevation: isTablet ? 6 : 4,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: isTablet ? 14 : 12,
                          width: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: isTablet ? 20 : 16,
                          width: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 24 : 16),

                // Verse section skeleton
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.4),
                        colorScheme.primaryContainer.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                            size: isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: isTablet ? 14 : 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Container(
                        height: isTablet ? 18 : 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: isTablet ? 18 : 16,
                        width: 250,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 28 : 20),

                // Reflection title skeleton
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                      size: isTablet ? 24 : 20,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: isTablet ? 18 : 16,
                      width: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 12 : 8),

                // Reflection text skeleton
                Container(
                  height: isTablet ? 16 : 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: isTablet ? 16 : 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: isTablet ? 16 : 14,
                  width: 300,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Add some bottom spacing for better visual balance
                SizedBox(height: isTablet ? 8 : 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
