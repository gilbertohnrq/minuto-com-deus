import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumPopup extends ConsumerWidget {
  const PremiumPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.9,
          maxWidth: isTablet ? 600 : double.infinity,
        ),
        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: isTablet ? 28 : 24,
                ),
              ),

              // Premium icon
              Container(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: theme.colorScheme.primary,
                  size: isTablet ? 64 : 48,
                ),
              ),

              SizedBox(height: isTablet ? 24 : 16),

              // Title
              Text(
                'Experimente o Premium!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: isTablet ? 28 : null,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Subtitle
              Text(
                'Desfrute de uma experiência livre de anúncios',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: isTablet ? 18 : null,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 32 : 24),

              // Benefits
              Column(
                children: [
                  _buildBenefit(
                    context,
                    Icons.block,
                    'Sem anúncios',
                    'Experiência completamente livre de anúncios',
                    isTablet,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  _buildBenefit(
                    context,
                    Icons.star,
                    'Conteúdo exclusivo',
                    'Acesso a devocionais especiais',
                    isTablet,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  _buildBenefit(
                    context,
                    Icons.support,
                    'Suporte prioritário',
                    'Atendimento especial para membros premium',
                    isTablet,
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 32 : 24),

              // Price
              Container(
                padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'R\$ 4,99/mês',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: isTablet ? 32 : null,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      'Cancele a qualquer momento',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: isTablet ? 14 : null,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 32 : 24),

              // Buttons
              Column(
                children: [
                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 56 : 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/premium');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Assinar Premium',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 16 : 12),

                  // Maybe later button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Talvez mais tarde',
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isTablet,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 16 : null,
                ),
              ),
              SizedBox(height: isTablet ? 4 : 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: isTablet ? 14 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
