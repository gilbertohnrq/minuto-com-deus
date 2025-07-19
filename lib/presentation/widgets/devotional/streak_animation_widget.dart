import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reflection_streak_provider.dart';

class StreakAnimationWidget extends ConsumerStatefulWidget {
  final VoidCallback? onAnimationComplete;

  const StreakAnimationWidget({
    super.key,
    this.onAnimationComplete,
  });

  @override
  ConsumerState<StreakAnimationWidget> createState() =>
      _StreakAnimationWidgetState();
}

class _StreakAnimationWidgetState extends ConsumerState<StreakAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start scale animation
    await _scaleController.forward();
    
    // Wait a bit, then start slide and fade
    await Future.delayed(const Duration(milliseconds: 500));
    
    _slideController.forward();
    _fadeController.forward();
    
    // Complete after all animations
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (mounted) {
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newStreakCount = ref.watch(newStreakCountProvider);
    final isMilestone = ref.watch(isStreakMilestoneProvider);
    
    if (newStreakCount == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _fadeAnimation,
              _slideAnimation,
            ]),
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isMilestone
                              ? [
                                  Colors.amber.withValues(alpha: 0.9),
                                  Colors.orange.withValues(alpha: 0.9),
                                ]
                              : [
                                  colorScheme.primary.withValues(alpha: 0.9),
                                  colorScheme.primaryContainer.withValues(alpha: 0.9),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isMilestone ? Colors.amber : colorScheme.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fire/Star icon based on milestone
                          Icon(
                            isMilestone ? Icons.star : Icons.local_fire_department,
                            size: 64,
                            color: Colors.white,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Streak count
                          Text(
                            '$newStreakCount',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 72,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Streak text
                          Text(
                            newStreakCount == 1 
                                ? 'Dia de reflexão!'
                                : 'Dias de reflexão!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          if (isMilestone) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getMilestoneMessage(newStreakCount),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          
                          // Encouraging message
                          Text(
                            _getEncouragingMessage(newStreakCount, isMilestone),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getMilestoneMessage(int streak) {
    switch (streak) {
      case 7:
        return '🎉 Marco de 1 semana! 🎉';
      case 30:
        return '🌟 Marco de 1 mês! 🌟';
      case 100:
        return '🏆 Marco de 100 dias! 🏆';
      default:
        return '🎊 Marco especial! 🎊';
    }
  }

  String _getEncouragingMessage(int streak, bool isMilestone) {
    if (isMilestone) {
      switch (streak) {
        case 7:
          return 'Você está construindo um hábito incrível!';
        case 30:
          return 'Sua dedicação é verdadeiramente inspiradora!';
        case 100:
          return 'Você é um exemplo de perseverança!';
        default:
          return 'Continue essa jornada maravilhosa!';
      }
    }
    
    if (streak == 1) {
      return 'Parabéns por começar sua jornada!';
    } else if (streak < 7) {
      return 'Continue assim, você está indo muito bem!';
    } else if (streak < 30) {
      return 'Sua consistência é admirável!';
    } else {
      return 'Você é um verdadeiro exemplo!';
    }
  }
}