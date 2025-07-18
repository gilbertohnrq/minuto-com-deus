import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon/Logo
                    Container(
                      width: isTablet ? 120 : 80,
                      height: isTablet ? 120 : 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(isTablet ? 30 : 20),
                      ),
                      child: Icon(
                        Icons.auto_stories,
                        size: isTablet ? 60 : 40,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Welcome Text
                    Text(
                      'Bem-vindo ao\nDevocional Diário',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 32 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Sua dose diária de inspiração e reflexão espiritual',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: isTablet ? 18 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Features preview
                    _buildFeatureItem(
                      context,
                      Icons.notifications,
                      'Notificações diárias',
                      'Receba lembretes gentis para seus momentos de reflexão',
                      isTablet,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildFeatureItem(
                      context,
                      Icons.favorite,
                      'Conteúdo inspirador',
                      'Devocionais cuidadosamente selecionados para seu crescimento',
                      isTablet,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildFeatureItem(
                      context,
                      Icons.workspace_premium,
                      'Premium disponível',
                      'Acesso completo sem anúncios e recursos exclusivos',
                      isTablet,
                    ),
                  ],
                ),
              ),
              
              // CTA Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 14,
                        ),
                      ),
                      child: Text(
                        'Começar gratuitamente',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/premium');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 14,
                        ),
                      ),
                      child: Text(
                        'Ver planos Premium',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Comece grátis • Sem cartão de crédito',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: isTablet ? 14 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            ),
            child: Icon(
              icon,
              size: isTablet ? 24 : 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          
          const SizedBox(width: 16),
          
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
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: isTablet ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
