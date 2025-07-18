import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reading_streak_provider.dart';

class StreakCard extends ConsumerWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(readingStreakNotifierProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    if (streakState.isLoading) {
      return _buildLoadingCard(context);
    }

    if (streakState.errorMessage != null) {
      return _buildErrorCard(context, streakState.errorMessage!);
    }

    final streak = streakState.currentStreak;
    final stats = streakState.stats;

    if (streak == null || stats == null) {
      return _buildEmptyCard(context);
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(isTablet ? 12.0 : 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: _getStreakGradient(streak.currentStreak, theme),
          ),
          child: isCompact
              ? _buildCompactContent(context, streak, stats, theme)
              : _buildFullContent(context, streak, stats, theme),
        ),
      ),
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    dynamic streak,
    dynamic stats,
    ThemeData theme,
  ) {
    return Row(
      children: [
        // Streak icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStreakIcon(streak.currentStreak),
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        
        // Streak info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${streak.currentStreak} dias',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                streak.hasReadToday ? 'Lido hoje!' : 'Leia hoje',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: streak.hasReadToday
                      ? Colors.green.shade600
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        
        // Status indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: streak.hasReadToday
                ? Colors.green.shade600
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent(
    BuildContext context,
    dynamic streak,
    dynamic stats,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              _getStreakIcon(streak.currentStreak),
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sequência de Leitura',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _getStreakStatus(streak, theme),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (streak.hasReadToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Concluído',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Stats row
        Row(
          children: [
            _buildStatItem(
              'Atual',
              '${streak.currentStreak}',
              'dias',
              theme.colorScheme.primary,
              theme,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              'Recorde',
              '${streak.longestStreak}',
              'dias',
              theme.colorScheme.secondary,
              theme,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              'Total',
              '${streak.totalDaysRead}',
              'dias',
              theme.colorScheme.tertiary,
              theme,
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Progress message
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                streak.hasReadToday ? Icons.check_circle : Icons.schedule,
                color: streak.hasReadToday
                    ? Colors.green.shade600
                    : theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getProgressMessage(streak),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    Color color,
    ThemeData theme,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Carregando streak...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.auto_stories,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Comece sua jornada de leitura hoje!',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getStreakGradient(int streakCount, ThemeData theme) {
    if (streakCount == 0) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surface.withValues(alpha: 0.8),
        ],
      );
    } else if (streakCount < 7) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.1),
          theme.colorScheme.primary.withValues(alpha: 0.05),
        ],
      );
    } else if (streakCount < 30) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.secondary.withValues(alpha: 0.1),
          theme.colorScheme.secondary.withValues(alpha: 0.05),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber.withValues(alpha: 0.1),
          Colors.amber.withValues(alpha: 0.05),
        ],
      );
    }
  }

  IconData _getStreakIcon(int streakCount) {
    if (streakCount == 0) return Icons.auto_stories;
    if (streakCount < 7) return Icons.local_fire_department;
    if (streakCount < 30) return Icons.whatshot;
    return Icons.emoji_events;
  }

  String _getStreakStatus(dynamic streak, ThemeData theme) {
    if (streak.hasReadToday) {
      return 'Devocional de hoje concluído!';
    } else if (streak.isStreakActive) {
      return 'Continue sua sequência de ${streak.currentStreak} dias';
    } else {
      return 'Inicie sua jornada de leitura hoje';
    }
  }

  String _getProgressMessage(dynamic streak) {
    if (streak.hasReadToday) {
      if (streak.currentStreak == 1) {
        return 'Parabéns! Você iniciou sua jornada de leitura 🎉';
      } else {
        return 'Excelente! Você manteve sua sequência de ${streak.currentStreak} dias 💪';
      }
    } else {
      return 'Leia o devocional de hoje para manter sua sequência!';
    }
  }
}